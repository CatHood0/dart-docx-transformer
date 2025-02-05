import 'package:quill_delta_docx_parser/quill_delta_docx_parser.dart';
import 'package:xml/xml.dart' as xml;

List<Styles> convertXmlStylesToStyles(xml.XmlDocument styles) {
  final result = <Styles>[];

  final rawStyles = styles.findAllElements('w:style');
  if (rawStyles.isEmpty) return result;
  for (var styleElement in rawStyles) {
    final type = styleElement.getAttribute('type') ?? '';
    final styleId = styleElement.getAttribute('w:styleId') ?? '';
    final nameElement = styleElement.getElement('w:name');
    final styleName = nameElement?.getAttribute('w:val') ?? '';

    final subStyles = <SubStyles>[];
    for (var node in styleElement.children.whereType<xml.XmlElement>()) {
      if (node.name.local == 'name') continue;

      final attributes = <String, dynamic>{};
      for (var attr in node.attributes) {
        attributes[attr.name.local] = attr.value;
      }

      subStyles.add(
        SubStyles(
          propertyName: node.name.local,
          value: attributes.isEmpty ? null : attributes,
          extraInfo: attributes.isNotEmpty ? attributes : null,
        ),
      );
    }

    result.add(
      Styles(
        type: type,
        styleId: styleId,
        styleName: styleName,
        subStyles: subStyles,
      ),
    );
  }
  return result;
}
