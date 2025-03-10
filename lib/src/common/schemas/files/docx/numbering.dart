import 'package:xml/xml.dart';

import '../../../default/xml_defaults.dart';
import '../../../namespaces.dart';

XmlDocument generateNumberingXMLTemplate() => XmlDocument(
      <XmlNode>[
        XmlDefaults.declaration,
        XmlElement.tag(
          'w:numbering',
          attributes: <XmlAttribute>[
            XmlAttribute(XmlName.fromString('xmlns:w'), namespaces['w']!),
            XmlAttribute(XmlName.fromString('xmlns:ve'), namespaces['ve']!),
            XmlAttribute(XmlName.fromString('xmlns:o'), namespaces['o']!),
            XmlAttribute(XmlName.fromString('xmlns:r'), namespaces['r']!),
            XmlAttribute(XmlName.fromString('xmlns:v'), namespaces['v']!),
            XmlAttribute(XmlName.fromString('xmlns:wp'), namespaces['wp']!),
            XmlAttribute(XmlName.fromString('xmlns:w10'), namespaces['w10']!),
            XmlAttribute(XmlName.fromString('xmlns:wne'), namespaces['wne']!),
          ],
          isSelfClosing: false,
        ),
      ],
    );
