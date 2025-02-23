import 'package:docx_transformer/docx_transformer.dart';
import 'package:docx_transformer/src/common/default/default_size_to_heading.dart';
import 'package:docx_transformer/src/common/schemas/common_node_keys/xml_keys.dart';
import 'package:docx_transformer/src/common/tab_direction.dart' show TabDirection;
import 'package:docx_transformer/src/constants.dart';
import 'package:docx_transformer/src/util/predicate.dart';
import 'package:xml/xml.dart' as xml;

List<Style> convertXmlStylesToStyles(
  xml.XmlDocument styles,
  ConverterFromXmlContext context,
) {
  final List<Style> result = <Style>[];
  context.shouldParserSizeToHeading ??= defaultSizeToHeading;

  final Iterable<xml.XmlElement> rawStyles = styles.findAllElements('w:style');
  if (rawStyles.isEmpty) return result;
  for (xml.XmlElement styleElement in rawStyles) {
    final String type = styleElement.getAttribute('w:type') ?? '';
    final String styleId = styleElement.getAttribute('w:styleId') ?? '';
    final String relatedWith = styleElement.getElement('w:link')?.getAttribute('w:val') ?? '';
    final String basedOn = styleElement.getElement('w:basedOn')?.getAttribute('w:val') ?? '';
    final String rsId = styleElement.getElement('w:rsId')?.getAttribute('w:val') ?? '';
    final xml.XmlElement? nameElement = styleElement.getElement('w:name');
    final String styleName = nameElement?.getAttribute('w:val') ?? '';
    final xml.XmlElement? paragraphStyle = styleElement.getElement('w:pPr');
    final xml.XmlElement? paragraphLineStyle = styleElement.getElement('w:rPr');

    final List<SubStyles> subStyles = <SubStyles>[];
    final Map<String, dynamic> attributes = <String, dynamic>{};
    final Map<String, Map<String, dynamic>> styleAttrs = <String, Map<String, dynamic>>{};
    styleAttrs['inline'] = <String, dynamic>{};
    styleAttrs['block'] = <String, dynamic>{};
    if (paragraphLineStyle != null) {
      final xml.XmlElement? fontFamilyNode = paragraphLineStyle.getElement(xmlFontsNode);
      final Object? family =
          fontFamilyNode?.getAttribute('w:asciiTheme') ?? fontFamilyNode?.getElement('w:hAnsiTheme');
      final String? sizeNode = paragraphLineStyle.getElement(xmlSizeFontNode)?.getAttribute('w:val');
      final String? color = paragraphLineStyle.getElement(xmlCharacterColorNode)?.getAttribute('w:val');
      final String? backgroundColor =
          paragraphLineStyle.getElement(xmlBackgroundCharacterColorNode)?.getAttribute('w:val');
      final xml.XmlElement? italicNode = paragraphLineStyle.getElement(xmlItalicNode);
      final xml.XmlElement? underlineNode = paragraphLineStyle.getElement(xmlUnderlineNode);
      final xml.XmlElement? boldNode = paragraphLineStyle.getElement(xmlBoldNode);
      final xml.XmlElement? strikeNode = paragraphLineStyle.getElement(xmlStrikethroughNode);
      final String? highlightColor =
          paragraphLineStyle.getElement(xmlHighlightCharacterColorNode)?.getAttribute('w:val');
      if (italicNode != null) {
        styleAttrs['inline']?['italic'] = true;
      }
      if (underlineNode != null) {
        styleAttrs['inline']?['underline'] = true;
      }
      if (boldNode != null) {
        styleAttrs['inline']?['bold'] = true;
      }
      if (strikeNode != null) {
        styleAttrs['inline']?['strikethrough'] = true;
      }
      if (family != null) {
        styleAttrs['inline']?['font'] = family;
      }
      if (color != null) {
        styleAttrs['inline']?['color'] = color;
      }
      if (highlightColor != null) {
        styleAttrs['inline']?['color'] = highlightColor;
      }
      if (backgroundColor != null) {
        styleAttrs['inline']?['background'] = backgroundColor;
      }
      if (sizeNode != null) {
        final int? possibleLevel = context.shouldParserSizeToHeading!(sizeNode);
        if (possibleLevel != null) {
          styleAttrs['block']?['header'] = '$possibleLevel';
        } else {
          styleAttrs['inline']?['size'] = sizeNode;
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
        final String? codeNum = listNode.getElement(xmlListTypeNode)?.getAttribute('w:val');
        final String? numberIndentLevel = listNode.getElement(xmlListIndentLevelNode)!.getAttribute('w:val');
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
          styleAttrs['block']?['align'] = value;
        }
      }

      if (indentNode != null) {
        TabDirection direction = TabDirection.ltr;
        final String? rawLeftIndent = indentNode.getAttribute('w:left');
        final String? rawRightIndent = indentNode.getAttribute('w:right');
        if (rawRightIndent != null) {
          direction = TabDirection.rtl;
        }
        final indent = rawLeftIndent ?? rawRightIndent;
        if (indent != null) {
          final double rawCurrentIndent = double.parse(indent);
          // if the indent is 720 or similar, then will make a division and get correct value
          // for the indent
          //
          // like: 709 / 708 => 1.x
          // or like: 1.418 / 708 => 2.xx
          int indentValue = (rawCurrentIndent / context.defaultTabStop).truncate();
          if (indentValue > 0) {
            // we need to ensure that the indent must be into the range of 1 to 5
            styleAttrs['block']?['indent'] = indentValue.clamp(
              1,
              5,
            );
            if (direction != TabDirection.ltr) {
              styleAttrs['block']?['direction'] = 'rtl';
            }
          }
        }
      }
      if (tabIndentNode != null) {
        TabDirection direction = TabDirection.ltr;
        final String? rawDirectionValue = tabIndentNode.getAttribute('w:val');
        final String? rawTabStop = tabIndentNode.getAttribute('w:pos');
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
          int indentValue = (tabStop / context.defaultTabStop).truncate();
          if (indentValue > 0) {
            // we need to ensure that the indent must be into the range of 1 to 5
            styleAttrs['block']?['indent'] = indentValue.clamp(
              1,
              5,
            );
            if (direction != TabDirection.ltr) {
              styleAttrs['block']?['direction'] = 'rtl';
            }
          }
        }
      }
      if (spacingNode != null) {
        final int? userParse = context.parseXmlSpacing?.call(spacingNode);
        if (userParse != null) {
          styleAttrs['block']?['line-height'] = userParse;
        } else {
          final double? rawLine = double.tryParse(spacingNode.getAttribute('w:line') ?? '');
          if (rawLine != null) {
            final double effectiveSpacing = rawLine / kDefaultSpacing1; 
            if(effectiveSpacing > 0) {
              styleAttrs['block']?['line-height'] = effectiveSpacing; 
            }
          }
        }
      }
    }
    for (xml.XmlElement node in styleElement.children.whereType<xml.XmlElement>()) {
      if (node.name.local == 'name' ||
          node.localName == 'pPr' ||
          node.localName == 'rPr' ||
          node.localName == 'link' ||
          node.localName == 'uiPriority' ||
          node.localName == 'basedOn') {
        continue;
      }

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
      Style(
        id: rsId.isEmpty ? null : rsId,
        type: type,
        relatedWith: relatedWith,
        basedOn: basedOn,
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
  final double defaultTabStop;

  ConverterFromXmlContext({
    this.shouldParserSizeToHeading,
    this.parseXmlSpacing,
    required this.defaultTabStop,
  });
}
