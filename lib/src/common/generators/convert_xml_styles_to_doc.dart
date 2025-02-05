import 'package:flutter/foundation.dart';
import 'package:quill_delta_docx_parser/quill_delta_docx_parser.dart';
import 'package:quill_delta_docx_parser/src/common/default/default_size_to_heading.dart';
import 'package:quill_delta_docx_parser/src/util/predicate.dart';
import 'package:xml/xml.dart' as xml;

List<Styles> convertXmlStylesToStyles(
    xml.XmlDocument styles, ParseSizeToHeadingCallback? shouldParserSizeToHeading) {
  final result = <Styles>[];
  shouldParserSizeToHeading ??= defaultSizeToHeading;

  final rawStyles = styles.findAllElements('w:style');
  if (rawStyles.isEmpty) return result;
  for (var styleElement in rawStyles) {
    final type = styleElement.getAttribute('w:type') ?? '';
    final styleId = styleElement.getAttribute('w:styleId') ?? '';
    final nameElement = styleElement.getElement('w:name');
    final styleName = nameElement?.getAttribute('w:val') ?? '';
    final paragraphStyle = styleElement.getElement('w:pPr');
    final paragraphLineStyle = styleElement.getElement('w:rPr');
    if (styleId == '624') {
      debugPrint(styleElement.toXmlString(pretty: true));
    }

    final subStyles = <SubStyles>[];
    final attributes = <String, dynamic>{};
    final styleAttrs = <String, dynamic>{};
    styleAttrs['inline'] = {};
    styleAttrs['block'] = {};
    if (paragraphLineStyle != null) {
      final fontFamilyNode = paragraphLineStyle.getElement(xmlFontsNode);
      final family = fontFamilyNode?.getAttribute('w:asciiTheme') ?? fontFamilyNode?.getElement('w:hAnsiTheme');
      final sizeNode = paragraphLineStyle.getElement(xmlSizeFontNode)?.getAttribute('w:val');
      final color = paragraphLineStyle.getElement(xmlCharacterColorNode)?.getAttribute('w:val');
      final backgroundColor =
          paragraphLineStyle.getElement(xmlBackgroundCharacterColorNode)?.getAttribute('w:val');
      final italicNode = paragraphLineStyle.getElement(xmlItalicNode);
      final underlineNode = paragraphLineStyle.getElement(xmlUnderlineNode);
      final boldNode = paragraphLineStyle.getElement(xmlBoldNode);
      final strikeNode = paragraphLineStyle.getElement(xmlStrikethroughNode);
      final highlightColor = paragraphLineStyle.getElement(xmlHighlightCharacterColorNode)?.getAttribute('w:val');
      if (italicNode != null) {
        styleAttrs['inline']['italic'] = true;
      }
      if (underlineNode != null) {
        styleAttrs['inline']['underline'] = true;
      }
      if (boldNode != null) {
        styleAttrs['inline']['bold'] = true;
      }
      if (strikeNode != null) {
        styleAttrs['inline']['strikethrough'] = true;
      }
      if (family != null) {
        styleAttrs['inline']['font'] = family;
      }
      if (color != null) {
        styleAttrs['inline']['color'] = color;
      }
      if (highlightColor != null) {
        styleAttrs['inline']['color'] = highlightColor;
      }
      if (backgroundColor != null) {
        styleAttrs['inline']['background'] = backgroundColor;
      }
      if (sizeNode != null) {
        final int? possibleLevel = shouldParserSizeToHeading(sizeNode);
        if (possibleLevel != null) {
          styleAttrs['block']['header'] = possibleLevel;
        } else {
          styleAttrs['inline']['size'] = sizeNode;
        }
      }
    }
    if (paragraphStyle != null) {
      var listNode = paragraphStyle.getElement(xmlListNode);
      var indentNode = paragraphStyle.getElement(xmlTabNode) ?? paragraphStyle.getElement(xmlIndentNode);
      var alignNode = paragraphStyle.getElement(xmlAlignmentNode);
      var spacingNode = paragraphStyle.getElement(xmlSpacingNode);

      if (alignNode != null) {
        final value = alignNode.getAttribute('w:val');
        if (value != null) {
          styleAttrs['block']['align'] = value;
        }
      }
      if (indentNode != null) {}
      if (spacingNode != null) {}

      if (listNode != null) {
        final codeNum = listNode.getElement(xmlListTypeNode)?.getAttribute('w:val');
        final numberIndentLevel = listNode.getElement(xmlListIndentLevelNode)!.getAttribute('w:val');
        if (codeNum != null && (codeNum == '2' || codeNum == '3')) {
          styleAttrs['block']?['list'] = codeNum == '2' ? 'bullet' : 'ordered';
        }
        if (numberIndentLevel != null) {
          final indent = int.tryParse(numberIndentLevel);
          if (indent != null && indent > 0) {
            styleAttrs['block']?['indent'] = indent;
          }
        }
      }
    }
    for (var node in styleElement.children.whereType<xml.XmlElement>()) {
      if (node.name.local == 'name' || node.localName == 'pPr' || node.localName == 'rPr') continue;

      for (var attr in node.attributes) {
        attributes[attr.name.local] = attr.value;
      }

      subStyles.add(
        SubStyles(
          propertyName: node.name.local,
          value: null,
          extraInfo: attributes.isNotEmpty ? {...attributes} : null,
        ),
      );
      attributes.clear();
    }

    result.add(
      Styles(
        type: type,
        styleId: styleId,
        styleName: styleName,
        subStyles: subStyles,
        extra: styleAttrs.isEmpty ? null : styleAttrs,
      ),
    );
  }
  return result;
}
