import 'package:xml/xml.dart';
import '../utils/constants.dart';
import 'attribute.dart';

class BackgroundTextColorAttribute extends NodeAttribute<String?> {
  BackgroundTextColorAttribute(String? value)
      : super(
          key: 'background-color',
          value: value,
          scope: Scope.portion,
        );

  @override
  String toXmlString() {
    throw UnimplementedError();
  }

  @override
  XmlElement? toXml() {
    if (value == null || value!.isEmpty) return null;
    return XmlElement.tag(
      'w:shd',
      attributes: [
        XmlAttribute(XmlName.fromString('w:val'), value ?? noColor),
      ],
    );
  }
}

class ForegroundTextColorAttribute extends NodeAttribute<String?> {
  ForegroundTextColorAttribute(String? value)
      : super(
          key: 'text-color',
          value: value,
          scope: Scope.portion,
        );

  @override
  String toXmlString() {
    throw UnimplementedError();
  }

  @override
  XmlElement? toXml() {
    if (value == null || value!.isEmpty) return null;
    return XmlElement.tag(
      'w:color',
      attributes: [
        XmlAttribute(XmlName.fromString('w:val'), value ?? noColor),
      ],
    );
  }
}

class FontSizeAttribute extends NodeAttribute<int?> {
  FontSizeAttribute(int? size)
      : super(
          key: 'font-size',
          value: size,
          scope: Scope.portion,
        );

  @override
  String toXmlString() {
    throw UnimplementedError();
  }

  @override
  XmlElement? toXml() {
    if (value == null || value! < 0) return null;
    return XmlElement.tag(
      'w:sz',
      attributes: [
        XmlAttribute(
          XmlName.fromString('w:val'),
          '${value!}',
        ),
      ],
    );
  }
}

class FontFamilyAttribute extends NodeAttribute<String?> {
  FontFamilyAttribute(String? font)
      : super(
          key: 'font-family',
          value: font,
          scope: Scope.portion,
        );

  @override
  String toXmlString() {
    throw UnimplementedError();
  }

  @override
  XmlElement? toXml() {
    if (value == null || value!.isEmpty) return null;
    return XmlElement.tag(
      'w:rFonts',
      attributes: [
        XmlAttribute(
          XmlName.fromString('w:val'),
          value!,
        ),
      ],
      isSelfClosing: true,
    );
  }
}

class StrikeAttribute extends NodeAttribute<bool> {
  StrikeAttribute()
      : super(
          key: 'strike',
          value: true,
          scope: Scope.portion,
        );

  @override
  String toXmlString() {
    throw UnimplementedError();
  }

  @override
  XmlElement? toXml() {
    return XmlElement.tag('w:strike');
  }
}

class UnderlineAttribute extends NodeAttribute<bool> {
  UnderlineAttribute()
      : super(
          key: 'underline',
          value: true,
          scope: Scope.portion,
        );

  @override
  String toXmlString() {
    throw UnimplementedError();
  }

  @override
  XmlElement? toXml() {
    return XmlElement.tag('w:u');
  }
}

class ItalicAttribute extends NodeAttribute<bool> {
  ItalicAttribute()
      : super(
          key: 'italic',
          value: true,
          scope: Scope.portion,
        );

  @override
  String toXmlString() {
    throw UnimplementedError();
  }

  @override
  XmlElement? toXml() {
    return XmlElement.tag('w:i');
  }
}

class LinkAttribute extends NodeAttribute<String> {
  LinkAttribute(String link)
      : super(
          key: 'href',
          value: link,
          scope: Scope.portion,
        );

  @override
  String toXmlString() {
    return '';
  }

  @override
  XmlElement? toXml() {
    return null;
  }
}

class BoldAttribute extends NodeAttribute<bool> {
  BoldAttribute()
      : super(
          key: 'bold',
          value: true,
          scope: Scope.portion,
        );

  @override
  String toXmlString() {
    return '<w:b />';
  }

  @override
  XmlElement? toXml() {
    return XmlElement.tag('w:b');
  }
}

class ScriptAttribute extends NodeAttribute<String> {
  ScriptAttribute(String script)
      : super(
          key: 'script',
          value: script,
          scope: Scope.portion,
        );

  @override
  String toXmlString() {
    if (value.isEmpty || value != 'subscript' && value != 'superscript') return '';
    return '''
      <w:vertAlign w:val="$value"/>
    ''';
  }

  @override
  XmlElement? toXml() {
    return XmlElement.tag(
      'w:vertAlign',
      attributes: [
        XmlAttribute(
          XmlName.fromString('w:val'),
          value,
        ),
      ],
    );
  }
}

class SubscriptAttribute extends ScriptAttribute {
  SubscriptAttribute() : super('subscript');
}

class SuperscriptAttribute extends ScriptAttribute {
  SuperscriptAttribute() : super('superscript');
}
