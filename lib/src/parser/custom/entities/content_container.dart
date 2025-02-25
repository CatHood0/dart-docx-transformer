import 'base/content.dart';
import 'paragraph_content.dart';
import 'text_content.dart';

class ContentContainer {
  ContentContainer({
    required this.contents,
  });

  final Iterable<ParagraphContent> contents;

  String toPlainText() {
    final StringBuffer buffer = StringBuffer();
    for (final ParagraphContent content in contents) {
      if (content is TextContent) {
        buffer.write((content as TextContent).data.text);
      }
    }
    return '$buffer';
  }
}
