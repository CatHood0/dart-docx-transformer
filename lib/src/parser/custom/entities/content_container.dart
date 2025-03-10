import 'package:xml/xml.dart';

import '../../../common/default/xml_defaults.dart';
import '../../../common/document/document_properties.dart';
import '../mixins/printable_mixin.dart';
import 'base/document_context.dart';
import 'base/parent_content.dart';
import 'paragraph_content.dart';

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
    final DocumentProperties properties = context.properties;
    return XmlDocument(
      <XmlNode>[
        XmlDefaults.declaration,
        XmlElement.tag(
          'w:document',
          attributes: XmlDefaults.documentAttributes,
          children: [
            XmlElement.tag(
              'w:body',
              children: [
                ...contents.map(
                  (ParentContent e) {
                    context.currentContentPart = e;
                    return e.buildXml(context: context);
                  },
                ),
                XmlElement.tag(
                  'w:sectPr',
                  children: [
                    XmlElement.tag(
                      'w:pgSz',
                      attributes: [
                        XmlAttribute(
                          XmlName.fromString('w:w'),
                          properties.editorSettings.pageSize.width.toString(),
                        ),
                        XmlAttribute(
                          XmlName.fromString('w:h'),
                          properties.editorSettings.pageSize.height.toString(),
                        ),
                        XmlAttribute(
                          XmlName.fromString('w:orient'),
                          properties.orientation.name,
                        ),
                      ],
                      isSelfClosing: false,
                    ),
                    XmlElement.tag(
                      'w:pgMar',
                      attributes: [
                        XmlAttribute(
                          XmlName.fromString('w:top'),
                          properties.margins.top.toString(),
                        ),
                        XmlAttribute(
                          XmlName.fromString('w:bottom'),
                          properties.margins.bottom.toString(),
                        ),
                        XmlAttribute(
                          XmlName.fromString('w:left'),
                          properties.margins.left.toString(),
                        ),
                        XmlAttribute(
                          XmlName.fromString('w:right'),
                          properties.margins.right.toString(),
                        ),
                        XmlAttribute(
                          XmlName.fromString('w:footer'),
                          properties.margins.footer.toString(),
                        ),
                        XmlAttribute(
                          XmlName.fromString('w:header'),
                          properties.margins.header.toString(),
                        ),
                        XmlAttribute(
                          XmlName.fromString('w:gutter'),
                          properties.margins.gutter.toString(),
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
}
