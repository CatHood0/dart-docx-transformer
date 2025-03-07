import 'package:meta/meta.dart';
import 'package:xml/xml.dart';
import '../../../../common/schemas/common_node_keys/xml_keys.dart';
import 'content.dart';
import 'printable_mixin.dart';

abstract class SimpleContent<T> extends Content<T> with PrintableMixin {
  SimpleContent({
    required super.data,
    super.parent,
  });

  @override
  @mustBeOverridden
  String toString() {
    return super.toString();
  }

  @protected
  XmlElement runParent({
    required List<XmlNode> nodes,
    required bool isLink,
    List<XmlNode> runAttributes = const [],
  }) {
    final XmlElement run = XmlElement.tag(
      xmlTextRunNode,
      children: <XmlNode>[
        ...runAttributes,
        ...nodes,
      ],
      isSelfClosing: false,
    );
    return isLink
        ? XmlElement.tag(
            xmlHyperlinkNode,
            attributes: <XmlAttribute>[
              XmlAttribute(
                XmlName.fromString('r:id'),
                rId!,
              ),
            ],
            children: <XmlNode>[run],
            isSelfClosing: false,
          )
        : run;
  }
}
