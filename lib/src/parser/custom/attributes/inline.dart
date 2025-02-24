import 'attribute.dart';

class BackgroundTextColorAttribute extends Attribute<String?> {
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
}

class ForegroundTextColorAttribute extends Attribute<String?> {
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
}

class FontSizeAttribute extends Attribute<int?> {
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
}

class FontFamilyAttribute extends Attribute<String?> {
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
}

class StrikeAttribute extends Attribute<bool> {
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
}

class UnderlineAttribute extends Attribute<bool> {
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
}

class ItalicAttribute extends Attribute<bool> {
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
}

class LinkAttribute extends Attribute<String> {
  LinkAttribute(String link)
      : super(
          key: 'href',
          value: link,
          scope: Scope.portion,
        );

  @override
  String toXmlString() {
    throw UnimplementedError();
  }
}

class BoldAttribute extends Attribute<bool> {
  BoldAttribute()
      : super(
          key: 'bold',
          value: true,
          scope: Scope.portion,
        );

  @override
  String toXmlString() {
    throw UnimplementedError();
  }
}

class ScriptAttribute extends Attribute<String> {
  ScriptAttribute(String script)
      : super(
          key: 'script',
          value: script,
          scope: Scope.portion,
        );

  @override
  String toXmlString() {
    if(value.isEmpty || value != 'subscript' && value != 'superscript') return '';
    return '''
      <w:vertAlign w:val="$value"/>
    '''; 
  }
}

class SubscriptAttribute extends ScriptAttribute {
  SubscriptAttribute() : super('subscript');
}

class SuperscriptAttribute extends ScriptAttribute {
  SuperscriptAttribute() : super('superscript');
}
