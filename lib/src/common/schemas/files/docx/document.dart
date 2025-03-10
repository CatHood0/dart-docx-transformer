import 'package:xml/xml.dart';

import '../../../../../docx_transformer.dart';
import '../../../default/xml_defaults.dart';

XmlDocument generateDocumentXml(
  DocumentProperties properties, {
  required Iterable<XmlElement> contents,
}) =>
    XmlDocument(
      <XmlNode>[
        XmlDefaults.declaration,
        XmlElement.tag(
          'w:document',
          attributes: XmlDefaults.documentAttributes,
          children: [
            XmlElement.tag(
              'w:body',
              children: [
                ...contents,
                XmlDefaults.sectPr(properties: properties),
              ],
            ),
          ],
          isSelfClosing: false,
        ),
      ],
    );
