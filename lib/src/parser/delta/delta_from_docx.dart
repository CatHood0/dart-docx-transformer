import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart' as xml;

import '../../../docx_transformer.dart';
import '../../common/generators/convert_xml_styles_to_doc.dart';
import '../../common/internals_vars.dart';
import '../../common/schemas/common_node_keys/word_files_common.dart';
import '../../common/schemas/common_node_keys/xml_keys.dart';
import '../../constants.dart';

class DeltaFromDocxParser extends Parser<Uint8List, Future<Delta?>?, DeltaParserOptions> {
  DeltaFromDocxParser({
    required super.data,
    required super.options,
  });

  ZipDecoder? _zipDecoder;

  @override
  Future<Delta?>? build() async {
    final Delta delta = Delta();
    _zipDecoder ??= ZipDecoder();

    final Archive archive = _zipDecoder!.decodeBytes(data);
    // we can get the styles of some paragraph directly
    // gettings first the
    //
    // We need to take in account, that are paragraph that implements the attribute
    // [rsId] or [rsIdDefault] that reference to a specific style into styles.xml
    // that applies different styles to that paragraph implicitely without passing them
    xml.XmlDocument? styles;
    xml.XmlDocument? document;
    xml.XmlDocument? settings;
    // we can get the hyperlink relations that we could need
    // since hyperlinks only add the attr r:id="" that has a id ref
    // to document.rels.xml
    //
    // the relation node looks like
    // <Relationship Id="rId10" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink"
    //  Target="https://www.youtube.com/watch?v=EXAMPLE" TargetMode="External"/>
    //
    // probably we want to create a cache from all the relations to avoid searching always
    xml.XmlDocument? documentRels;
    final Map<String, Object> rawMedia = <String, Object>{};

    // search the necessary files
    for (final ArchiveFile file in archive) {
      if (file.name == stylesXmlFilePath) {
        final String fileContent = utf8.decode(file.content);
        styles = xml.XmlDocument.parse(fileContent);
      }
      if (file.name == documentXmlRelsFilePath) {
        final String fileContent = utf8.decode(file.content);
        documentRels = xml.XmlDocument.parse(fileContent);
      }
      if (file.name == settingsXmlFilePath) {
        final String fileContent = utf8.decode(file.content);
        settings = xml.XmlDocument.parse(fileContent);
      }
      if (file.name.startsWith('word/media/')) {
        final InputStream? w = file.getContent();
        if (w != null) {
          rawMedia[file.name] = w.toUint8List();
        }
      }
      if (file.name == documentFilePath) {
        final String fileContent = utf8.decode(file.content);
        document = xml.XmlDocument.parse(fileContent);
      }
    }

    if (document == null) {
      throw StateError("$documentFilePath couldn't be founded into the File passed");
    }

    _buildTabMultiplierIfNeeded(settings);

    final Map<String, Object> documentRelations = <String, Object>{};
    // cache ops
    // correspond => {rId: link}
    buildRelations(
      documentRels,
      objectBuilder: (String id, String type, String target) {
        documentRelations[id] = target;
      },
    );

    final DocumentStylesSheet docStyles = DocumentStylesSheet.fromStyles(
      styles!,
      ConverterFromXmlContext(
        shouldParserSizeToHeading: options.shouldParserSizeToHeading,
        parseXmlSpacing: options.parseXmlSpacing,
        ignoreColorWhenNoSupported: options.ignoreColorWhenNoSupported,
        colorBuilder: options.colorBuilder,
        checkColor: options.checkColor,
        acceptFontValueWhen: options.acceptFontValueWhen,
        acceptSizeValueWhen: options.acceptSizeValueWhen,
        acceptSpacingValueWhen: options.acceptSpacingValueWhen,
        defaultTabStop: kDefaultTabStop,
      ),
      computeIndents: false,
    );

    final Iterable<xml.XmlElement> paragraphNodes = document.findAllElements(xmlParagraphNode);

    for (final xml.XmlElement paragraph in paragraphNodes) {
      // common parents nodes
      final xml.XmlElement? paragraphLevelAttributesNode = paragraph.getElement(xmlParagraphBlockAttrsNode);
      // <w:rPr> node could be into <w:pPr> since this last one correspond to the common attributes
      // applied to the entire paragraph (<w:p>)
      final xml.XmlElement? commonInlineParagraphAttributes =
          paragraphLevelAttributesNode?.getElement(xmlParagraphInlineAttsrNode);
      final Map<String, dynamic> blockAttributes = <String, dynamic>{};
      // these are the attributes that probably will be applied to a part of the text
      final Map<String, dynamic> inlineAttributes = <String, dynamic>{};
      // these are the attributes that will be applied to the entire characters of the paragraph
      final Map<String, dynamic> paragraphInlineAttributes = <String, dynamic>{};
      // Getting the w:pStyle, we can the styleId that is stored into styles.xml
      //
      // then, we already have the styles parsed to a human readable class, we can get the specific
      // style by the id passed
      final xml.XmlElement? paragraphStyle = paragraphLevelAttributesNode?.getElement(xmlpStyleNode);
      final Style? style = docStyles.getStyleById(paragraphStyle?.getAttribute('w:val') ?? '') ??
          docStyles.getStyleById(
            paragraph.getAttribute('w:rsId') ?? '',
          );
      if (style != null) {
        //TODO: sometimes, basedOn param, could be "Normal" that means
        // that we will need to search `<w:docDefaults>` node and get the styles
        // that are applied to the all common paragraphs
        final Style parent = docStyles.getParentOf(style);
        blockAttributes.addAll(<String, dynamic>{...?style.block, ...?parent.block});
        paragraphInlineAttributes.addAll(<String, dynamic>{...?style.inline, ...?parent.inline});
      }
      // block attributes
      final (
        xml.XmlElement? listNode,
        xml.XmlElement? tabNode,
        xml.XmlElement? indentNode,
        xml.XmlElement? alignNode,
        xml.XmlElement? spacingNode,
        xml.XmlElement? borderNode,
      ) = buildParagraphAttributesNodes(paragraphLevelAttributesNode);

      final List<xml.XmlNode> textPartNodes = List<xml.XmlNode>.from(paragraph.children)
        ..removeWhere((xml.XmlNode node) =>
            node is xml.XmlElement && (node.localName == 'pPr' || node.localName == 'proofErr'));
      // if the textPartNodes are empty we will need to ignore the paragraph
      // because it is only a new line
      if (textPartNodes.isEmpty) {
        buildBlockAttributes(
          tabNode,
          indentNode,
          alignNode,
          listNode,
          spacingNode,
          borderNode,
          blockAttributes,
        );
        if (blockAttributes.isNotEmpty) {
          delta.insert('\n', blockAttributes);
        }
        delta.insert('\n');
        continue;
      }
      // Docx nodes divides the content by "preserved whitespaces"
      // and styles attributes
      //
      // then, we will need to verify the node type and the text
      // inside to avoid add unexpected chars
      //
      // # This is how Word Editor creates its lines (using Delta format)
      //
      // [
      //  {"insert": "This"},
      //  {"insert": " "},
      //  {"insert": "is"},
      //  {"insert": " "},
      //  {"insert": "a"},
      //  {"insert": " "},
      //  {"insert": "bold text", {"bold": true}},
      //  {"insert": " "},
      // ]
      buildBlockAttributes(
        tabNode,
        indentNode,
        alignNode,
        listNode,
        spacingNode,
        borderNode,
        blockAttributes,
      );
      for (final xml.XmlElement textPartNode in textPartNodes.whereType<xml.XmlElement>()) {
        // ignore misspell items
        if (textPartNode.localName == xmlProofErrorNode) continue;
        // hyperlink works as a wrapper of the nodes <w:r>
        // that contains the text parts
        //
        // that's why we insert the text separated of the common implementation
        if (textPartNode.localName == 'hyperlink') {
          final String? rId = textPartNode.getAttribute('r:id');
          final String? link = documentRelations[rId] as String?;
          if (link != null) {
            inlineAttributes['link'] = link;
          }
          await _buildInsertionPart(
            inlineAttributes,
            blockAttributes,
            paragraphInlineAttributes,
            commonInlineParagraphAttributes,
            textPartNode.getElement(xmlTextPartNode)!,
            delta,
            documentRelations,
            rawMedia,
          );
          continue;
        }
        await _buildInsertionPart(
          inlineAttributes,
          blockAttributes,
          paragraphInlineAttributes,
          commonInlineParagraphAttributes,
          textPartNode,
          delta,
          documentRelations,
          rawMedia,
        );
      }
      if (blockAttributes.isNotEmpty) {
        delta.insert('\n', blockAttributes);
      }
      bool shouldAddNewLineAfterParagraphEnd = true;
      for (final String element in _kDefaultExclusiveKeys) {
        if (blockAttributes[element] != null) {
          shouldAddNewLineAfterParagraphEnd = false;
          break;
        }
      }
      if (shouldAddNewLineAfterParagraphEnd) {
        delta.insert('\n');
      }
    }

    return delta.isEmpty ? null : delta;
  }

