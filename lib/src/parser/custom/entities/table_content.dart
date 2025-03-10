import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:xml/xml.dart';
import '../../../../docx_transformer.dart';
import '../../../constants.dart';

class TableContent extends ParentContent<Iterable<TableRow>> {
  TableContent({
    required super.data,
    required this.properties,
    super.parent,
  });

  final TableProperties properties;

  @override
  XmlElement buildXml({required DocumentContext context}) {
    final List<XmlElement> _gridCols = [];
    if (properties.gridColWidthBuilder != null) {
      for (int i = 0; i < data.length; i++) {
        final TableRow tr = data.elementAt(i);
        final double width = computeTwip(properties.gridColWidthBuilder!(tr, i)).toDouble();
        _gridCols.add(
          XmlElement.tag(
            'w:gridCol',
            attributes: [
              XmlAttribute(XmlName.fromString('w:w'), '$width'),
            ],
            isSelfClosing: true,
          ),
        );
      }
    }
    return runParent(
      attributes: <XmlAttribute>[],
      isSelfClosing: data.isNotEmpty,
      children: <XmlNode>[
        XmlElement.tag(
          'w:tbl',
          children: [
            ...buildXmlStyle(context: context),
            ...data.map((TableRow tr) {
              return XmlElement.tag(
                'w:tr',
                children: [
                  ...tr.cells.map(
                    (TableCell cell) {
                      return cell.content.buildXml(context: context);
                    },
                  ),
                ],
                isSelfClosing: false,
              );
            }),
          ],
          isSelfClosing: false,
        ),
      ],
    );
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[
      XmlElement.tag(
        'w:tblPr',
        children: [
          if (properties.tableStyle != null)
            XmlElement.tag(
              'w:tblStyle',
              attributes: [
                XmlAttribute(
                  XmlName.fromString('w:val'),
                  properties.tableStyle!,
                ),
              ],
            ),
          XmlElement.tag(
            'w:tblW',
            attributes: [
              // width of the table
              XmlAttribute(
                XmlName.fromString('w:w'),
                (properties.width.size ?? 0).toString(),
              ),
              // type of the width size computing
              XmlAttribute(
                XmlName.fromString('w:type'),
                properties.width.type,
              ),
            ],
            isSelfClosing: false,
          ),
          XmlElement.tag(
            'w:tblW',
            attributes: [
              // width of the table
              XmlAttribute(
                XmlName.fromString('w:w'),
                (properties.width.size ?? 0).toString(),
              ),
              // type of the width size computing
              XmlAttribute(
                XmlName.fromString('w:type'),
                properties.width.type,
              ),
            ],
            isSelfClosing: false,
          ),
        ],
        isSelfClosing: false,
      ),
    ];
  }

  @override
  TableContent get copy => TableContent(
        data: data,
        properties: properties,
        parent: parent,
      );

  @override
  Content? visitElement(
    bool Function(Content element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    for (final TableRow row in data) {
      for (final TableCell cell in row.cells) {
        if (shouldGetElement(cell.content)) {
          return cell.content;
        }
      }
    }
    return null;
  }

  @override
  List<Content>? visitAllElement(
    bool Function(Content element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (data.isEmpty) return null;
    final List<Content> elements = <Content>[];
    for (final TableRow row in data) {
      for (final TableCell cell in row.cells) {
        if (shouldGetElement(cell.content)) {
          elements.add(cell.content);
        } else if (visitChildrenIfNeeded) {
          final Iterable<Content>? foundedEl = cell.content.visitAllElement(
            shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded,
          );
          if (foundedEl != null) {
            elements.addAll(foundedEl);
          }
        }
      }
    }
    return elements;
  }
}

// Every row is counted as a column of the table
class TableRow {
  TableRow({
    required this.cells,
    this.width,
    this.height,
    this.padding,
  });

  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final Iterable<TableCell> cells;
}

class TableCell {
  TableCell({
    required this.content,
  }) : assert(content is! TableContent,
            'A table cell cannot use a content(${content.id}) of the same type of the body table');

  final ParentContent content;
}

class TableProperties {
  TableProperties({
    SizeProperty? width,
    this.tableStyle,
    this.gridColWidthBuilder,
  }) : width = width ?? SizeProperty.auto();

  final SizeProperty width;

  /// this allow define a width for every column of the table
  ///
  /// pass the width that you want, since internally, we make the calculation
  /// to avoid pass the correct format for DOCX convention
  final double Function(TableRow row, int index)? gridColWidthBuilder;

  /// this string is a value that should matches with a style
  /// registered into styles.xml
  final String? tableStyle;
}

class SizeProperty {
  SizeProperty({
    required this.size,
    required this.type,
  }) : assert(
            type.isNotEmpty &&
                (type == 'dxa' ||
                    type == 'auto' ||
                    type == 'pct' ||
                    type == 'nil' ||
                    type == 'none'),
            type.isEmpty
                ? 'Type cannot be empty'
                : 'Type with value "$type" is not supported. You will need to '
                    'change it to be into the range of '
                    'values accepted: "dxa", "pct", "nil", "auto" and "none"');

  SizeProperty.dxa({
    required this.size,
  }) : type = size == null || size < 1 ? 'none' : 'dxa';

  SizeProperty.pct({
    required this.size,
  }) : type = size == null || size < 1 ? 'none' : 'pct';

  SizeProperty.nil()
      : size = null,
        type = 'nil';

  SizeProperty.none()
      : size = null,
        type = 'none';

  SizeProperty.auto()
      : size = 0,
        type = 'auto';

  final double? size;
  final String type;
}
