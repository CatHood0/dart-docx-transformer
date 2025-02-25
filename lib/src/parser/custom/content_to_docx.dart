import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart' as xml;

import '../../../docx_transformer.dart';
import '../../common/default/default_document_styles.dart';
import '../../common/schemas/common_node_keys/word_files_common.dart';
import '../../common/schemas/files/docx/content_types.dart';
import '../../common/schemas/files/docx/core.dart';
import '../../common/schemas/files/docx/document.dart';
import '../../common/schemas/files/docx/document_rels.dart';
import '../../common/schemas/files/docx/font_table.dart';
import '../../common/schemas/files/docx/numbering.dart';
import '../../common/schemas/files/docx/rels.dart';
import '../../common/schemas/files/docx/settings.dart';
import '../../common/schemas/files/docx/styles.dart';
import '../../common/schemas/files/docx/themes.dart';
import '../../common/schemas/files/docx/web_settings.dart';
import '../../constants.dart';
import 'entities/base/document_context.dart';
import 'entities/content_container.dart';
import 'entities/paragraph_content.dart';

class ContentToDocx extends Parser<ContentContainer, Uint8List?, BasicParserOptions> {
  ContentToDocx({
    required super.options,
  });

  @override
  Uint8List? build({required ContentContainer data}) {
    if (data.contents.isEmpty) return null;
    final ZipEncoder encoder = ZipEncoder();
    final Archive archive = Archive();
    final DocumentProperties defaultProperties = options.properties ??
        defaultDocumentProperties(
          title: options.title,
          owner: options.owner,
          subject: options.subject,
          description: options.description,
          lastModifiedBy: options.lastModifiedBy,
          keywords: options.keywords,
          styles: defaultDocumentStyles,
          revisions: options.revisions,
        );

    final String docStr = _documentContentBuilder(
      data: data,
      context: DocumentContext(
        styles: options.properties?.docStyles ?? defaultDocumentStyles,
        media: <String, MediaData>{},
      ),
    );
    final String content = generateDocumentXml(defaultProperties, docStr);
    final xml.XmlDocument docNode = xml.XmlDocument.parse(content);

    final EditorProperties editorProperties = defaultEditorProperties(content: data.toString());

    final ArchiveFile document = ArchiveFile.string('word/document.xml', docNode.toXmlString());
    final ArchiveFile styles = ArchiveFile.string(
      'word/styles.xml',
      generateStylesXML(defaultProperties),
    );

    final ArchiveFile core = ArchiveFile.string(
      coreFilePath,
      generateCoreXml(
        defaultProperties,
        editorProperties,
      ),
    );

    final ArchiveFile contentTypes = ArchiveFile.string(
      contentTypesPath,
      generateContentTypesXml(),
    );

    final ArchiveFile rels = ArchiveFile.string(
      relsFilePath,
      generateRelsXml(),
    );

    final ArchiveFile fontTable = ArchiveFile.string(
      fontTableXmlFilePath,
      generateFontTableXML(),
    );

    final ArchiveFile documentRels = ArchiveFile.string(
      documentXmlRelsFilePath,
      generateDocumentXmlRels(null),
    );

    final ArchiveFile numbering = ArchiveFile.string(
      numberingXmlFilePath,
      generateNumberingXMLTemplate(),
    );

    final ArchiveFile themes = ArchiveFile.string(
      themeXmlFilePath,
      generateThemesXml(),
    );

    final ArchiveFile settings = ArchiveFile.string(
      settingsXmlFilePath,
      generateSettingsXML(),
    );

    final ArchiveFile webSettings = ArchiveFile.string(
      webSettingsXmlFilePath,
      generateWebSettingsXML(),
    );

    archive
      ..add(contentTypes)
      ..add(rels)
      ..add(core)
      ..add(styles)
      ..add(numbering)
      ..add(fontTable)
      ..add(documentRels)
      ..add(document)
      ..add(settings)
      ..add(webSettings)
      ..add(themes);

    return encoder.encodeBytes(archive);
  }

  String _documentContentBuilder({required ContentContainer data, required DocumentContext context}) {
    final StringBuffer buffer = StringBuffer();
    for (final ParagraphContent pr in data.contents) {
      buffer.writeln(pr.buildXml(context: context));
    }
    return '$buffer';
  }
}
