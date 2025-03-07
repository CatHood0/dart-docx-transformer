import 'package:flutter/widgets.dart';
import 'package:xml/xml.dart';

import 'base/content.dart';
import 'base/document_context.dart';
import 'base/parent_content.dart';
import 'base/simple_content.dart';

class TableContent extends ParentContent<TableRow> {
  TableContent({
    required super.data,
    super.parent,
  });

  @override
  XmlElement buildXml({required DocumentContext context}) {
    return runParent(
      attributes: <XmlAttribute>[],
      children: <XmlNode>[],
    );
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[];
  }

  @override
  TableContent get copy => TableContent(data: data);

  @override
  Content? visitElement(bool Function(Content element) shouldGetElement) {
    for (final TableRow row in data) {
      for (final TableCell cell in row.cells) {
        if (shouldGetElement(cell.content)) {
          return cell.content;
        }
      }
    }
    return null;
  }
}

class TableRow {
  TableRow({
    required this.cells,
  });

  final Iterable<TableCell> cells;
}

class TableCell {
  TableCell({
    required this.content,
    this.width,
    this.height,
    this.padding,
  });

  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final SimpleContent content;
}
