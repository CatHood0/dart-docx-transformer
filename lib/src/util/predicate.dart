import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:xml/xml.dart' as xml;

typedef Predicate<T> = bool Function(xml.XmlNode node, T value);
typedef PredicateMisspell = bool Function(List<Operation> operationsMisspelled);
