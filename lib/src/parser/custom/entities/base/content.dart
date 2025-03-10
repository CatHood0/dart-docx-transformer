import 'package:xml/xml.dart';

import '../../../../common/generators/hexadecimal_generator.dart';
import 'document_context.dart';
import 'parent_content.dart';

abstract class Content<T> {
  Content({
    required this.data,
    this.parent,
  }) : id = nanoid(7);

  final T data;
  final String id;
  ParentContent? parent;
  Content<T> get copy;
  XmlNode buildXml({required DocumentContext context});
  List<XmlNode> buildXmlStyle({required DocumentContext context});
  Content? visitElement(
    bool Function(Content element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  });
  List<Content>? visitAllElement(
    bool Function(Content element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  });
  String? rId;
}
