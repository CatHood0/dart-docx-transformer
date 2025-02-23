import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:docx_transformer/docx_transformer.dart';
import 'package:docx_transformer/src/common/generators/convert_xml_styles_to_doc.dart';
import 'package:docx_transformer/src/common/schemas/common_node_keys/word_files_common.dart';
import 'package:docx_transformer/src/common/schemas/common_node_keys/xml_keys.dart';
import 'package:docx_transformer/src/common/tab_direction.dart' show TabDirection;
import 'package:docx_transformer/src/constants.dart';
import 'package:docx_transformer/src/parser/parser.dart';
import 'package:flutter/foundation.dart';
import 'package:xml/src/xml/utils/node_list.dart';
import 'package:xml/xml.dart' as xml;

class DocxToDelta extends Parser<Uint8List, Future<Delta?>?, DeltaParserOptions> {
  ZipDecoder? _zipDecoder;
  DocxToDelta({
    required super.data,
    required super.options,
  });

  @override
  Future<Delta?>? build() async {
    Delta delta = Delta();
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
    Map<String, Object> rawMedia = <String, Object>{};

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
      throw StateError('$documentFilePath couldn\'t be founded into the File passed');
    }

    _buildTabMultiplierIfNeeded(settings);

    // cache ops
    // correspond => {rId: link}
    final Map<String, Object> documentRelations = _buildRelations(documentRels) ?? <String, Object>{};
    final DocumentStylesSheet docStyles = DocumentStylesSheet.fromStyles(
      styles!,
      ConverterFromXmlContext(
        shouldParserSizeToHeading: options.shouldParserSizeToHeading,
        parseXmlSpacing: options.parseXmlSpacing,
        defaultTabStop: _kDefaultTabStop,
      ),
    );

    final Iterable<xml.XmlElement> paragraphNodes = document.findAllElements(xmlParagraphNode);

    for (final xml.XmlElement paragraph in paragraphNodes) {
      // common parents nodes
      final xml.XmlElement? paragraphLevelAttributesNode = paragraph.getElement(xmlParagraphBlockAttrsNode);
      // <w:rPr> node could be into <w:pPr> since this last one correspond to the common attributes
      // applied to the entire paragraph (<w:p>)
      final xml.XmlElement? commonInlineParagraphAttributes =
          paragraphLevelAttributesNode?.getElement(xmlParagraphInlineAttsrNode);
      Map<String, dynamic> blockAttributes = <String, dynamic>{};
      // these are the attributes that probably will be applied to a part of the text
      Map<String, dynamic> inlineAttributes = <String, dynamic>{};
      // these are the attributes that will be applied to the entire characters of the paragraph
      Map<String, dynamic> paragraphInlineAttributes = <String, dynamic>{};
      // Getting the w:pStyle, we can the styleId that is stored into styles.xml
      //
      // then, we already have the styles parsed to a human readable class, we can get the specific
      // style by the id passed
      xml.XmlElement? paragraphStyle = paragraphLevelAttributesNode?.getElement(xmlpStyleNode);
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
      xml.XmlElement? listNode = paragraphLevelAttributesNode?.getElement(xmlListNode);
      xml.XmlElement? tabNode =
          paragraphLevelAttributesNode?.getElement(xmlTabNode)?.getElement(xmlValueTabNode) ??
              paragraphLevelAttributesNode?.getElement(xmlValueTabNode);
      xml.XmlElement? indentNode = paragraphLevelAttributesNode?.getElement(xmlIndentNode);
      xml.XmlElement? alignNode = paragraphLevelAttributesNode?.getElement(xmlAlignmentNode);
      xml.XmlElement? spacingNode = paragraphLevelAttributesNode?.getElement(xmlSpacingNode);
      xml.XmlElement? borderNode = paragraphLevelAttributesNode?.getElement(xmlBorderNode);

      final List<xml.XmlNode> textPartNodes = List.from(paragraph.children)
        ..removeWhere((xml.XmlNode node) =>
            node is xml.XmlElement && (node.localName == 'pPr' || node.localName == 'proofErr'));
      // if the textPartNodes are empty we will need to ignore the paragraph
      // because it is only a new line
      if (textPartNodes.isEmpty) {
        _buildBlockAttributes(
          tabNode,
          indentNode,
          alignNode,
          listNode,
          spacingNode,
          borderNode,
          blockAttributes,
        );
        if (blockAttributes.isNotEmpty) {
          blockAttributes.remove('blockquote');
          delta.insert('\n', blockAttributes);
          continue;
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
          _buildInsertionPart(
            inlineAttributes,
            paragraphInlineAttributes,
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
          paragraphInlineAttributes,
          commonInlineParagraphAttributes,
          textPartNode,
          delta,
          documentRelations,
          rawMedia,
        );
      }
      _buildBlockAttributes(
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
        continue;
      }
      delta.insert('\n');
    }

    return delta.isEmpty ? null : delta;
  }

