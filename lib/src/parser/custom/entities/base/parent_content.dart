import 'package:meta/meta.dart';
import 'package:xml/xml.dart';

import '../../../../common/schemas/common_node_keys/xml_keys.dart';
import 'content.dart';

abstract class ParentContent<T> extends Content<Iterable<T>> {
  ParentContent({
    required super.data,
    super.parent,
  });

  @protected
  XmlElement runParent({
    required List<XmlAttribute> attributes,
    required List<XmlNode> children,
  }) {
    return XmlElement.tag(
      xmlParagraphNode,
      attributes: attributes,
      children: children,
      isSelfClosing: data.isEmpty,
    );
  }
}
