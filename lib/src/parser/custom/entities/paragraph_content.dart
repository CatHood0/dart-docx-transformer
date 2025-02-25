import '../../../../docx_transformer.dart';
import 'base/content.dart';
import 'base/document_context.dart';

class ParagraphContent extends Content<Iterable<Content>> {
  ParagraphContent({
    required super.data,
    this.style,
  }) : super(parent: null);

  final Style? style;

  @override
  String buildXml({required DocumentContext context}) {
    final String style = buildXmlStyle(context: context);
    final String runs = data.map((Content e) {
      context.currentContentPart = e;
      return e.buildXml(
        context: context,
      );
    }).join('\n');
    return '<w:p>$style\n$runs</w:p>';
  }

  @override
  String buildXmlStyle({required DocumentContext context}) {
    return '';
  }

  @override
  ParagraphContent get copy => ParagraphContent(data: data);
}
