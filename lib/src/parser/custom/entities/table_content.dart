import 'package:flutter/widgets.dart';

import 'base/content.dart';
import 'base/document_context.dart';

class TableContent extends Content<TableData> {
  TableContent({
    required super.data,
    super.parent,
  });

  @override
  String buildXml({required DocumentContext context}) {
    return '';
  }

  @override
  String buildXmlStyle({required DocumentContext context}) {
    return '';
  }

  @override
  TableContent get copy => TableContent(data: data);
}

class TableData {
  TableData({
    required this.columns,
  });

  final Iterable<TableColumn> columns;
}

class TableColumn {
  TableColumn({
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
  final Content content;
}
