import 'package:xml/xml.dart';

import '../../../default/xml_defaults.dart';
import '../../../extensions/string_ext.dart';
import '../../../namespaces.dart' show namespaces;

XmlDocument generateWebSettingsXML() => XmlDocument(
      [
        XmlDefaults.declaration,
        XmlElement.tag(
          'w:webSettings',
          attributes: <XmlAttribute>[
            XmlAttribute('xmlns:w'.toName(), namespaces['w']!),
            XmlAttribute('xmlns:r'.toName(), namespaces['r']!),
          ],
          children: <XmlNode>[],
          isSelfClosing: false,
        ),
      ],
    );
