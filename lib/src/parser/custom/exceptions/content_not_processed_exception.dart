import '../../../../docx_transformer.dart';

class ContentNotProcessedException implements Exception {
  ContentNotProcessedException({
    required this.content,
  });

  final Content content;

  @override
  String toString() {
    return 'ContentNotProcessedException: The content of type ${content.runtimeType}(${content.id}) '
        'has its rId non initialized. '
        'This means that was not processed as expected '
        'before use buildXml() method';
  }
}
