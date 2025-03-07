import 'package:xml/xml.dart';

import '../../../common/schemas/common_node_keys/xml_keys.dart';
import '../attributes/attribute.dart';
import '../attributes/inline.dart';
import 'base/content.dart';
import 'base/document_context.dart';
import 'base/simple_content.dart';

class TextContent extends SimpleContent<TextPart> {
  TextContent({
    required super.data,
    super.parent,
  });

  @override
  XmlElement buildXml({required DocumentContext context}) {
    return runParent(
      runAttributes: buildXmlStyle(context: context),
      nodes: [
        XmlElement.tag(
          xmlTextNode,
          children: [
            XmlText(data.text),
          ],
          isSelfClosing: false,
        )
      ],
      isLink: data.styles.firstWhere(
        (e) => e is LinkAttribute,
        orElse: BoldAttribute.new,
      ) is LinkAttribute,
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
  TextContent get copy => TextContent(
        data: TextPart(
          text: data.text,
          styles: data.styles,
        ),
        parent: parent,
      );


  @override
  TextContent? visitElement(bool Function(Content element) shouldGetElement) {
    if (shouldGetElement(this)) return this;
    return null;
  }

  @override
  String toString() {
    return 'TextContent(id: $id, data: $data)';
  }

  @override
  String toPlainText() {
    return data.text;
  }
}

class TextPart {
  TextPart({
    required this.text,
    this.styles = const <NodeAttribute>[],
  });

  final String text;
  final List<NodeAttribute> styles;
}
