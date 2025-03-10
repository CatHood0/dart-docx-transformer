import 'package:meta/meta.dart';
import 'package:xml/xml.dart';
import '../../../../../docx_transformer.dart';
import '../../../../common/schemas/common_node_keys/xml_keys.dart';
import '../../exceptions/content_not_processed_exception.dart';
import '../../mixins/printable_mixin.dart';

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

  bool get isLink;
  String get link;

  @protected
  XmlElement runParent({
    required List<XmlNode> nodes,
    List<XmlNode> runAttributes = const [],
  }) {
    if (rId == null && (isLink || this is ImageContent)) {
      throw ContentNotProcessedException(content: this);
    }
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

  @override
  SimpleContent? visitElement(
    bool Function(Content element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    return shouldGetElement(this) ? this : null;
  }

  @override
  List<SimpleContent>? visitAllElement(
    bool Function(Content element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? <SimpleContent>[this] : null;
  }
}
