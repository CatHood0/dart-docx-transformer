import 'dart:typed_data';
import 'package:archive/archive_io.dart';
import 'package:xml/xml.dart';
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

class Options extends ParserOptions {
  Options({
    required super.onDetectImage,
    required this.title,
    this.subject = '',
    this.owner = '',
    this.description = '',
    this.lastModifiedBy = '',
    this.keywords = const <String>[],
    this.revisions = 1,
    this.properties,
  }) : super(ignoreColorWhenNoSupported: false);
  final String title;
  final String owner;
  final String subject;
  final String description;
  final String lastModifiedBy;
  final List<String> keywords;
  final int revisions;
  final DocumentProperties? properties;
}

class PlainTextToDocx extends Parser<String, Future<Uint8List?>, Options> {
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
          styles: defaultDocumentStyles,
          revisions: options.revisions,
        );

    final String docStr = _documentContentBuilder(data: data);

    final String content = generateDocumentXml(defaultProperties, docStr);
    final XmlDocument docNode = XmlDocument.parse(content);

    final EditorProperties editorProperties = defaultEditorProperties(content: data);

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

  String _documentContentBuilder({required String data}) {
    final List<String> paragraphs = data.split('\n');
    final StringBuffer buffer = StringBuffer();
    for (final String pr in paragraphs) {
      buffer.writeln(_nodeSectionBuilder('p', isClosure: false));
      final List<String> lines = pr.split(RegExp(r'\s'));
      for (int i = 0; i < lines.length; i++) {
        final String textPart = lines.elementAt(i);
        final bool isLast = lines.length - 1 == i;
        final String runStart = _nodeSectionBuilder('r', isClosure: false);
        final String content = _nodeBuilder('t', attributes: kDefaultPreserveWhitespaceMark, content: textPart);
        final String extraPartContent =
            isLast ? '' : _nodeBuilder('t', attributes: kDefaultPreserveWhitespaceMark, content: ' ');
        final String runEnd = _nodeSectionBuilder('r', isClosure: true);
        buffer.writeln('$runStart\n$content\n$runEnd');
        if (!isLast) {
          buffer.writeln('$runStart\n$extraPartContent\n$runEnd');
        }
      }
      buffer.writeln(
        _nodeSectionBuilder('p', isClosure: true),
      );
    }
    return '$buffer';
  }

  String _nodeSectionBuilder(
    String name, {
    Map<String, dynamic> attributes = const <String, dynamic>{},
    bool isClosure = false,
    bool isAutoClosure = false,
  }) {
    final String attrs = attributes.isEmpty
        ? ''
        : attributes.entries
            .map(
              (MapEntry<String, dynamic> e) => '${e.key}="${e.value}"',
            )
            .join(' ');
    return '''<${isClosure ? '/' : ''}w:$name$attrs${isAutoClosure ? ' /' : ''}>''';
  }

  String _nodeBuilder(
    String name, {
    Map<String, dynamic> attributes = const <String, dynamic>{},
    String content = '',
  }) {
    return '''<w:$name${attributes.isEmpty ? '' : ' ${attributes.entries.map(
          (MapEntry<String, dynamic> e) => '${e.key}="${e.value}"',
        ).join(' ')}'}>$content</w:$name>''';
  }
}
