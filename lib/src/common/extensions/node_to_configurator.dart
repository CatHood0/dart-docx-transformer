import 'package:xml/xml.dart';

import '../styles.dart';

extension XmlNodeToStyleConfigurator on XmlElement {
  StyleConfigurator get toConfigurator {
    final Map<String, dynamic> attributes = <String, dynamic>{};
    for (final attr in this.attributes) {
      if (attr.localName == 'val') continue;
      attributes['${attr.name.prefix ?? ''}${attr.name.local}'] = attr.value;
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
  XmlNode get toConfigurator {
    final List<XmlAttribute> xmlAttributes = [
      if (value != null) XmlAttribute(XmlName.fromString('w:val'), value.toString())
    ];
    for (final MapEntry<String, dynamic> attr in (attributes ?? {}).entries) {
      if (attr.key == 'val') continue;
      xmlAttributes.add(
        XmlAttribute(XmlName.fromString('w:${attr.key}'), attr.value),
      );
    }
    return XmlElement(
      XmlName.fromString('${prefix != null ? '$prefix:' : ''}$propertyName'),
      xmlAttributes,
      [
        ...configurators.map(
          (StyleConfigurator e) => e.toConfigurator,
        ),
      ],
      isAutoClosure,
    );
  }
}
