import 'package:xml/xml.dart' as xml;

import '../../../docx_transformer.dart';
import '../../constants.dart';
import '../../util/predicate.dart';
import '../color.dart';
import '../default/default_size_to_heading.dart';
import '../extensions/string_ext.dart';
import '../schemas/common_node_keys/xml_keys.dart';
import '../tab_direction.dart' show TabDirection;

List<Style> convertXmlStylesToStyles(
  xml.XmlDocument styles,
  ConverterFromXmlContext context, {
  bool computeIndents = false,
}) {
  final List<Style> result = <Style>[];
  context.shouldParserSizeToHeading ??= defaultSizeToHeading;
  context.checkColor ??= isValidColor;

  final Iterable<xml.XmlElement> rawStyles = styles.findAllElements('w:style');
  if (rawStyles.isEmpty) return result;
  for (final xml.XmlElement styleElement in rawStyles) {
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
      final String? family =
          fontFamilyNode?.getAttribute('w:asciiTheme') ?? fontFamilyNode?.getElement('w:hAnsiTheme') as String?;
      final xml.XmlElement? sizeNode = paragraphLineStyle.getElement(xmlSizeFontNode);
      final String? color = paragraphLineStyle.getElement(xmlCharacterColorNode)?.getAttribute('w:val');
      final String? backgroundColor =
          paragraphLineStyle.getElement(xmlBackgroundCharacterColorNode)?.getAttribute('w:val');
      final xml.XmlElement? italicNode = paragraphLineStyle.getElement(xmlItalicNode);
      final xml.XmlElement? underlineNode = paragraphLineStyle.getElement(xmlUnderlineNode);
      final xml.XmlElement? boldNode = paragraphLineStyle.getElement(xmlBoldNode);
      final xml.XmlElement? strikeNode = paragraphLineStyle.getElement(xmlStrikethroughNode);
      // script
      final xml.XmlElement? scriptNode = paragraphLineStyle.getElement(xmlScriptNode);
      final String? scriptValue = scriptNode?.getAttribute('w:val');
      final String? highlightColor =
          paragraphLineStyle.getElement(xmlHighlightCharacterColorNode)?.getAttribute('w:val');
      final String? sizeAttr = sizeNode?.getAttribute('w:val');
      if (italicNode != null && italicNode.localName == 'i') {
        styleAttrs['inline']?['italic'] = true;
      }
      if (underlineNode != null && underlineNode.localName == 'u') {
        styleAttrs['inline']?['underline'] = true;
      }
      if (boldNode != null && boldNode.localName == 'u') {
        styleAttrs['inline']?['bold'] = true;
      }
      if (strikeNode != null) {
        if (strikeNode.getAttribute('w:val') == null) {
          styleAttrs['inline']?['strikethrough'] = true;
        }
      }
      if (scriptValue != null) {
        if (scriptValue != 'baseline') {
          styleAttrs['inline']?['script'] = scriptValue;
        }
      }
      if (family != null) {
        final bool acceptFamily = context.acceptFontValueWhen?.call(fontFamilyNode!, family) ?? true;
        if (acceptFamily) {
          styleAttrs['inline']?['font'] = family;
        }
      }
      if (color != null) {
        final bool shouldAcceptColor = context.checkColor!.call(color);
        if (!shouldAcceptColor && !context.ignoreColorWhenNoSupported) {
          throw Exception(
            'The color with the value: $color is not supported currently. '
            'You could consider use checkColor() param from the context',
          );
        }
        if (shouldAcceptColor) {
          if (context.colorBuilder == null) {
            styleAttrs['inline']?['color'] = color.startsWith('#') ? color : '#$color'.toUpperCase();
          } else if (context.colorBuilder != null) {
            final String? newColorV = context.colorBuilder!.call(color);
            if (newColorV != null && newColorV.trim().isNotEmpty) {
              styleAttrs['inline']?['color'] =
                  newColorV.startsWith('#') ? newColorV.toUpperCase() : '#$newColorV'.toUpperCase();
            }
          }
        }
      }
      if (highlightColor != null) {
        styleAttrs['inline']?['color'] = highlightColor;
      }
      if (backgroundColor != null) {
        final bool shouldAcceptColor =
            context.checkColor?.call(backgroundColor) ?? isValidColor(backgroundColor.toUpperCase());
        if (!shouldAcceptColor && !context.ignoreColorWhenNoSupported) {
          throw Exception(
            'The color with the value: $backgroundColor is not supported currently. '
            'You could consider use checkColor() param from the options',
          );
        }
        if (shouldAcceptColor) {
          if (context.colorBuilder == null) {
            styleAttrs['inline']?['background'] = backgroundColor.startsWith('#')
                ? backgroundColor.toUpperCase()
                : '#$backgroundColor'.toUpperCase();
          } else if (context.colorBuilder != null) {
            final String? newColorV = context.colorBuilder?.call(backgroundColor);
            if (newColorV != null && newColorV.trim().isNotEmpty) {
              styleAttrs['inline']?['background'] =
                  newColorV.startsWith('#') ? newColorV.toUpperCase() : '#$newColorV'.toUpperCase();
            }
          }
        }
      }
      if (sizeAttr != null) {
        bool acceptSize = true;
        final String size = sizeAttr.toString();
        if (context.acceptSizeValueWhen != null) {
          acceptSize = context.acceptSizeValueWhen?.call(sizeNode!, size) ?? acceptSize;
        }
        if (acceptSize) {
          final int? possibleLevel = context.shouldParserSizeToHeading!(sizeAttr);
          if (possibleLevel != null) {
            styleAttrs['block']?['header'] = '$possibleLevel';
          } else {
            styleAttrs['inline']?['size'] = sizeNode;
          }
        }
      }
    }
    if (paragraphStyle != null) {
      final xml.XmlElement? listNode = paragraphStyle.getElement(xmlListNode);
      final xml.XmlElement? indentNode = paragraphStyle.getElement(xmlIndentNode);
      final xml.XmlElement? tabIndentNode = paragraphStyle.getElement(xmlTabNode);
      final xml.XmlElement? alignNode = paragraphStyle.getElement(xmlAlignmentNode);
      final xml.XmlElement? spacingNode = paragraphStyle.getElement(xmlSpacingNode);

      if (listNode != null) {
        final String? codeNum = listNode.getElement(xmlListTypeNode)?.getAttribute('w:val');
        final String? numberIndentLevel = listNode.getElement(xmlListIndentLevelNode)!.getAttribute('w:val');
        if (codeNum != null && (codeNum == '2' || codeNum == '3')) {
          styleAttrs['block']?['list'] = codeNum == '2' ? 'bullet' : 'ordered';
        }
        if (numberIndentLevel != null) {
          final int indent = int.tryParse(numberIndentLevel.isEmpty ? '0' : numberIndentLevel) ?? 0;
          if (indent > 0) {
            styleAttrs['block']?['indent'] = indent;
          }
        }
      }

      if (alignNode != null) {
        final String? align = alignNode.getAttribute('w:val');
        if (align != null) {
          // we add "both", because option, because in docx documents, "both" align is equivalent to justify alignment
          assert(
              align.isAlignStr,
              'Quill Delta only supports: right, left, center and justify alignments. '
              'The value of type: "$align" is not supported');
          styleAttrs['block']?['align'] = align.toFixedAlignStr();
        }
      }

      if (computeIndents) {
        if (indentNode != null) {
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
            final int indentValue = (rawCurrentIndent / context.defaultTabStop).truncate();
            if (indentValue.floor() > 0) {
              // we need to ensure that the indent must be into the range of 1 to 5
              styleAttrs['block']?['indent'] = indentValue.floor();
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
            final int indentValue = (tabStop / context.defaultTabStop).truncate();
            if (indentValue.floor() > 0) {
              // we need to ensure that the indent must be into the range of 1 to 5
              styleAttrs['block']?['indent'] = indentValue.floor();
              if (direction != TabDirection.ltr) {
                styleAttrs['block']?['direction'] = 'rtl';
              }
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
            if (effectiveSpacing > 0) {
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
          extraInfo: attributes.isNotEmpty ? <String, dynamic>{...attributes} : null,
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
  ConverterFromXmlContext({
    required this.ignoreColorWhenNoSupported,
    required this.defaultTabStop,
    this.acceptFontValueWhen,
    this.acceptSizeValueWhen,
    this.acceptSpacingValueWhen,
    this.shouldParserSizeToHeading,
    this.parseXmlSpacing,
    this.colorBuilder,
    this.checkColor,
  });

  ParseSizeToHeadingCallback? shouldParserSizeToHeading;
  ParseXmlSpacingCallback? parseXmlSpacing;
  bool Function(String? hex)? checkColor;
  final Predicate<String>? acceptFontValueWhen;
  final Predicate<String>? acceptSizeValueWhen;
  final Predicate<int>? acceptSpacingValueWhen;
  final bool ignoreColorWhenNoSupported;
  final String? Function(String? hex)? colorBuilder;
  final double defaultTabStop;
}
