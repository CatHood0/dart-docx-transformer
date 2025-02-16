import 'dart:io';
import 'dart:typed_data';

import 'package:quill_delta_docx_parser/quill_delta_docx_parser.dart';
import 'package:quill_delta_docx_parser/src/parser/parser_options.dart';
import 'package:quill_delta_docx_parser/src/util/predicate.dart';

abstract class Parser<T, R, O extends ParserOptions> {
  final T data;
  final O options;
  Parser({
    required this.data,
    required this.options,
  });

  R build();
}

class DeltaParserOptions extends ParserOptions {
  final Predicate<String>? acceptFontValueWhen;
  final Predicate<String>? acceptSizeValueWhen;

  /// a way to build a custom size from Word
  /// to a know value for Quill Delta
  ///
  /// like: "28" can be converted to "huge"
  final String Function(String)? transformSizeValueTo;

  /// This is a callback that decides if the operations
  /// founded at this point, contains misspelled attribute
  /// from &lt;w:proofErr/&gt;
  final PredicateMisspell? buildDeltaFromMisspelledOps;
  final Future<Object?> Function(Uint8List bytes, String name) onDetectImage;
  final ParseSizeToHeadingCallback? shouldParserSizeToHeading;
  final ParseXmlSpacingCallback? parseXmlSpacing;

  DeltaParserOptions({
    required this.onDetectImage,
    required this.shouldParserSizeToHeading,
    this.parseXmlSpacing,
    this.acceptFontValueWhen,
    this.acceptSizeValueWhen,
    this.transformSizeValueTo,
    this.buildDeltaFromMisspelledOps,
  });
}

class DocxParserOptions extends ParserOptions {
  final String fileName;
  final String path;
  final Directory? directoryWrapper;
  final DocumentProperties documentProperties;

  DocxParserOptions({
    required this.fileName,
    required this.path,
    required this.directoryWrapper,
    required this.documentProperties,
  });
}
