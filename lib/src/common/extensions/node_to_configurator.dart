import 'package:xml/xml.dart';

import '../styles.dart';
import 'string_ext.dart';

extension XmlNodeToStyleConfigurator on XmlElement {
  StyleConfigurator get toConfigurator {
    final Map<String, dynamic> attributes = <String, dynamic>{};
    for (final attr in this.attributes) {
      if (attr.localName == 'val') continue;
      attributes[attr.qualifiedName] = attr.value;
    }
    return isSelfClosing
        ? StyleConfigurator.autoClosure(
            propertyName: name.local,
            prefix: name.prefix,
            value: getAttribute('w:val'),
            attributes: attributes,
            configurators: <StyleConfigurator>[
              ...children.whereType<XmlElement>().map(
                    (XmlElement node) => node.toConfigurator,
                  ),
            ],
          )
        : StyleConfigurator.noAutoClosure(
            propertyName: name.local,
            attributes: attributes,
            prefix: name.prefix,
            value: getAttribute('w:val'),
            configurators: <StyleConfigurator>[
              ...children.whereType<XmlElement>().map(
                    (XmlElement node) => node.toConfigurator,
                  ),
            ],
          );
  }
}

extension StyleConfiguratorToXmlNode on StyleConfigurator {
  XmlNode get toNode {
    final List<XmlAttribute> xmlAttributes = [
      if (value != null) XmlAttribute(XmlName.fromString('w:val'), value.toString())
    ];
    for (final MapEntry<String, dynamic> attr in (attributes ?? {}).entries) {
      if (attr.key == 'val') continue;
      xmlAttributes.add(
        XmlAttribute(attr.key.toName(), attr.value),
      );
    }
    return XmlElement(
      qualifiedName.toName(),
      xmlAttributes,
      [
        ...configurators.map(
          (StyleConfigurator e) => e.toNode,
        ),
      ],
      isAutoClosure,
    );
  }
}
