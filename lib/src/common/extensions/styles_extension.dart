import '../../constants.dart';
import '../color.dart';
import '../generators/convert_xml_styles_to_doc.dart';
import '../schemas/common_node_keys/xml_keys.dart';
import '../schemas/common_node_keys/xml_local_keys.dart';
import '../styles.dart';
import 'string_ext.dart';

extension StylesExtension on Style {
  Map<String, dynamic>? buildBlockAttributesMap({
    required ConverterFromXmlContext context,
    bool computeIndents = true,
  }) {
    final StyleConfigurator? blockConfigurator = getConfigurator(localXmlKeyParagraphBlockAttrsNode);
    if (blockConfigurator == null || blockConfigurator.isInvalid) return null;
    final Map<String, dynamic> blocks = <String, dynamic>{};
    final StyleConfigurator? listConfigurator = blockConfigurator.getConfigurator(localXmlKeyListNode);
    final StyleConfigurator? indentConfigurator = blockConfigurator.getConfigurator(localXmlKeyIndentNode);
    final StyleConfigurator? tabIndentConfigurator = blockConfigurator.getConfigurator(localXmlKeyTabNode);
    final StyleConfigurator? alignConfigurator = blockConfigurator.getConfigurator(localXmlKeyAlignmentNode);
    final StyleConfigurator? spacingConfigurator = blockConfigurator.getConfigurator(localXmlKeySpacingNode);

    if (listConfigurator != null) {
      final String? codeNum = listConfigurator.getConfigurator(localXmlKeyListTypeNode)?.value as String?;
      final String? numberIndentLevel =
          listConfigurator.getConfigurator(localXmlKeyListIndentLevelNode)?.value as String?;
      if (codeNum != null && (codeNum == '2' || codeNum == '3')) {
        blocks['list'] = codeNum == '2' ? 'bullet' : 'ordered';
      }
      if (numberIndentLevel != null) {
        final int indent = int.tryParse(numberIndentLevel.isEmpty ? '0' : numberIndentLevel) ?? 0;
        if (indent > 0) {
          blocks['indent'] = indent;
        }
      }
    }

    if (alignConfigurator != null) {
      final String? align = alignConfigurator.value as String?;
      if (align != null) {
        // we add "both", because option, because in docx documents, "both" align is equivalent to justify alignment
        assert(
            align.isAlignStr,
            'Quill Delta only supports: right, left, center and justify alignments. '
            'The value of type: "$align" is not supported');
        blocks['align'] = align.toFixedAlignStr();
      }
    }

    if (computeIndents) {
      if (indentConfigurator != null) {
        final String? rawLeftIndent = indentConfigurator.attributes?['w:left'];
        final String? rawRightIndent = indentConfigurator.attributes?['w:right'];
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
            blocks['indent'] = indentValue.floor();
          }
        }
      }
      if (tabIndentConfigurator != null) {
        final String? rawTabStop = tabIndentConfigurator.attributes?['w:pos'];
        if (rawTabStop != null) {
          final double tabStop = double.parse(rawTabStop);
          // if the tabStop is 720, then will make a division and get correct value
          // for the indent
          //
          // like: 720 / 720 => 1
          // or like: 1.440 / 720 => 2
          final int indentValue = (tabStop / context.defaultTabStop).truncate();
          if (indentValue.floor() > 0) {
            // we need to ensure that the indent must be into the range of 1 to 5
            blocks['indent'] = indentValue.floor();
          }
        }
      }
    }
    if (spacingConfigurator != null) {
      final int? userParse = context.parseSpacing?.call(spacingConfigurator);
      if (userParse != null) {
        blocks['line-height'] = userParse;
      } else {
        final double? rawLine = double.tryParse(spacingConfigurator.attributes?['w:line'] ?? '');
        if (rawLine != null) {
          final double effectiveSpacing = rawLine / kDefaultSpacing1;
          if (effectiveSpacing > 0) {
            blocks['line-height'] = effectiveSpacing;
          }
        }
      }
    }
    return null;
  }

  Map<String, dynamic>? buildInlineAttributesMap({
    required ConverterFromXmlContext context,
    required Map<String, dynamic> blockAttributes,
  }) {
    final StyleConfigurator? inlineConfigurator = getConfigurator(localXmlKeyParagraphInlineAttrsNode);
    if (inlineConfigurator == null || inlineConfigurator.isInvalid) return null;
    final Map<String, dynamic> inlines = <String, dynamic>{};
    final StyleConfigurator? fontFamilyNode = inlineConfigurator.getConfigurator(localXmlKeyFontsNode);
    final String? family = fontFamilyNode?.attributes?['w:ascii'] ??
        fontFamilyNode?.attributes?['w:hAnsi'] ??
        fontFamilyNode?.attributes?['w:cs'] ??
        fontFamilyNode?.attributes?['w:asciiTheme'] ??
        fontFamilyNode?.attributes?['w:hAnsiTheme'];
    final StyleConfigurator? sizeNode = inlineConfigurator.getConfigurator(localXmlKeySizeFontNode);
    final String? color = inlineConfigurator.getConfigurator(localXmlKeyCharacterColorNode)?.value as String?;
    final String? backgroundColor =
        inlineConfigurator.getConfigurator(xmlBackgroundCharacterColorNode)?.value as String?;
    final StyleConfigurator? underlineNode = inlineConfigurator.getConfigurator(xmlUnderlineNode);
    final StyleConfigurator? boldNode = inlineConfigurator.getConfigurator(xmlBoldNode);
    final StyleConfigurator? strikeNode = inlineConfigurator.getConfigurator(xmlStrikethroughNode);
    // script
    final StyleConfigurator? scriptNode = inlineConfigurator.getConfigurator(xmlScriptNode);
    final String? scriptValue = scriptNode?.value as String?;
    final String? highlightColor =
        inlineConfigurator.getConfigurator(xmlHighlightCharacterColorNode)?.value as String?;
    final String? sizeAttr = sizeNode?.value as String?;
    if (underlineNode != null && underlineNode.propertyName == 'u') {
      inlines['underline'] = true;
    }
    if (boldNode != null && boldNode.propertyName == 'b') {
      inlines['bold'] = true;
    }
    if (strikeNode != null) {
      if (strikeNode.value == null) {
        inlines['strikethrough'] = true;
      }
    }
    if (scriptValue != null) {
      if (scriptValue != 'baseline') {
        inlines['script'] = scriptValue;
      }
    }
    if (family != null) {
      final bool acceptFamily = context.acceptFontValueWhen?.call(family) ?? true;
      if (acceptFamily) {
        inlines['font'] = family;
      }
    }
    if (color != null) {
      final bool shouldAcceptColor = context.checkColor?.call(color) ?? isValidColor(color);
      if (!shouldAcceptColor && !context.ignoreColorWhenNoSupported) {
        throw Exception(
          'The color with the value: $color is not supported currently. '
          'You could consider use checkColor() param from the context',
        );
      }
      if (shouldAcceptColor) {
        if (context.colorBuilder == null) {
          inlines['color'] = color.startsWith('#') ? color : '#$color'.toUpperCase();
        } else if (context.colorBuilder != null) {
          final String? newColorV = context.colorBuilder!.call(color);
          if (newColorV != null && newColorV.trim().isNotEmpty) {
            inlines['color'] =
                newColorV.startsWith('#') ? newColorV.toUpperCase() : '#$newColorV'.toUpperCase();
          }
        }
      }
    }
    if (highlightColor != null) {
      inlines['color'] = highlightColor;
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
          inlines['background'] =
              backgroundColor.startsWith('#') ? backgroundColor.toUpperCase() : '#$backgroundColor'.toUpperCase();
        } else if (context.colorBuilder != null) {
          final String? newColorV = context.colorBuilder?.call(backgroundColor);
          if (newColorV != null && newColorV.trim().isNotEmpty) {
            inlines['background'] =
                newColorV.startsWith('#') ? newColorV.toUpperCase() : '#$newColorV'.toUpperCase();
          }
        }
      }
    }
    if (sizeAttr != null) {
      bool acceptSize = true;
      final String size = sizeAttr.toString();
      if (context.acceptSizeValueWhen != null) {
        acceptSize = context.acceptSizeValueWhen?.call( size) ?? acceptSize;
      }
      if (acceptSize) {
        final int? possibleLevel = context.shouldParserSizeToHeading?.call(sizeAttr);
        if (possibleLevel != null && possibleLevel > 0 && possibleLevel < 7) {
          blockAttributes['header'] = '$possibleLevel';
        } else {
          final int? numSize = int.tryParse(size);
          if (numSize != null) {
            inlines['size'] = numSize;
          }
        }
      }
    }
    return null;
  }
}
