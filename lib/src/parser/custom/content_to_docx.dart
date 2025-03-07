import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart' as xml;

import '../../../docx_transformer.dart';
import '../../common/default/default_document_styles.dart';
import '../../common/generators/media_creator.dart';
import '../../common/namespaces.dart';
import '../../common/schemas/common_node_keys/word_files_common.dart';
import '../../common/schemas/entities/relation_ship.dart';
import '../../common/schemas/files/docx/content_types.dart';
import '../../common/schemas/files/docx/core.dart';
import '../../common/schemas/files/docx/document_rels.dart';
import '../../common/schemas/files/docx/font_table.dart';
import '../../common/schemas/files/docx/numbering.dart';
import '../../common/schemas/files/docx/rels.dart';
import '../../common/schemas/files/docx/settings.dart';
import '../../common/schemas/files/docx/styles.dart';
import '../../common/schemas/files/docx/themes.dart';
import '../../common/schemas/files/docx/web_settings.dart';
import '../../constants.dart';

class ContentToDocx extends Parser<ContentContainer, Future<Uint8List?>?, BasicParserOptions> {
  ContentToDocx({
    required super.options,
  });

  @override
  Future<Uint8List?>? build({required ContentContainer data}) async {
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

    final (Map<String, ImageContent> images, Set<String> knowedExtensions) = getAllMedia(data);
    //TODO: register all extensions in Content_Types

    final Map<String, String> registeredMediaNames = {};
    final Map<String, MediaData> mediaRegistered = <String, MediaData>{};
    // build the xml relations ships
    final ArchiveFile documentRels = ArchiveFile.string(
      documentXmlRelsFilePath,
      generateDocumentXmlRels(
        (int lastId) => buildRelationShips(
          images,
          registeredMediaNames,
          lastId,
        ),
      ),
    );
    // build media data for the DocumentContext
    int lastMediaId = 1;
    for (final ImageContent img in images.values) {
      final MediaData media = MediaData(
        name: registeredMediaNames[img.id] as String,
        extension: img.data.extension,
        id: lastMediaId,
        bytes: img.data.bytes,
        imageIdReference: img.rId!,
      );
      img.data.name = media.name;
      mediaRegistered[media.name] = media;
      lastMediaId++;
    }

    final DocumentContext documentContext = DocumentContext(
      styles: options.properties?.docStyles ?? defaultDocumentStyles,
      media: mediaRegistered,
      properties: options.properties ?? defaultProperties,
    );

    final xml.XmlDocument docNode = data.toXml(context: documentContext);
    final EditorProperties editorProperties = defaultEditorProperties(content: data.toPlainText());

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
      ..add(rels);

    // add the media data into the zip
    for (final MediaData media in mediaRegistered.values) {
      archive.add(
        ArchiveFile.bytes(
          'word/media/${media.name}.${media.extension}',
          media.bytes,
        ),
      );
    }
    archive
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

  (Map<String, ImageContent>, Set<String>) getAllMedia(ContentContainer data) {
    final Map<String, ImageContent> images = <String, ImageContent>{};
    final Set<String> knowedExtensions = <String>{};
    for (final ParentContent parent in data.contents) {
      if (parent is ParagraphContent) {
        final ImageContent? image = parent.visitElement(
          (Content el) => el is ImageContent,
          visitChildrenIfNeeded: true,
        ) as ImageContent?;
        if (image != null) {
          images[image.id] = image;
          knowedExtensions.add(image.data.extension);
        }
        continue;
      }
      final ImageContent? image = parent.visitElement(
        (el) => el is ImageContent,
      ) as ImageContent?;
      if (image != null) {
        images[image.id] = image;
        knowedExtensions.add(image.data.extension);
      }
    }
    return (images, knowedExtensions);
  }

  List<RelationShip> buildRelationShips(
    Map<String, ImageContent> images,
    Map<String, String> registeredMediaNames,
    int lastId,
  ) {
    int lastMediaId = 1;
    return <RelationShip>[
      ...images.values.map(
        (ImageContent e) {
          if (e.rId == null) e.rId = 'rId${lastId + 1}';
          final String name = generateMediaName(
            lastMediaId,
            trim: true,
            isImage: true,
          );
          lastMediaId++;
          registeredMediaNames[e.id] = name;
          lastId++;
          return RelationShip(
            rId: e.rId!,
            target: 'media/$name.${e.data.extension}',
            type: namespaces['images']!,
          );
        },
      ),
    ];
  }
}
