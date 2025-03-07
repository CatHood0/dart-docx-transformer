import 'package:meta/meta.dart';
import 'package:xml/xml.dart';

import '../utils/constants.dart';
import 'attribute.dart';

class IndentAttribute extends NodeAttribute<int?> {
  IndentAttribute(int? value)
      : super(
          key: 'indent',
          value: value,
          scope: Scope.paragraph,
        );

  @override
  String toXmlString() {
    if (value == null || value! <= 0) return '';
    return '<w:ind w:line="${value! * 720}" />';
  }

  @override
  XmlElement? toXml() {
    if(value == null || value! < 0) return null;
    return XmlElement.tag(
      'w:ind',
      attributes: [
        XmlAttribute(XmlName.fromString('w:line'), '${value! * 720}'),
      ],
    );
  }
}

class BlockquoteAttribute extends NodeAttribute<bool> {
  BlockquoteAttribute()
      : super(
          key: 'blockquote',
          value: true,
          scope: Scope.paragraph,
        );

  // this only should be overrided internally
  @internal
  String? borderColor;

  @internal
  int? borderSize;

  @internal
  int? borderSpace;

  final String _defaultNoneBorder = 'w:val="$noVal" w:color="$noColor" w:sz="8" w:space="$commonBorderSpace"';

  @override
  String toXmlString() {
    return '''<w:pBdr> 
        ${value ? '<w:left'
            'w:="single" '
            'w:color="${borderColor ?? kDefaultBorderColor} '
            'w:size="${borderSize ?? 8} '
            'w:space="${borderSpace ?? commonBorderSpace}"' : ''}
        ${value ? '<w:right $_defaultNoneBorder />' : ''}
        ${value ? '<w:top $_defaultNoneBorder />' : ''}
        ${value ? '<w:bottom $_defaultNoneBorder />' : ''}
        ${value ? '<w:between $_defaultNoneBorder />' : ''}
      </w:pBdr>
    ''';
  }

  @override
  XmlElement? toXml() {
    return XmlElement.tag(
      'w:pBdr',
      isSelfClosing: !value,
      children: !value
          ? <XmlNode>[]
          : <XmlNode>[
              XmlElement(
                XmlName.fromString('w:left'),
                [
                  XmlAttribute(XmlName.fromString('w:val'), 'single'),
                  XmlAttribute(XmlName.fromString('w:color'), borderColor ?? kDefaultBorderColor),
                  XmlAttribute(XmlName.fromString('w:sz'), '${borderSize ?? 8}'),
                  XmlAttribute(XmlName.fromString('w:space'), '${borderSpace ?? commonBorderSpace}'),
                ],
              ),
              _buildNoneBorderXmlElement('w:right'),
              _buildNoneBorderXmlElement('w:top'),
              _buildNoneBorderXmlElement('w:bottom'),
              _buildNoneBorderXmlElement('w:between'),
            ],
    );
  }

  XmlElement _buildNoneBorderXmlElement(String qualifiedName) {
    return XmlElement(
      XmlName.fromString(qualifiedName),
      [
        XmlAttribute(XmlName.fromString('w:val'), noVal),
        XmlAttribute(XmlName.fromString('w:color'), noColor),
        XmlAttribute(XmlName.fromString('w:sz'), commonBorderSize.toString()),
        XmlAttribute(XmlName.fromString('w:space'), commonBorderSpace.toString()),
      ],
    );
  }
}

class HeaderAttribute extends NodeAttribute<int> {
  HeaderAttribute(int value)
      : super(
          key: 'heading',
          value: value,
          scope: Scope.paragraph,
        );

  @override
  String toXmlString() {
    throw UnimplementedError();
  }

  @override
  XmlElement? toXml() {
    throw UnimplementedError();
  }
}

class AlignmentAttribute extends NodeAttribute<String> {
  AlignmentAttribute(String value)
      : super(
          key: 'alignment',
          value: value,
          scope: Scope.paragraph,
        );

  @override
  String toXmlString() {
    throw UnimplementedError();
  }

  @override
  XmlElement? toXml() {
    throw UnimplementedError();
  }
}

class NumberedListAttribute extends ListAttribute {
  NumberedListAttribute() : super('numbered');

  @override
  String toXmlString() {
    throw UnimplementedError();
  }

  @override
  XmlElement? toXml() {
    throw UnimplementedError();
  }
}

class UnorderedListAttribute extends ListAttribute {
  UnorderedListAttribute() : super('unordered');

  @override
  String toXmlString() {
    throw UnimplementedError();
  }

  @override
  XmlElement? toXml() {
    throw UnimplementedError();
  }
}

abstract class ListAttribute extends NodeAttribute<String> {
  ListAttribute(String value)
      : super(
          key: 'list',
          value: value,
          scope: Scope.paragraph,
        );
}
