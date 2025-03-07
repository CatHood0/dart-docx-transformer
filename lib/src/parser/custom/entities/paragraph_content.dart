import 'package:xml/xml.dart';

import '../../../common/styles.dart';
import 'base/content.dart';
import 'base/document_context.dart';
import 'base/parent_content.dart';
import 'base/simple_content.dart';

class ParagraphContent extends ParentContent<SimpleContent> {
  ParagraphContent({
    required Iterable<SimpleContent> data,
    this.style,
  }) : super(parent: null, data: data) {
    for (final SimpleContent content in data) {
      content.parent = this;
    }
  }

  final Style? style;

  @override
  XmlElement buildXml({required DocumentContext context}) {
    final List<XmlElement> paragraphStyles = buildXmlStyle(context: context);
    final List<XmlAttribute> attrs = [...paragraphStyles.whereType<XmlAttribute>()];
    return runParent(
      attributes: attrs,
      children: <XmlNode>[
        ...paragraphStyles.whereType<XmlElement>(),
        ...data.map(
          (SimpleContent e) => e.buildXml(context: context),
        ),
      ],
    );
  }

  @override
  List<XmlElement> buildXmlStyle({required DocumentContext context}) {
    return [];
  }

  @override
  ParagraphContent get copy => ParagraphContent(data: data);

  @override
  SimpleContent? visitElement(bool Function(Content element) shouldGetElement,
      {bool visitChildrenIfNeeded = false}) {
    for (final element in data) {
      if (shouldGetElement(element)) {
        return element;
      }
    }
    if (visitChildrenIfNeeded) {
      for (final SimpleContent element in data) {
        final SimpleContent? foundedEl = element.visitElement(shouldGetElement) as SimpleContent?;
        if (foundedEl != null) return foundedEl;
      }
    }
    return null;
  }
}
