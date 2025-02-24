abstract class Attribute<T> {
  Attribute({
    required this.key,
    required this.value,
    required this.scope,
  });

  final String key;
  final T value;
  final Scope scope;
  String toXmlString();
}

enum Scope {
  portion,
  paragraph,
  custom, 
}


