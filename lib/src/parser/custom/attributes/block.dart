import 'package:meta/meta.dart';
import 'package:xml/xml.dart';

import '../utils/constants.dart';
import 'attribute.dart';

class IndentAttribute extends Attribute<int?> {
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
}

class BlockquoteAttribute extends Attribute<bool> {
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
    return '''
      <w:pBdr> 
        ${value ? '<w:left '
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
}

class HeaderAttribute extends Attribute<int> {
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
}

class AlignmentAttribute extends Attribute<String> {
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
}

class NumberedListAttribute extends ListAttribute {
  NumberedListAttribute() : super('numbered');

  @override
  String toXmlString() {
    throw UnimplementedError();
  }
}

class UnorderedListAttribute extends ListAttribute {
  UnorderedListAttribute() : super('unordered');

  @override
  String toXmlString() {
    throw UnimplementedError();
  }
}

abstract class ListAttribute extends Attribute<String> {
  ListAttribute(String value)
      : super(
          key: 'list',
          value: value,
          scope: Scope.paragraph,
        );
}