  Future<void> _buildInsertionPart(
    Map<String, dynamic> inlineAttributes,
    Map<String, dynamic> blockAttributes,
    Map<String, dynamic> paragraphInlineAttributes,
    xml.XmlElement? commonInlineParagraphAttributes,
    xml.XmlElement node,
    Delta delta,
    Map<String, dynamic> documentRelations,
    Map<String, Object> rawMedia,
  ) async {
    if (node.localName == 'r') {
      final xml.XmlElement? drawNode =
          node.getElement('w:drawing') ?? node.findAllElements('w:drawing').firstOrNull;
      // could be an image
      if (drawNode != null) {
        final xml.XmlElement? embedNode = drawNode.findAllElements('a:blip').firstOrNull;
        // if found this node, then means that this draw node
        // is probably a image renderer
        if (embedNode != null) {
          // get the rsId of the image
          final String imageId = embedNode.getAttribute('r:embed')!; // => rIdx
          // get the correct path from the document relations
          final String? imagePath = documentRelations[imageId] as String?;
          if (imagePath != null) {
            final String effectivePath = imagePath.startsWith('word/') ? imagePath : 'word/$imagePath';
            // get the bytes of the images from the media files
            final Uint8List bytes = rawMedia[effectivePath] as Uint8List;
            // transform the image to something that can be inserted in a Delta
            final String? url =
                await options.onDetectImage.call(bytes, imagePath.replaceFirst(imageNamePattern, ''));
            if (url != null) {
              assert(url.isNotEmpty, 'url/path of the image(path: $effectivePath) cannot be empty');
              delta.insert(<String, Object>{'image': url});
              inlineAttributes.clear();
              return;
            }
          }
        }
      }
    }
    final xml.XmlElement? inlineAttributesOfPart = node.getElement(xmlParagraphInlineAttsrNode);
    final bool hasInlineAttrs = inlineAttributesOfPart != null || commonInlineParagraphAttributes != null;
    if (hasInlineAttrs) {
      buildInlineAttributes(
        commonInlineParagraphAttributes,
        inlineAttributesOfPart,
        inlineAttributes,
        blockAttributes,
      );
    }
    // the node that contains the text
    delta.insert(
        node.getElement(xmlTextNode)?.innerText ?? '',
        inlineAttributes.isEmpty
            ? paragraphInlineAttributes.isEmpty
                ? null
                : paragraphInlineAttributes
            : <String, dynamic>{...inlineAttributes, ...paragraphInlineAttributes});
    inlineAttributes.clear();
  }

