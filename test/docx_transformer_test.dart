import 'dart:io';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:docx_transformer/docx_transformer.dart';
import 'package:docx_transformer/src/common/generators/hexadecimal_generator.dart';
import 'package:docx_transformer/src/parser/custom/attributes/attribute.dart';
import 'package:docx_transformer/src/parser/custom/attributes/inline.dart';
import 'package:docx_transformer/src/parser/custom/content_to_docx.dart';
import 'package:docx_transformer/src/parser/custom/entities/content_container.dart';
import 'package:docx_transformer/src/parser/custom/entities/paragraph_content.dart';
import 'package:docx_transformer/src/parser/custom/entities/text_content.dart';
import 'package:docx_transformer/src/parser/plain_text/plain_text_to_docx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('minimal test', () async {
    final File file = File('test_resources/Documento.docx');
    final DeltaFromDocxParser parser = DeltaFromDocxParser(
      options: DeltaParserOptions(
        shouldParserSizeToHeading: null,
        ignoreColorWhenNoSupported: true,
        onDetectImage: (Uint8List bytes, String name) async {
          return 'path/to/my_image_${nanoid(8)}';
        },
      ),
    );
    final Delta? delta = await parser.build(data: await file.readAsBytes());
    //debugPrint('Result: $delta');
  });

  test('minimal test', () async {
    final parser = ContentToDocx(
      options: BasicParserOptions(
        title: 'title',
        onDetectImage: (Uint8List bytes, String name) async {
          return 'path/to/my_image_${nanoid(8)}';
        },
      ),
    );
    final bytes = await parser.build(
      data: ContentContainer(
        contents: [
          ParagraphContent(
            data: [
              TextContent(data: TextPart(text: 'This is a part of the text where')),
              TextContent(data: TextPart(text: ' your can use', styles: <Attribute>[BoldAttribute()])),
            ],
          ),
          ParagraphContent(
            data: [
              TextContent(data: TextPart(text: '\nYeah')),
              TextContent(data: TextPart(text: '\n')),
            ],
          ),
        ],
      ),
    );
  });

  test('minimal test', () async {
    final PlainTextToDocx parser = PlainTextToDocx(
      options: BasicParserOptions(
        title: 'title',
        onDetectImage: (Uint8List bytes, String name) async {
          return 'path/to/my_image_${nanoid(8)}';
        },
      ),
    );
    final Uint8List bytes = await parser.build(data: 'Hello world about\nmy changed world\n\nYeah this is break');
  });
}
