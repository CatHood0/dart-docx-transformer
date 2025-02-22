import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docx_transformer/src/common/generators/hexadecimal_generator.dart';
import 'package:docx_transformer/src/parser/delta/delta_from_docx.dart';
import 'package:docx_transformer/src/parser/parser.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('minimal test', () async {
    final File file = File('test_resources/Documento.docx');
    final DocxToDelta parser = DocxToDelta(
      data: await file.readAsBytes(),
      options: DeltaParserOptions(
          shouldParserSizeToHeading: null,
          onDetectImage: (bytes, name) async {
            return 'path/to/my_image_${nanoid(8)}';
          }),
    );
    final delta = await parser.build();
    debugPrint('Result: $delta');
  });
}