  void _buildTabMultiplierIfNeeded(xml.XmlDocument? settings) {
    final xml.XmlElement? tabNodeSettings = settings?.findAllElements('w:defaultTabStop').firstOrNull;
    final String? tabStopValue = tabNodeSettings?.getAttribute('w:val');
    if (settings == null || tabNodeSettings == null || tabStopValue == null) return;
    final double? numTab = double.tryParse(tabStopValue);
    // we need to update the multiplier if needed
    if (numTab != null) {
      kDefaultTabStop = numTab;
    }
  }

  (
    xml.XmlElement?,
    xml.XmlElement?,
    xml.XmlElement?,
    xml.XmlElement?,
    xml.XmlElement?,
    xml.XmlElement?,
  ) buildParagraphAttributesNodes(
    xml.XmlElement? paragraphAttributesNode,
  ) {
    final xml.XmlElement? listNode = paragraphAttributesNode?.getElement(xmlListNode);
    final xml.XmlElement? tabNode = paragraphAttributesNode?.getElement(xmlTabNode)?.getElement(xmlValueTabNode) ??
        paragraphAttributesNode?.getElement(xmlValueTabNode);
    final xml.XmlElement? indentNode = paragraphAttributesNode?.getElement(xmlIndentNode);
    final xml.XmlElement? alignNode = paragraphAttributesNode?.getElement(xmlAlignmentNode);
    final xml.XmlElement? spacingNode = paragraphAttributesNode?.getElement(xmlSpacingNode);
    final xml.XmlElement? borderNode = paragraphAttributesNode?.getElement(xmlBorderNode);
    return (listNode, tabNode, indentNode, alignNode, spacingNode, borderNode);
  }
}

final List<String> _kDefaultExclusiveKeys = List<String>.unmodifiable(
  <String>[
    'list',
    'code-block',
    'blockquote',
  ],
);
