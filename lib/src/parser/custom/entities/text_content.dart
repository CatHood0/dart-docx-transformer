import 'dart:convert';

import 'package:flutter_quill_delta_easy_parser/extensions/helpers/string_helper.dart';
import 'package:xml/xml.dart';

import '../../../common/extensions/string_ext.dart';
import '../../../common/schemas/common_node_keys/xml_keys.dart';
import '../attributes/attribute.dart';
import '../attributes/inline.dart';
import 'base/document_context.dart';
import 'base/simple_content.dart';

class TextContent extends SimpleContent<TextPart> {
  TextContent({
    required super.data,
    super.parent,
  });

  @override
  bool get isLink {
    final NodeAttribute style = data.styles.firstWhere(
      (NodeAttribute e) => e is LinkAttribute,
      orElse: BoldAttribute.new,
    );
    return style is LinkAttribute && style.value.isNotEmpty;
  }

  @override
  String get link {
    if (!isLink) return '';
    final LinkAttribute hyperlinkAttribute = data.styles.firstWhere(
      (
        NodeAttribute e,
      ) =>
          e is LinkAttribute,
    ) as LinkAttribute;
    return hyperlinkAttribute.value;
  }

  @override
  TextContent get copy => TextContent(
        data: TextPart(
          text: data.text,
          styles: data.styles,
        ),
        parent: parent,
      );

  @override
  XmlElement buildXml({required DocumentContext context}) {
    final List<String> lines = tokenizeWithNewLines(data.text);
    if (lines.length > 1) {
      return runParent(
        runAttributes: buildXmlStyle(context: context),
        nodes: [
          ...lines.map((line) {
            if (line == '\n') {
              return XmlElement('w:br'.toName());
            }
            return XmlElement.tag(
              xmlTextNode,
              children: [
                XmlText(line),
              ],
              isSelfClosing: false,
            );
          }),
        ],
      );
    }
    return runParent(
      runAttributes: buildXmlStyle(context: context),
      nodes: [
        if (data.text.isNotEmpty && data.text != '\n')
          XmlElement.tag(
            xmlTextNode,
            children: [
              XmlText(data.text),
            ],
            isSelfClosing: false,
          )
      ],
    );
  }

  @override
  List<XmlElement> buildXmlStyle({required DocumentContext context}) {
    if (data.styles.isEmpty) return [];
    final List<NodeAttribute> styles = <NodeAttribute>[...data.styles];
    if (styles.where((NodeAttribute e) => e.scope != Scope.portion).isNotEmpty) {
      throw Exception('The styles passed in $runtimeType are invalid. '
          'All of them must implement "Scope.portion" value');
    }
    final List<XmlElement> xmlStyles = <XmlElement>[];
    for (final NodeAttribute style in styles) {
      final XmlElement? styleXml = style.toXml();
      if (styleXml != null) {
        xmlStyles.add(styleXml);
      }
    }
    return xmlStyles.isEmpty
        ? []
        : [
            XmlElement.tag('w:rPr',
                children: [
                  ...xmlStyles,
                ],
                isSelfClosing: false),
          ];
  }

  @override
  String toPlainText() {
    return data.text;
  }

  @override
  String toString() {
    return 'TextContent(id: $id, data: $data)';
  }
}

class TextPart {
  TextPart({
    required this.text,
    this.styles = const <NodeAttribute>[],
  });

  final String text;
  final List<NodeAttribute> styles;

  @override
  String toString() {
    return 'TextPart(data: $text, styles: $styles)';
  }
}
