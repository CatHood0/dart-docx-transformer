import 'package:quill_delta_docx_parser/src/parser/parser_options.dart';

abstract class Parser<T, R, O extends ParserOptions> {
  final T data;
  final O options;
  Parser({
    required this.data,
    required this.options,
  });

  R build();
}
