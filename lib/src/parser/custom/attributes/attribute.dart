import 'package:xml/xml.dart';

abstract class NodeAttribute<T> {
  NodeAttribute({
    required this.key,
    required this.value,
    required this.scope,
  });

  final String key;
  final T value;
  final Scope scope;
  String toXmlString();
  XmlElement? toXml();
}

enum Scope {
  portion,
  paragraph,
  custom, 
}


