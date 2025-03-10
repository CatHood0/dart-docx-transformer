import 'package:xml/xml.dart';

import '../../../default/xml_defaults.dart';
import '../../../namespaces.dart';
import '../../common_node_keys/word_files_common.dart';

/// Correspond to file [Content_Types].xml
XmlDocument generateContentTypesXml({Iterable<String> knowedExtensions = const []}) {
  return XmlDocument(
    [
      XmlDefaults.declaration,
      XmlElement.tag(
        'Types',
        attributes: [XmlAttribute(XmlName.fromString('xmlns'), namespaces['contentTypes']!)],
        children: [
          _defaultElement('rels', namespaces['relationsXml']!),
          _defaultElement('png', 'image/png'),
          _defaultElement('jpg', 'image/jpg'),
          _defaultElement('jpeg', 'image/jpeg'),
          _defaultElement('xml', 'application/xml'),
          _overrideElement('/$relsFilePath', namespaces['relationsXml']!),
          _overrideElement('/$documentXmlRelsFilePath', namespaces['relationsXml']!),
          _overrideElement('/$documentFilePath', namespaces['documentType']!),
          _overrideElement('/$stylesXmlFilePath', namespaces['stylesType']!),
          _overrideElement('/$numberingXmlFilePath', namespaces['numberingType']!),
          // we need to auto generate theme types when needed
          _overrideElement('/$theme1XmlFilePath', namespaces['themeType']!),
          _overrideElement('/$fontTableXmlFilePath', namespaces['fontTableType']!),
          _overrideElement('/$coreFilePath', namespaces['corePropsType']!),
          _overrideElement('/$settingsXmlFilePath', namespaces['settingsType']!),
          _overrideElement('/$webSettingsXmlFilePath', namespaces['webSettingsType']!),
        ],
        isSelfClosing: false,
      ),
    ],
  );
}

XmlElement _defaultElement(String type, String contentType) {
  return XmlElement(
    XmlName('Default'),
    [
      XmlAttribute(XmlName('Extension'), type),
      XmlAttribute(XmlName('ContentType'), contentType),
    ],
    [],
    true,
  );
}

XmlElement _overrideElement(String part, String contentType) {
  return XmlElement(
    XmlName('Override'),
    [
      XmlAttribute(XmlName('PartName'), part),
      XmlAttribute(XmlName('ContentType'), contentType),
    ],
    [],
    true,
  );
}
