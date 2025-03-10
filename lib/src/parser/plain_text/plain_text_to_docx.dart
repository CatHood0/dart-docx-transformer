import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive_io.dart';
import 'package:xml/xml.dart';
import '../../../docx_transformer.dart';
import '../../common/default/default_document_styles.dart';
import '../../common/default/xml_defaults.dart';
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

class PlainTextToDocx extends Parser<String, Future<Uint8List?>, BasicParserOptions> {
  PlainTextToDocx({
    required super.options,
  });

  @override
  Future<Uint8List> build({required String data}) async {
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
          styles: DefaultDocumentStyles.kDefaultDocumentStyleSheet,
          revisions: options.revisions,
        );

    final List<XmlElement> contents = _documentContentBuilder(data: data);
    final XmlDocument docNode = generateDocumentXml(defaultProperties, contents: contents);

    final ArchiveFile document = ArchiveFile.bytes(
      'word/document.xml',
      stringToBytes(
        docNode.toXmlString(),
      ),
    );
    final ArchiveFile styles = ArchiveFile.bytes(
      'word/styles.xml',
      stringToBytes(generateStylesXML(defaultProperties).toXmlString()),
    );

    final ArchiveFile core = ArchiveFile.bytes(
      coreFilePath,
      stringToBytes(
        generateCoreXml(
          defaultProperties,
        ).toXmlString(),
      ),
    );

    final ArchiveFile contentTypes = ArchiveFile.bytes(
      contentTypesPath,
      stringToBytes(
        generateContentTypesXml().toXmlString(),
      ),
    );

    final ArchiveFile rels = ArchiveFile.bytes(
      relsFilePath,
      stringToBytes(
        generateRelsXml().toXmlString(),
      ),
    );

    final ArchiveFile fontTable = ArchiveFile.bytes(
      fontTableXmlFilePath,
      stringToBytes(
        generateFontTableXML().toXmlString(),
      ),
    );

    final ArchiveFile documentRels = ArchiveFile.bytes(
      documentXmlRelsFilePath,
      stringToBytes(
        generateDocumentXmlRels(null).toXmlString(),
      ),
    );

    final ArchiveFile numbering = ArchiveFile.bytes(
      numberingXmlFilePath,
      stringToBytes(
        generateNumberingXMLTemplate().toXmlString(),
      ),
    );

    final ArchiveFile themes = ArchiveFile.bytes(
      themeXmlFilePath,
      stringToBytes(
        generateThemesXml(),
      ),
    );

    final ArchiveFile settings = ArchiveFile.bytes(
      settingsXmlFilePath,
      stringToBytes(
        generateSettingsXML().toXmlString(),
      ),
    );

    final ArchiveFile webSettings = ArchiveFile.bytes(
      webSettingsXmlFilePath,
      stringToBytes(
        generateWebSettingsXML().toXmlString(),
      ),
    );

    archive
      ..add(contentTypes)
      ..add(rels)
      ..add(core)
      ..add(document)
      ..add(styles)
      ..add(numbering)
      ..add(fontTable)
      ..add(documentRels)
      ..add(themes)
      ..add(settings)
      ..add(webSettings);

    return encoder.encodeBytes(archive);
  }

  List<XmlElement> _documentContentBuilder({required String data}) {
    final List<String> lines = const LineSplitter().convert(data);
    final List<XmlElement> buffer = <XmlElement>[];
    for (final String text in lines) {
      buffer.add(
        XmlDefaults.paragraphTag(
          text,
          extraChildren: XmlDefaults.paragraphStyles,
        ),
      );
    }
    return buffer;
  }
}
