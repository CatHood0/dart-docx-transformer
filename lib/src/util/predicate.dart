import 'package:dart_quill_delta/dart_quill_delta.dart';
import '../common/styles.dart';

typedef Predicate<T> = bool Function(T value);
typedef PredicateMisspell = bool Function(List<Operation> operationsMisspelled);
typedef ParseSizeToHeadingCallback = int? Function(String size);
typedef ParseSpacingCallback = int Function(StyleConfigurator spacingConfigurator);
