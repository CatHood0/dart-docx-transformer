import 'dart:io';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:docx_transformer/docx_transformer.dart';
import 'package:docx_transformer/src/common/generators/hexadecimal_generator.dart';
import 'package:docx_transformer/src/parser/plain_text/plain_text_to_docx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('minimal test', () async {
    final File file = File('test_resources/Documento.docx');
    final DeltaFromDocxParser parser = DeltaFromDocxParser(
      data: await file.readAsBytes(),
      options: DeltaParserOptions(
        shouldParserSizeToHeading: null,
        ignoreColorWhenNoSupported: true,
        onDetectImage: (Uint8List bytes, String name) async {
          return 'path/to/my_image_${nanoid(8)}';
        },
      ),
    );
    final Delta? delta = await parser.build();
    //debugPrint('Result: $delta');
  });

  test('minimal test', () async {
    final PlainTextToDocx parser = PlainTextToDocx(
      data: 'Hello world about\nmy changed world\n\nYeah this is break',
      options: Options(
        title: 'title',
        onDetectImage: (Uint8List bytes, String name) async {
          return 'path/to/my_image_${nanoid(8)}';
        },
      ),
    );
    final Uint8List bytes = await parser.build();
  });
}
