import 'dart:io';

import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter_quill_delta_easy_parser/flutter_quill_delta_easy_parser.dart';
import 'package:quill_delta_docx_parser/src/common/default/default_document_styles.dart';
import 'package:quill_delta_docx_parser/src/common/document/document_properties.dart';
import 'package:quill_delta_docx_parser/src/common/document/document_styles.dart';
import 'package:quill_delta_docx_parser/src/parser/parser.dart';
import 'package:quill_delta_docx_parser/src/parser/parser_options.dart';

class DeltaToDocx extends Parser<Delta, File?, DocxParserOptions> {
  DeltaToDocx({
    required super.data,
    required super.options,
  }) : assert(data.isEmpty, 'The Delta passed cannot be empty');

  @override
  File? build() {
    final Document? document = RichTextParser().parseDelta(data);
    final DocumentStylesSheet docStyles = options.documentProperties.docStyles ?? defaultDocumentStyles;
    if (document == null) {
      throw StateError('The Delta passed is invalid to be transformed to a Word Document');
    }
    return null;
  }
}