  void _buildInsertionPart(
    Map<String, dynamic> inlineAttributes,
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
            final Object? url = await options.onDetectImage.call(bytes, imagePath.replaceFirst(r'.*\/', ''));
            if (url != null) {
              assert(url is String, 'Embed Images only accept "String" type');
              delta.insert(<String, Object>{'image': url});
              inlineAttributes.clear();
              return;
            }
          }
        }
      }
    }
    final xml.XmlElement? inlineAttributesOfPart = node.getElement(xmlParagraphInlineAttsrNode);
    bool hasInlineAttrs = inlineAttributesOfPart != null || commonInlineParagraphAttributes != null;
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
            ? paragraphInlineAttributes.isEmpty
                ? null
                : paragraphInlineAttributes
            : <String, dynamic>{...inlineAttributes, ...paragraphInlineAttributes});
    inlineAttributes.clear();
  }

  void _buildInlineAttributes(
    xml.XmlElement? paragraphAttributes,
    xml.XmlElement? lineAttributes,
    Map<String, dynamic> inlineAttributes,
  ) {
    // family
    final xml.XmlElement? fontFamilyNode =
        lineAttributes?.getElement(xmlFontsNode) ?? paragraphAttributes?.getElement(xmlFontsNode);
    final xml.XmlElement? fontSizeNode =
        lineAttributes?.getElement(xmlFontsNode) ?? paragraphAttributes?.getElement(xmlFontsNode);
    // italic
    final xml.XmlElement? italicNode =
        (lineAttributes?.getElement(xmlItalicNode) ?? lineAttributes?.getElement(xmlItalicNode)) ??
            (paragraphAttributes?.getElement(xmlItalicNode) ?? paragraphAttributes?.getElement(xmlItalicNode));
    // bold
    paragraphAttributes?.getElement(xmlItalicNode);
    final xml.XmlElement? boldNode =
        (lineAttributes?.getElement(xmlBoldNode) ?? lineAttributes?.getElement(xmlBoldCsNode)) ??
            (paragraphAttributes?.getElement(xmlBoldNode) ?? paragraphAttributes?.getElement(xmlBoldCsNode));
    // underline
    final xml.XmlElement? underlineNode =
        lineAttributes?.getElement(xmlUnderlineNode) ?? paragraphAttributes?.getElement(xmlUnderlineNode);
    // script
    final xml.XmlElement? scriptNode =
        lineAttributes?.getElement(xmlScriptNode) ?? paragraphAttributes?.getElement(xmlScriptNode);
    // strike
    final xml.XmlElement? strikethroughNode =
        lineAttributes?.getElement(xmlStrikethroughNode) ?? paragraphAttributes?.getElement(xmlStrikethroughNode);
    // text color
    final xml.XmlElement? colorNode = lineAttributes?.getElement(xmlCharacterColorNode) ??
        paragraphAttributes?.getElement(xmlCharacterColorNode);
    // background color
    final xml.XmlElement? backgroundColorNode = lineAttributes?.getElement(xmlBackgroundCharacterColorNode) ??
        paragraphAttributes?.getElement(xmlBackgroundCharacterColorNode);
    // nodes values
    final String? sizeAttr =
        fontSizeNode?.getAttribute(xmlSizeFontNode) ?? fontSizeNode?.getAttribute(xmlSizeCsFontNode);
    final String? familyAttr = fontFamilyNode?.getAttribute('asciiTheme');
    final String? color = colorNode?.getAttribute('w:val');
    final String? backgroundColor = backgroundColorNode?.getAttribute('w:val');
    final String? scriptValue = scriptNode?.getAttribute('w:val');
    // check if we will accept this family
    if (familyAttr != null && fontFamilyNode != null) {
      bool acceptFamily = options.acceptFontValueWhen?.call(fontFamilyNode, familyAttr) ?? false;
      if (acceptFamily) {
        inlineAttributes['font'] = familyAttr;
      }
    }
    if (sizeAttr != null) {
      bool acceptSize = true;
      String size = sizeAttr;
      if (options.acceptSizeValueWhen != null) {
        acceptSize = options.acceptSizeValueWhen?.call(fontSizeNode!, size) ?? acceptSize;
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
      if (strikethroughNode.getAttribute('w:val') == null) {
        inlineAttributes['strikethrough'] = true;
      }
    }
    if (scriptValue != null) {
      if (scriptValue != 'baseline') {
        inlineAttributes['script'] = scriptValue;
      }
    }
    if (color != null) {
      inlineAttributes['color'] = color;
    }
    if (backgroundColor != null) {
      inlineAttributes['background'] = backgroundColor;
    }
  }

  void _buildBlockAttributes(
    xml.XmlElement? tabNode,
    xml.XmlElement? indentNode,
    xml.XmlElement? alignNode,
    xml.XmlElement? listNode,
    xml.XmlElement? spacingNode,
    xml.XmlElement? borderNode,
    Map<String, dynamic> blockAttributes,
  ) {
    final bool isList = listNode != null;
    final bool containsTabNode = tabNode != null;
    final bool containsIndentNode = indentNode != null;
    final bool containsAlignment = alignNode != null;
    final bool containsSpacing = spacingNode != null;
    final bool containsBorder = borderNode != null;
    if (containsTabNode) {
      TabDirection direction = TabDirection.ltr;
      final String? rawDirectionValue = tabNode.getAttribute('w:val');
      final String? rawTabStop = tabNode.getAttribute('w:pos');
      if (rawTabStop != null) {
        if (rawDirectionValue != null && rawDirectionValue != 'left') {
          direction = rawDirectionValue == 'right' ? TabDirection.rtl : TabDirection.ltr;
        }
        final double tabStop = double.parse(rawTabStop);
        // if the tabStop is 720, then will make a division and get correct value
        // for the indent
        //
        // like: 720 / 720 => 1
        // or like: 1.440 / 720 => 2
        int indentValue = (tabStop / _kDefaultTabStop).truncate();
        if (indentValue > 0) {
          final bool shouldAcceptSpacing = options.acceptSpacingValueWhen?.call(tabNode, indentValue) ?? true;
          if (shouldAcceptSpacing) {
            // we need to ensure that the indent must be into the range of 1 to 5
            blockAttributes['indent'] = indentValue.clamp(
              1,
              5,
            );
            if (direction != TabDirection.ltr) {
              blockAttributes['direction'] = 'rtl';
            }
          }
        }
      }
    }
    if (!containsTabNode && containsIndentNode) {
      TabDirection direction = TabDirection.ltr;
      final String? rawLeftIndent = indentNode.getAttribute('w:left');
      final String? rawRightIndent = indentNode.getAttribute('w:right');
      if (rawRightIndent != null) {
        direction = TabDirection.rtl;
      }
      final String? indent = rawLeftIndent ?? rawRightIndent;
      if (indent != null) {
        final double rawCurrentIndent = double.parse(indent);
        // if the indent is 720 or similar, then will make a division and get correct value
        // for the indent
        //
        // like: 709 / 708 => 1.x
        // or like: 1.418 / 708 => 2.xx
        int indentValue = (rawCurrentIndent / _kDefaultTabStop).truncate();
        if (indentValue > 0) {
          final bool shouldAcceptSpacing = options.acceptSpacingValueWhen?.call(tabNode!, indentValue) ?? true;
          if (shouldAcceptSpacing) {
            // we need to ensure that the indent must be into the range of 1 to 5
            blockAttributes['indent'] = indentValue.clamp(
              1,
              5,
            );
            if (direction != TabDirection.ltr) {
              blockAttributes['direction'] = 'rtl';
            }
          }
        }
      }
    }
    if (containsAlignment) {
      final String? align = alignNode.getAttribute('w:val');
      if (align != null) {
        assert(
          align == 'left' || align == 'right' || align == 'center' || align == 'justify',
          'Quill Delta only supports: right, left, center and justify alignments',
        );
        blockAttributes['align'] = align;
      }
    }
    if (containsBorder) {
      final XmlNodeList<xml.XmlNode> children = borderNode.children;
      for (final child in children) {
        if (child is xml.XmlElement) {
          if (child.localName == 'left') {
            final String? typeBorder = child.getAttribute('w:val');
            if (typeBorder == 'single') {
              blockAttributes['blockquote'] = true;
              break;
            }
          }
          // if the other border sides are defined
          // we need to avoid adding blockquote since
          // does not match with the style that we expect
          if (child.localName == 'right' ||
              child.localName == 'top' ||
              child.localName == 'bottom' ||
              child.localName == 'between') {
            final String? typeBorder = child.getAttribute('w:val');
            if (typeBorder != 'none') {
              blockAttributes.remove('blockquote');
              break;
            }
          }
        }
      }
    }
    if (containsSpacing) {
      final int? userParse = options.parseXmlSpacing?.call(spacingNode);
      if (userParse != null) {
        blockAttributes['line-height'] = userParse;
      } else {
        final double? rawLine = double.tryParse(spacingNode.getAttribute('w:line') ?? '');
        if (rawLine != null) {
          double effectiveSpacing = rawLine / kDefaultSpacing1;
          if (effectiveSpacing > 1.0 && effectiveSpacing < 1.50) {
            effectiveSpacing = 1.0;
          } else if (effectiveSpacing > 1.5 && effectiveSpacing < 2.0) {
            effectiveSpacing = 1.5;
          } else if (effectiveSpacing > 2.0) {
            effectiveSpacing = 2.0;
          }
          if (effectiveSpacing > 0) {
            blockAttributes['line-height'] = effectiveSpacing;
          }
        }
      }
    }
    if (isList) {
      final String? codeNum = listNode.getElement(xmlListTypeNode)!.getAttribute('w:val');
      final String? numberIndentLevel = listNode.getElement(xmlListIndentLevelNode)!.getAttribute('w:val');
      if (codeNum != null && (codeNum == '2' || codeNum == '3')) {
        blockAttributes['list'] = codeNum == '2' ? 'bullet' : 'ordered';
      }
      if (numberIndentLevel != null) {
        final int? indent = int.tryParse(numberIndentLevel);
        if (indent != null && indent > 0) {
          blockAttributes['indent'] = indent;
        }
      }
    }
  }

  Map<String, Object>? _buildRelations(xml.XmlDocument? documentRels) {
    if (documentRels == null) return null;
    final Iterable<xml.XmlElement> elements = documentRels.findAllElements('Relationship');
    final Map<String, Object> relations = <String, Object>{};
    for (final xml.XmlElement ele in elements) {
      final String id = ele.getAttribute('Id')!;
      final String? target = ele.getAttribute('Target');
      relations[id] = target!;
    }
    return relations;
  }

  void _buildTabMultiplierIfNeeded(xml.XmlDocument? settings) {
    final xml.XmlElement? tabNodeSettings = settings?.findAllElements('w:defaultTabStop').firstOrNull;
    final String? tabStopValue = tabNodeSettings?.getAttribute('w:val');
    if (settings == null || tabNodeSettings == null || tabStopValue == null) return;
    final double? numTab = double.tryParse(tabStopValue);
    // we need to update the multiplier if needed
    if (numTab != null) {
      _kDefaultTabStop = numTab;
    }
  }
}

// every 720 tab value, means 1 level of the indentation
//
// we need to take in account that we need to check settings.xml
// where contains this value (could be different and we need to check it)
double _kDefaultTabStop = 720;
