import 'package:xml/xml.dart';

import 'document_context.dart';

abstract class Content<T> {
  Content({
    required this.data,
    this.parent,
  });

  final XmlNode? parent;
  final T data;
  Content<T> get copy;
  String buildXml({required DocumentContext context});
  String buildXmlStyle({required DocumentContext context});
  bool canBuildStyles(DocumentContext context) =>
      buildXmlStyle(context: context).isNotEmpty ||
      buildXmlStyle(context: context)
          .replaceAll(
            '\n',
            '',
          )
          .trim()
          .isNotEmpty;
}
