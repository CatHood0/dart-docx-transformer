import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart' as xml;

import '../../../docx_transformer.dart';
import 'entities/content_container.dart';

class ContentToDocx extends Parser<ContentContainer, Uint8List?, DocxParserOptions> {
  ContentToDocx({
    required super.data,
    required super.options,
  });

  ZipDecoder? _zipDecoder;

  @override
  Uint8List? build() {
    if(data.contents.isEmpty) return null;
    _zipDecoder ??= ZipDecoder();
    xml.XmlDocument? styles;
    xml.XmlDocument? document;
    xml.XmlDocument? settings;
    xml.XmlDocument? documentRels;

    return null;
  }

  void _buildRelations() {

  }
}
