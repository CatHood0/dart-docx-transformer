import 'package:docx_transformer/docx_transformer.dart';
import 'package:docx_transformer/src/common/default/default_size_to_heading.dart';
import 'package:docx_transformer/src/util/predicate.dart';
import 'package:xml/xml.dart' as xml;

const _maxLeftValue = 5000;

final _defaultSpacings = Map<double, double>.unmodifiable(<double, double>{
  12.0: 1.0,
  18.0: 1.5,
  24: 2.0,
});

List<Styles> convertXmlStylesToStyles(
  xml.XmlDocument styles,
  ConverterFromXmlContext context,
) {
  final List<Styles> result = <Styles>[];
  context.shouldParserSizeToHeading ??= defaultSizeToHeading;

  final Iterable<xml.XmlElement> rawStyles = styles.findAllElements('w:style');
  if (rawStyles.isEmpty) return result;
  for (xml.XmlElement styleElement in rawStyles) {
    final String type = styleElement.getAttribute('w:type') ?? '';
    final String styleId = styleElement.getAttribute('w:styleId') ?? '';
    final String relatedWith =
        styleElement.getElement('w:link')?.getAttribute('w:val') ?? '';
    final String baseOn =
        styleElement.getElement('w:basedOn')?.getAttribute('w:val') ?? '';
    final String rsId =
        styleElement.getElement('w:rsId')?.getAttribute('w:val') ?? '';
    final xml.XmlElement? nameElement = styleElement.getElement('w:name');
    final String styleName = nameElement?.getAttribute('w:val') ?? '';
    final xml.XmlElement? paragraphStyle = styleElement.getElement('w:pPr');
    final xml.XmlElement? paragraphLineStyle = styleElement.getElement('w:rPr');

    final List<SubStyles> subStyles = <SubStyles>[];
    final Map<String, dynamic> attributes = <String, dynamic>{};
    final Map<String, dynamic> styleAttrs = <String, dynamic>{};
    styleAttrs['inline'] = <String, dynamic>{};
    styleAttrs['block'] = <String, dynamic>{};
    if (paragraphLineStyle != null) {
      final xml.XmlElement? fontFamilyNode =
          paragraphLineStyle.getElement(xmlFontsNode);
      final Object? family = fontFamilyNode?.getAttribute('w:asciiTheme') ??
          fontFamilyNode?.getElement('w:hAnsiTheme');
      final String? sizeNode =
          paragraphLineStyle.getElement(xmlSizeFontNode)?.getAttribute('w:val');
      final String? color = paragraphLineStyle
          .getElement(xmlCharacterColorNode)
          ?.getAttribute('w:val');
      final String? backgroundColor = paragraphLineStyle
          .getElement(xmlBackgroundCharacterColorNode)
          ?.getAttribute('w:val');
      final xml.XmlElement? italicNode =
          paragraphLineStyle.getElement(xmlItalicNode);
      final xml.XmlElement? underlineNode =
          paragraphLineStyle.getElement(xmlUnderlineNode);
      final xml.XmlElement? boldNode =
          paragraphLineStyle.getElement(xmlBoldNode);
      final xml.XmlElement? strikeNode =
          paragraphLineStyle.getElement(xmlStrikethroughNode);
      final String? highlightColor = paragraphLineStyle
          .getElement(xmlHighlightCharacterColorNode)
          ?.getAttribute('w:val');
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
        final int? possibleLevel = context.shouldParserSizeToHeading!(sizeNode);
        if (possibleLevel != null) {
          styleAttrs['block']['header'] = '$possibleLevel';
        } else {
          styleAttrs['inline']['size'] = sizeNode;
        }
      }
    }
    if (paragraphStyle != null) {
      xml.XmlElement? listNode = paragraphStyle.getElement(xmlListNode);
      xml.XmlElement? indentNode = paragraphStyle.getElement(xmlIndentNode);
      xml.XmlElement? tabIndentNode = paragraphStyle.getElement(xmlTabNode);
      xml.XmlElement? alignNode = paragraphStyle.getElement(xmlAlignmentNode);
      xml.XmlElement? spacingNode = paragraphStyle.getElement(xmlSpacingNode);

      if (listNode != null) {
        final String? codeNum =
            listNode.getElement(xmlListTypeNode)?.getAttribute('w:val');
        final String? numberIndentLevel =
            listNode.getElement(xmlListIndentLevelNode)!.getAttribute('w:val');
        if (codeNum != null && (codeNum == '2' || codeNum == '3')) {
          styleAttrs['block']?['list'] = codeNum == '2' ? 'bullet' : 'ordered';
        }
        if (numberIndentLevel != null) {
          final int? indent = int.tryParse(numberIndentLevel);
          if (indent != null && indent > 0) {
            styleAttrs['block']?['indent'] = indent;
          }
        }
      }

      if (alignNode != null) {
        final String? value = alignNode.getAttribute('w:val');
        if (value != null) {
          styleAttrs['block']['align'] = value;
        }
      }

      if (indentNode != null) {
        final rawIndentValue = indentNode.getAttribute('w:left');
        // if contains a value, then we can calculate something
        if (rawIndentValue != null) {
          final indentValueNum = double.tryParse(rawIndentValue);
          final effectiveIndentValue =
              ((indentValueNum ?? 0) / _maxLeftValue).floor();
          if (effectiveIndentValue > 0) {
            styleAttrs['block']['indent'] = effectiveIndentValue;
          }
        }
      }
      if (tabIndentNode != null) {}
      if (spacingNode != null) {
        final String? sizeAttr = paragraphLineStyle
            ?.getElement(xmlSizeFontNode)
            ?.getAttribute('w:val');
        if (sizeAttr != null) {
          final int sizeNumber = int.tryParse(sizeAttr)!;
          final int? afterSpacing =
              int.tryParse(spacingNode.getAttribute('w:after') ?? '');
          if (afterSpacing != null && afterSpacing > 0) {
            final double effectiveSizePoint = sizeNumber / 2;
            final double effectiveSpacing = afterSpacing / 20;
            final double spacing =
                (effectiveSpacing / effectiveSizePoint).floorToDouble();
            if (spacing > 0.0) {
              styleAttrs['block']?['line-height'] = spacing;
            }
          }
        } else {
          final int? afterSpacing =
              int.tryParse(spacingNode.getAttribute('w:after') ?? '');
          if (afterSpacing != null && afterSpacing > 0) {
            final double effectiveSpacing = afterSpacing / 20;
            final double? spacing = _defaultSpacings[effectiveSpacing];
            if (spacing != null) {
              styleAttrs['block']?['line-height'] = spacing;
            }
          }
        }
      }
    }
    for (xml.XmlElement node
        in styleElement.children.whereType<xml.XmlElement>()) {
      if (node.name.local == 'name' ||
          node.localName == 'pPr' ||
          node.localName == 'rPr' ||
          node.localName == 'link' ||
          node.localName == 'uiPriority' ||
          node.localName == 'baseOn') continue;

      for (xml.XmlAttribute attr in node.attributes) {
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
        id: rsId.isEmpty ? null : rsId,
        type: type,
        relatedWith: relatedWith,
        baseOn: baseOn,
        styleId: styleId,
        styleName: styleName,
        subStyles: subStyles,
        block: styleAttrs['block'] as Map<String, dynamic>,
        inline: styleAttrs['inline'] as Map<String, dynamic>,
        extra: null,
      ),
    );
  }
  return result;
}

class ConverterFromXmlContext {
  ParseSizeToHeadingCallback? shouldParserSizeToHeading;
  ParseXmlSpacingCallback? parseXmlSpacing;

  ConverterFromXmlContext({
    this.shouldParserSizeToHeading,
    this.parseXmlSpacing,
  });
}
