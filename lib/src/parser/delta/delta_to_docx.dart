import 'dart:typed_data';

import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter_quill_delta_easy_parser/flutter_quill_delta_easy_parser.dart';
import '../../../docx_transformer.dart';
import '../../common/default/default_document_styles.dart';

class DeltaToDocx extends Parser<Delta, Future<Uint8List?>?, DocxParserOptions> {
  DeltaToDocx({
    required super.options,
  });

  // we will transform all to a encoded file and returned as bytes to be
  // writted by the developer
  @override
  Future<Uint8List?>? build({required Delta data}) {
    final Document? document = RichTextParser().parseDelta(data);
    final DocumentStylesSheet docStyles = options.documentProperties.docStyles ?? DefaultDocumentStyles.kDefaultDocumentStyleSheet;
    if (document == null) {
      throw StateError('The Delta passed is invalid to be transformed to a Word Document');
    }
    return null;
  }
}
