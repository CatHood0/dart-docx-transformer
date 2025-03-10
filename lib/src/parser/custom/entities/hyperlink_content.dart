import 'package:xml/xml.dart';

import '../../../../docx_transformer.dart';
import '../../../common/schemas/common_node_keys/xml_keys.dart';
import '../../../constants.dart';
import '../attributes/attribute.dart';

class HyperlinkContent extends SimpleContent<HyperlinkTextPart> {
  HyperlinkContent({
    required super.data,
    super.parent,
  });

  @override
  bool get isLink => true;

  @override
  String get link => data.hyperlink;

  @override
  HyperlinkContent get copy => HyperlinkContent(
        data: HyperlinkTextPart(
          hyperlink: data.hyperlink,
          text: data.text,
          styles: data.styles,
        ),
        parent: parent,
      );

  @override
  XmlElement buildXml({required DocumentContext context}) {
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
    return 'HyperlinkContent(id: $id, data: $data)';
  }

  @override
  HyperlinkContent? visitElement(
    bool Function(Content element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    if (shouldGetElement(this)) return this;
    return null;
  }
}

class HyperlinkTextPart extends TextPart {
  HyperlinkTextPart({
    required super.text,
    required this.hyperlink,
    super.styles,
  }) : assert(linkDetectorMatcher.hasMatch(hyperlink), 'The link: "$hyperlink" is not a valid like');
  final String hyperlink;

  @override
  String toString() {
    return 'Hyperlink(link: $hyperlink)';
  }
}
