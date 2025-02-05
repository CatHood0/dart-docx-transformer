import 'dart:io';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quill_delta_docx_parser/src/parser/docx_to_delta.dart';
import 'package:quill_delta_docx_parser/src/parser/parser.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('minimal test', () async {
    final File file = File('test_resources/Documento.docx');
    final Parser<Uint8List, Delta?, DeltaParserOptions> parser = DocxToDelta(
      data: await file.readAsBytes(),
      options: DeltaParserOptions(),
    );
    final delta = parser.build();
    debugPrint('Result: $delta');
  });
}
