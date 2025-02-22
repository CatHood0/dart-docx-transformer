import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:docx_transformer/docx_transformer.dart';
import 'package:docx_transformer/src/common/generators/convert_xml_styles_to_doc.dart';
import 'package:docx_transformer/src/parser/parser.dart';
import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart' as xml;

class DocxToDelta
    extends Parser<Uint8List, Future<Delta?>?, DeltaParserOptions> {
  ZipDecoder? _zipDecoder;
  DocxToDelta({
    required super.data,
    required super.options,
  });

  @override
  Future<Delta?>? build() async {
    Delta delta = Delta();
    _zipDecoder ??= ZipDecoder();

    final archive = _zipDecoder!.decodeBytes(data);
    // we can get the styles of some paragraph directly
    // gettings first the
    //
    // We need to take in account, that are paragraph that implements the attribute
    // [rsId] or [rsIdDefault] that reference to a specific style into styles.xml
    // that applies different styles to that paragraph implicitely without passing them
    xml.XmlDocument? styles;
    xml.XmlDocument? document;
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
    Map<String, Object> rawMedia = {};

    // search the necessary files
    for (final file in archive) {
      if (file.name == stylesXmlFilePath) {
        final fileContent = utf8.decode(file.content);
        styles = xml.XmlDocument.parse(fileContent);
      }
      if (file.name == documentXmlRelsFilePath) {
        final fileContent = utf8.decode(file.content);
        documentRels = xml.XmlDocument.parse(fileContent);
      }
      if (file.name.startsWith('word/media/')) {
        final w = file.getContent();
        if (w != null) {
          rawMedia[file.name] = w.toUint8List();
        }
      }
      if (file.name == documentFilePath) {
        final fileContent = utf8.decode(file.content);
        document = xml.XmlDocument.parse(fileContent);
      }
    }

    if (document == null) {
      throw StateError(
          '$documentFilePath couldn\'t be founded into the File passed');
    }

    // cache ops
    // correspond => {rId: link}
    final Map<String, Object> documentRelations =
        _buildRelations(documentRels) ?? {};
    final DocumentStylesSheet docStyles = DocumentStylesSheet.fromStyles(
      styles!,
      ConverterFromXmlContext(
        shouldParserSizeToHeading: options.shouldParserSizeToHeading,
      ),
    );

    final Iterable<xml.XmlElement> paragraphNodes =
        document.findAllElements(xmlParagraphNode);

    for (final xml.XmlElement paragraph in paragraphNodes) {
      // common parents nodes
      final xml.XmlElement? paragraphLevelAttributesNode =
          paragraph.getElement(xmlParagraphBlockAttrsNode);
      // <w:rPr> node could be into <w:pPr> since this last one correspond to the common attributes
      // applied to the entire paragraph (<w:p>)
      final xml.XmlElement? commonInlineParagraphAttributes =
          paragraphLevelAttributesNode?.getElement(xmlParagraphInlineAttsrNode);
      Map<String, dynamic> blockAttributes = {};
      // these are the attributes that probably could be applied to a part of the text
      Map<String, dynamic> inlineAttributes = {};
      // these are the attributes that will be applied to the entire characters of the paragraph
      Map<String, dynamic> generalInlineAttributes = {};
      // Getting the w:pStyle, we can the styleId that is stored into styles.xml
      //
      // then, we already have the styles parsed to a human readable class, we can get the specific
      // style by the id passed
      xml.XmlElement? paragraphStyle =
          paragraphLevelAttributesNode?.getElement(xmlpStyleNode);
      final Styles? style =
          docStyles.getStyleById(paragraphStyle?.getAttribute('w:val') ?? '') ??
              docStyles.getStyleById(
                paragraph.getAttribute('w:rsId') ?? '',
              );
      if (style != null) {
        //final Iterable<Iterable<Styles>> relatedStyles = docStyles.getDeepRelationships(style);
        if (style.block != null) {
          blockAttributes.addAll({...?style.block});
        }
        if (style.inline != null) {
          generalInlineAttributes.addAll({...?style.inline});
        }
      }
      // block attributes
      xml.XmlElement? listNode =
          paragraphLevelAttributesNode?.getElement(xmlListNode);
      xml.XmlElement? indentNode =
          paragraphLevelAttributesNode?.getElement(xmlTabNode);
      xml.XmlElement? alignNode =
          paragraphLevelAttributesNode?.getElement(xmlAlignmentNode);

      final List<xml.XmlNode> textPartNodes = List.from(paragraph.children)
        ..removeWhere((xml.XmlNode node) =>
            node is xml.XmlElement &&
            (node.localName == 'pPr' || node.localName == 'proofErr'));
      // if the textPartNodes are empty we will need to ignore the paragraph
      // because it is only a new line
      if (textPartNodes.isEmpty) {
        //TODO: check if it has block attributes
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
      for (final xml.XmlElement textPartNode
          in textPartNodes.whereType<xml.XmlElement>()) {
        // ignore misspell items
        if (textPartNode.localName == xmlProofErrorNode) continue;
        // hyperlink works as a wrapper of the nodes <w:r>
        // that contains the text parts
        //
        // that's why we insert the text separated of the common implementation
        if (textPartNode.localName == 'hyperlink') {
          final rId = textPartNode.getAttribute('r:id');
          final link = documentRelations[rId] as String?;
          if (link != null) {
            inlineAttributes['link'] = link;
          }
          _buildInsertionPart(
            inlineAttributes,
            generalInlineAttributes,
            commonInlineParagraphAttributes,
            textPartNode.getElement(xmlTextPartNode)!,
            delta,
            documentRelations,
            rawMedia,
          );
          continue;
        }
        _buildInsertionPart(
          inlineAttributes,
          generalInlineAttributes,
          commonInlineParagraphAttributes,
          textPartNode,
          delta,
          documentRelations,
          rawMedia,
        );
      }
      //TODO: divide inline and block attributes building to another function
      final bool isList = listNode != null;
      final bool containsIndent = indentNode != null;
      final bool containsAlignment = alignNode != null;
      if (containsIndent) {
        print(indentNode);
        print(indentNode);
      }
      if (containsAlignment) {
        final align = alignNode.getAttribute('w:val');
        if (align != null) {
          assert(
            align == 'left' ||
                align == 'right' ||
                align == 'center' ||
                align == 'justify',
            'Quill Delta only supports: right, left, center and justify alignments',
          );
          blockAttributes['align'] = align;
        }
      }
      if (isList) {
        final codeNum =
            listNode.getElement(xmlListTypeNode)!.getAttribute('w:val');
        final numberIndentLevel =
            listNode.getElement(xmlListIndentLevelNode)!.getAttribute('w:val');
        if (codeNum != null && (codeNum == '2' || codeNum == '3')) {
          blockAttributes['list'] = codeNum == '2' ? 'bullet' : 'ordered';
        }
        if (numberIndentLevel != null) {
          final indent = int.tryParse(numberIndentLevel);
          if (indent != null && indent > 0) {
            blockAttributes['indent'] = indent;
          }
        }
      }
      if (blockAttributes.isNotEmpty) {
        delta.insert('\n', blockAttributes);
        continue;
      }
      delta.insert('\n');
    }

    return delta.isEmpty ? null : delta;
  }

  void _buildInsertionPart(
    Map<String, dynamic> inlineAttributes,
    Map<String, dynamic> generalInlineAttributes,
    xml.XmlElement? commonInlineParagraphAttributes,
    xml.XmlElement node,
    Delta delta,
    Map<String, dynamic> documentRelations,
    Map<String, Object> rawMedia,
  ) async {
    if (node.localName == 'r') {
      final drawNode = node.getElement('w:drawing') ??
          node.findAllElements('w:drawing').firstOrNull;
      // could be an image
      if (drawNode != null) {
        final embedNode = drawNode.findAllElements('a:blip').firstOrNull;
        // if found this node, then means that this draw node
        // is probably a image renderer
        if (embedNode != null) {
          // get the rsId of the image
          final imageId = embedNode.getAttribute('r:embed')!; // => rIdx
          // get the correct path from the document relations
          final imagePath = documentRelations[imageId] as String?;
          if (imagePath != null) {
            final effectivePath =
                imagePath.startsWith('word/') ? imagePath : 'word/$imagePath';
            // get the bytes of the images from the media files
            final bytes = rawMedia[effectivePath] as Uint8List;
            // transform the image to something that can be inserted in a Delta
            final url = await options.onDetectImage
                .call(bytes, imagePath.replaceFirst(r'.*\/', ''));
            if (url != null) {
              assert(url is String, 'Embed Images only accept "String" type');
              delta.insert({'image': url});
              inlineAttributes.clear();
              return;
            }
          }
        }
      }
    }
    final inlineAttributesOfPart = node.getElement(xmlParagraphInlineAttsrNode);
    bool hasInlineAttrs = inlineAttributesOfPart != null ||
        commonInlineParagraphAttributes != null;
    if (hasInlineAttrs) {
      _buildInlineAttributes(
        commonInlineParagraphAttributes,
        inlineAttributesOfPart,
        inlineAttributes,
      );
    }
    // the node that contains the text
    delta.insert(
        node.getElement(xmlTextNode)?.innerText ?? '',
        inlineAttributes.isEmpty
            ? generalInlineAttributes.isEmpty
                ? null
                : generalInlineAttributes
            : {...inlineAttributes, ...generalInlineAttributes});
    inlineAttributes.clear();
  }

  void _buildInlineAttributes(
    xml.XmlElement? paragraphAttributes,
    xml.XmlElement? lineAttributes,
    Map<String, dynamic> inlineAttributes,
  ) {
    // family
    final fontFamilyNode = lineAttributes?.getElement(xmlFontsNode) ??
        paragraphAttributes?.getElement(xmlFontsNode);
    final fontSizeNode = lineAttributes?.getElement(xmlFontsNode) ??
        paragraphAttributes?.getElement(xmlFontsNode);
    // italic
    final italicNode = (lineAttributes?.getElement(xmlItalicNode) ??
            lineAttributes?.getElement(xmlItalicNode)) ??
        (paragraphAttributes?.getElement(xmlItalicNode) ??
            paragraphAttributes?.getElement(xmlItalicNode));
    // bold
    paragraphAttributes?.getElement(xmlItalicNode);
    final boldNode = (lineAttributes?.getElement(xmlBoldNode) ??
            lineAttributes?.getElement(xmlBoldCsNode)) ??
        (paragraphAttributes?.getElement(xmlBoldNode) ??
            paragraphAttributes?.getElement(xmlBoldCsNode));
    // underline
    final underlineNode = lineAttributes?.getElement(xmlUnderlineNode) ??
        paragraphAttributes?.getElement(xmlUnderlineNode);
    // strike
    final strikethroughNode =
        lineAttributes?.getElement(xmlStrikethroughNode) ??
            paragraphAttributes?.getElement(xmlStrikethroughNode);
    // text color
    final colorNode = lineAttributes?.getElement(xmlCharacterColorNode) ??
        paragraphAttributes?.getElement(xmlCharacterColorNode);
    // background color
    final backgroundColorNode =
        lineAttributes?.getElement(xmlBackgroundCharacterColorNode) ??
            paragraphAttributes?.getElement(xmlBackgroundCharacterColorNode);
    // nodes values
    final sizeAttr = fontSizeNode?.getAttribute(xmlSizeFontNode) ??
        fontSizeNode?.getAttribute(xmlSizeCsFontNode);
    final familyAttr = fontFamilyNode?.getAttribute('asciiTheme') ??
        fontFamilyNode?.getAttribute('hAnsiTheme');
    final color = colorNode?.getAttribute('w:val');
    final backgroundColor = backgroundColorNode?.getAttribute('w:val');
    // check if we will accept this family
    if (familyAttr != null) {
      bool acceptFamily = true;
      if (fontFamilyNode != null) {
        acceptFamily =
            options.acceptFontValueWhen?.call(fontFamilyNode, familyAttr) ??
                acceptFamily;
      }
      if (acceptFamily) {
        inlineAttributes['font'] = familyAttr;
      }
    }
    if (sizeAttr != null) {
      bool acceptSize = true;
      String size = sizeAttr;
      if (options.acceptSizeValueWhen != null) {
        acceptSize =
            options.acceptFontValueWhen?.call(fontSizeNode!, familyAttr!) ??
                acceptSize;
      }
      if (acceptSize) {
        // transform if is passed
        if (options.transformSizeValueTo != null) {
          size = options.transformSizeValueTo!(sizeAttr);
        }
        if (size.isNotEmpty) {
          inlineAttributes['size'] = size;
        }
      }
    }
    if (italicNode != null) {
      inlineAttributes['italic'] = true;
    }
    if (boldNode != null) {
      inlineAttributes['italic'] = true;
    }
    if (underlineNode != null) {
      inlineAttributes['underline'] = true;
    }
    if (strikethroughNode != null) {
      inlineAttributes['strikethrough'] = true;
    }
    if (color != null) {
      inlineAttributes['color'] = color;
    }
    if (backgroundColor != null) {
      inlineAttributes['background'] = backgroundColor;
    }
  }

  Map<String, Object>? _buildRelations(xml.XmlDocument? documentRels) {
    if (documentRels == null) return null;
    final elements = documentRels.findAllElements('Relationship');
    final Map<String, Object> relations = {};
    for (final ele in elements) {
      final id = ele.getAttribute('Id')!;
      final target = ele.getAttribute('Target');
      relations[id] = target!;
    }
    return relations;
  }
}
