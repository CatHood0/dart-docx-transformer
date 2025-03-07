import 'package:xml/xml.dart';

import '../../../common/namespaces.dart';
import 'base/document_context.dart';
import 'base/parent_content.dart';
import 'base/printable_mixin.dart';
import 'base/simple_content.dart';
import 'paragraph_content.dart';
import 'text_content.dart';

class ContentContainer {
  ContentContainer({
    required this.contents,
  });

  final Iterable<ParentContent<dynamic>> contents;

  String toPlainText() {
    final StringBuffer buffer = StringBuffer();
    for (final ParagraphContent pr in contents.whereType<ParagraphContent>()) {
      for (final PrintableMixin content in pr.data.whereType<PrintableMixin>()) {
        buffer.write(content.toPlainText());
      }
    }
    return '$buffer';
  }

  XmlDocument toXml({required DocumentContext context}) {
    return XmlDocument(
      <XmlNode>[
        XmlDeclaration(
          [
            XmlAttribute(XmlName.fromString('version'), '1.0'),
            XmlAttribute(XmlName.fromString('encoding'), 'UTF-8'),
            XmlAttribute(XmlName.fromString('standalone'), 'yes'),
          ],
        ),
        XmlElement.tag(
          'w:document',
          attributes: [
            ..._documentAttributes(),
          ],
          children: [
            XmlElement.tag(
              'w:body',
              children: [
                ...contents.map(
                  (e) => e.buildXml(context: context),
                ),
                XmlElement.tag(
                  'w:sectPr',
                  children: [
                    XmlElement.tag(
                      'w:pgSz',
                      attributes: [
                        XmlAttribute(
                          XmlName.fromString('w:w'),
                          context.properties.editorSettings.pageSize.width.toString(),
                        ),
                        XmlAttribute(
                          XmlName.fromString('w:h'),
                          context.properties.editorSettings.pageSize.height.toString(),
                        ),
                        XmlAttribute(
                          XmlName.fromString('w:orient'),
                          context.properties.orientation.name,
                        ),
                      ],
                      isSelfClosing: false,
                    ),
                    XmlElement.tag(
                      'w:pgMar',
                      attributes: [
                        XmlAttribute(
                          XmlName.fromString('w:top'),
                          context.properties.margins.top.toString(),
                        ),
                        XmlAttribute(
                          XmlName.fromString('w:bottom'),
                          context.properties.margins.bottom.toString(),
                        ),
                        XmlAttribute(
                          XmlName.fromString('w:left'),
                          context.properties.margins.left.toString(),
                        ),
                        XmlAttribute(
                          XmlName.fromString('w:right'),
                          context.properties.margins.right.toString(),
                        ),
                        XmlAttribute(
                          XmlName.fromString('w:footer'),
                          context.properties.margins.footer.toString(),
                        ),
                        XmlAttribute(
                          XmlName.fromString('w:header'),
                          context.properties.margins.header.toString(),
                        ),
                        XmlAttribute(
                          XmlName.fromString('w:gutter'),
                          context.properties.margins.gutter.toString(),
                        ),
                      ],
                      isSelfClosing: false,
                    ),
                  ],
                  isSelfClosing: false,
                ),
              ],
            ),
          ],
          isSelfClosing: false,
        ),
      ],
    );
  }

  List<XmlAttribute> _documentAttributes() {
    return <XmlAttribute>[
      XmlAttribute(XmlName.fromString('xmlns:a'), namespaces['a']!),
      XmlAttribute(XmlName.fromString('xmlns:cdr'), namespaces['cdr']!),
      XmlAttribute(XmlName.fromString('xmlns:o'), namespaces['o']!),
      XmlAttribute(XmlName.fromString('xmlns:pic'), namespaces['pic']!),
      XmlAttribute(XmlName.fromString('xmlns:r'), namespaces['r']!),
      XmlAttribute(XmlName.fromString('xmlns:v'), namespaces['v']!),
      XmlAttribute(XmlName.fromString('xmlns:ve'), namespaces['ve']!),
      XmlAttribute(XmlName.fromString('xmlns:vt'), namespaces['vt']!),
      XmlAttribute(XmlName.fromString('xmlns:w'), namespaces['w']!),
      XmlAttribute(XmlName.fromString('xmlns:w10'), namespaces['w10']!),
      XmlAttribute(XmlName.fromString('xmlns:wp'), namespaces['wp']!),
      XmlAttribute(XmlName.fromString('xmlns:wne'), namespaces['wne']!),
    ];
  }
}
