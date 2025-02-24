import '../attributes/attribute.dart';
import 'base/content.dart';
import 'base/document_context.dart';

const String _kDefaultEmptyRun = '<w:r><w:t xml="preserved-whitespace"></w:r>';

class TextContent extends Content<TextPart> {
  TextContent({
    required super.data,
    super.parent,
  });

  @override
  String buildXml({required DocumentContext context}) {
    final String xml = buildXmlStyle(context: context);
    final String style = xml.isEmpty ? '' : '$xml\n';
    final List<String> texts = data.text.split(' ');
    return '''
      ${texts.map((String element) {
      return '''\n<w:r>$style<w:t xml:space="preserve">$element</w:t>\n</w:r>''';
    }).join('\n$_kDefaultEmptyRun')}
    ''';
  }

  @override
  String buildXmlStyle({required DocumentContext context}) {
    if (data.styles.isEmpty) return '';
    final List<Attribute> styles = <Attribute>[...data.styles];
    if (styles.where((Attribute e) => e.scope != Scope.portion).isNotEmpty) {
      throw Exception('The styles passed in $runtimeType are invalid. '
          'All of them must implement "Scope.portion" value');
    }
    final Iterable<String> xmlStyles = styles.map((Attribute e) => e.toXmlString());
    if (xmlStyles.isEmpty) return '';
    return '''
     <w:rPr>
      ${xmlStyles.join('$_whitespaces\n')},
     <w:rPr>
    ''';
  }

  final String _whitespaces = '      ';

  @override
  TextContent get copy => TextContent(
        data: TextPart(
          text: data.text,
          styles: data.styles,
        ),
        parent: parent,
      );
}

class TextPart {
  TextPart({
    required this.text,
    required this.styles,
  });

  final String text;
  final List<Attribute> styles;
}
