import 'package:meta/meta.dart';
import 'package:xml/src/xml/utils/node_list.dart';
import 'package:xml/xml.dart' as xml;
import '../../docx_transformer.dart';
import '../common/color.dart';
import '../common/extensions/string_ext.dart';
import '../common/internals_vars.dart';
import '../common/schemas/common_node_keys/xml_keys.dart';
import '../constants.dart';

abstract class Parser<T, R, O extends ParserOptions> {
  Parser({
    required this.data,
    required this.options,
  });
  final T data;
  final O options;

  R build();

  void buildRelations(
    xml.XmlDocument? documentRels, {
    required void Function(String, String, String) objectBuilder,
  }) {
    if (documentRels == null) return;
    final Iterable<xml.XmlElement> elements = documentRels.findAllElements('Relationship');
    for (final xml.XmlElement ele in elements) {
      final String id = ele.getAttribute('Id')!;
      final String type = ele.getAttribute('Type')!;
      final String target = ele.getAttribute('Target')!;
      objectBuilder.call(id, type, target);
    }
  }

  @protected
  void buildBlockAttributes(
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
      final String? rawTabStop = tabNode.getAttribute('w:pos');
      if (rawTabStop != null) {
        final double tabStop = double.parse(rawTabStop);
        // if the tabStop is 720, then will make a division and get correct value
        // for the indent
        //
        // like: 720 / 720 => 1
        // or like: 1.440 / 720 => 2
        final int indentValue = (tabStop / kDefaultTabStop).truncate();
        if (indentValue.floor() > 0) {
          final bool shouldAcceptSpacing = options.acceptSpacingValueWhen?.call(tabNode, indentValue) ?? true;
          if (shouldAcceptSpacing) {
            // we need to ensure that the indent must be into the range of 1 to 5
            blockAttributes['indent'] = indentValue.floor();
          }
        }
      }
    }
    if (!containsTabNode && containsIndentNode) {
      final String? rawLeftIndent = indentNode.getAttribute('w:left');
      final String? rawRightIndent = indentNode.getAttribute('w:right');
      final String? indent = rawLeftIndent ?? rawRightIndent;
      if (indent != null) {
        final double rawCurrentIndent = double.parse(indent);
        // if the indent is 720 or similar, then will make a division and get correct value
        // for the indent
        //
        // like: 709 / 708 => 1.x
        // or like: 1.418 / 708 => 2.xx
        final int indentValue = (rawCurrentIndent / kDefaultTabStop).truncate();
        if (indentValue.floor() > 0) {
          final bool shouldAcceptSpacing = options.acceptSpacingValueWhen?.call(tabNode!, indentValue) ?? true;
          if (shouldAcceptSpacing) {
            blockAttributes['indent'] = indentValue.floor();
          }
        }
      }
    }
    if (containsAlignment) {
      final String? align = alignNode.getAttribute('w:val');
      if (align != null) {
        // we add "both", because option, because in docx documents, "both" align is equivalent to justify alignment
        assert(
            align.isAlignStr,
            'Quill Delta only supports: right, left, center and justify alignments. '
            'The value of type: "$align" is not supported');
        blockAttributes['align'] = align.toFixedAlignStr();
      }
    }
    if (containsBorder) {
      final XmlNodeList<xml.XmlNode> children = borderNode.children;
      for (final xml.XmlNode child in children) {
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
        final int indent = int.tryParse(numberIndentLevel.isEmpty ? '0' : numberIndentLevel) ?? 0;
        if (indent > 0) {
          blockAttributes['indent'] = indent;
        }
      }
    }
  }

  @protected
  void buildInlineAttributes(
    xml.XmlElement? paragraphInlineAttributes,
    xml.XmlElement? textPartInlineAttributes,
    Map<String, dynamic> inlineAttributes,
    Map<String, dynamic> blockAttributes,
  ) {
    // family
    final xml.XmlElement? fontFamilyNode =
        textPartInlineAttributes?.getElement(xmlFontsNode) ?? paragraphInlineAttributes?.getElement(xmlFontsNode);
    final xml.XmlElement? fontSizeNode =
        textPartInlineAttributes?.getElement(xmlFontsNode) ?? paragraphInlineAttributes?.getElement(xmlFontsNode);
    // italic
    final xml.XmlElement? italicNode = textPartInlineAttributes?.getElement(xmlItalicNode) ??
        paragraphInlineAttributes?.getElement(xmlItalicNode);
    // bold
    final xml.XmlElement? boldNode =
        textPartInlineAttributes?.getElement(xmlBoldNode) ?? paragraphInlineAttributes?.getElement(xmlBoldNode);
    // underline
    final xml.XmlElement? underlineNode = textPartInlineAttributes?.getElement(xmlUnderlineNode) ??
        paragraphInlineAttributes?.getElement(xmlUnderlineNode);
    // script
    final xml.XmlElement? scriptNode = textPartInlineAttributes?.getElement(xmlScriptNode) ??
        paragraphInlineAttributes?.getElement(xmlScriptNode);
    // strike
    final xml.XmlElement? strikethroughNode = textPartInlineAttributes?.getElement(xmlStrikethroughNode) ??
        paragraphInlineAttributes?.getElement(xmlStrikethroughNode);
    // text color
    final xml.XmlElement? colorNode = textPartInlineAttributes?.getElement(xmlCharacterColorNode) ??
        paragraphInlineAttributes?.getElement(xmlCharacterColorNode);
    // background color
    final xml.XmlElement? backgroundColorNode =
        textPartInlineAttributes?.getElement(xmlBackgroundCharacterColorNode) ??
            paragraphInlineAttributes?.getElement(xmlBackgroundCharacterColorNode);
    // nodes values
    final String? sizeAttr =
        fontSizeNode?.getAttribute(xmlSizeFontNode) ?? fontSizeNode?.getAttribute(xmlSizeCsFontNode);
    final String? familyAttr = fontFamilyNode?.getAttribute('w:ascii') ??
        fontFamilyNode?.getAttribute('w:hAnsi') ??
        fontFamilyNode?.getAttribute('w:cs') ??
        fontFamilyNode?.getAttribute('w:asciiTheme') ??
        fontFamilyNode?.getElement('w:hAnsiTheme') as String?;
    final String? color = colorNode?.getAttribute('w:val');
    final String? backgroundColor = backgroundColorNode?.getAttribute('w:val');
    final String? scriptValue = scriptNode?.getAttribute('w:val');
    // check if we will accept this family
    if (familyAttr != null && fontFamilyNode != null) {
      final bool acceptFamily = options.acceptFontValueWhen?.call(fontFamilyNode, familyAttr) ?? false;
      if (acceptFamily) {
        inlineAttributes['font'] = familyAttr;
      }
    }
    if (sizeAttr != null) {
      bool acceptSize = !blockAttributes.containsKey('header');
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
          final int? numSize = int.tryParse(size);
          if(numSize != null) {
            inlineAttributes['size'] = numSize;
          }
        }
      }
    }
    if (italicNode != null && italicNode.localName == 'i') {
      inlineAttributes['italic'] = true;
    }
    if (boldNode != null && boldNode.localName == 'b') {
      inlineAttributes['italic'] = true;
    }
    if (underlineNode != null && underlineNode.localName == 'u') {
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
      final bool shouldAcceptColor = options.checkColor?.call(color) ?? isValidColor(color);
      if (!shouldAcceptColor && !options.ignoreColorWhenNoSupported) {
        throw Exception(
          'The color with the value: $color is not supported currently. '
          'You could consider use checkColor() param from the options',
        );
      }
      if (shouldAcceptColor) {
        if (options.colorBuilder == null) {
          inlineAttributes['color'] = color.startsWith('#') ? color : '#$color'.toUpperCase();
        } else if (options.colorBuilder != null) {
          final String? newColorV = options.colorBuilder!.call(color);
          if (newColorV != null && newColorV.trim().isNotEmpty) {
            inlineAttributes['color'] =
                newColorV.startsWith('#') ? newColorV.toUpperCase() : '#$newColorV'.toUpperCase();
          }
        }
      }
    }
    if (backgroundColor != null) {
      final bool shouldAcceptColor =
          options.checkColor?.call(backgroundColor) ?? isValidColor(backgroundColor.toUpperCase());
      if (!shouldAcceptColor && !options.ignoreColorWhenNoSupported) {
        throw Exception(
          'The color with the value: $backgroundColor is not supported currently. '
          'You could consider use checkColor() param from the options',
        );
      }
      if (shouldAcceptColor) {
        if (options.colorBuilder == null) {
          inlineAttributes['background'] =
              backgroundColor.startsWith('#') ? backgroundColor.toUpperCase() : '#$backgroundColor'.toUpperCase();
        } else if (options.colorBuilder != null) {
          final String? newColorV = options.colorBuilder?.call(backgroundColor);
          if (newColorV != null && newColorV.trim().isNotEmpty) {
            inlineAttributes['background'] =
                newColorV.startsWith('#') ? newColorV.toUpperCase() : '#$newColorV'.toUpperCase();
          }
        }
      }
    }
  }
}
