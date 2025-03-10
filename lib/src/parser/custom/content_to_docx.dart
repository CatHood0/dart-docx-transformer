import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart' as xml;

import '../../../docx_transformer.dart';
import '../../common/default/default_document_styles.dart';
import '../../common/extensions/string_ext.dart';
import '../../common/generators/media_creator.dart';
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

class ContentToDocx extends Parser<ContentContainer, Future<Uint8List?>?, ContentParserOptions> {
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
          styles: DefaultDocumentStyles.kDefaultDocumentStyleSheet,
          revisions: options.revisions,
        );

    final (Map<String, ImageContent> images, Set<String> knowedExtensions) = getAllMedia(data);
    final List<SimpleContent> hyperlinks = getAllHyperlinks(data);
    //TODO: register all extensions in Content_Types

    final Map<String, String> registeredMediaNames = {};
    final Map<String, MediaData> mediaRegistered = <String, MediaData>{};
    // build the xml relations ships
    final ArchiveFile documentRels = ArchiveFile.bytes(
      documentXmlRelsFilePath,
      stringToBytes(
        generateDocumentXmlRels(
          (int lastId) => buildRelationShips(
            hyperlinks: hyperlinks,
            images: images,
            registeredMediaNames: registeredMediaNames,
            lastId: lastId,
          ),
        ).toXmlString(),
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
        imageRefId: img.rId!,
      );
      img.data.name = media.name;
      mediaRegistered[media.name] = media;
      lastMediaId++;
    }

    final DocumentContext documentContext = DocumentContext(
      styles: options.properties?.docStyles ?? DefaultDocumentStyles.kDefaultDocumentStyleSheet,
      media: mediaRegistered,
      properties: options.properties ?? defaultProperties,
    );

    final xml.XmlDocument docNode = data.toXml(context: documentContext);

    final ArchiveFile document = ArchiveFile.bytes(
      documentFilePath,
      stringToBytes(
        docNode.toXmlString(),
      ),
    );
    final ArchiveFile styles = ArchiveFile.bytes(
      stylesXmlFilePath,
      stringToBytes(
        generateStylesXML(defaultProperties).toXmlString(),
      ),
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
      ..add(rels);

    // add the media data into the zip
    for (final MediaData media in mediaRegistered.values) {
      archive.add(
        ArchiveFile.bytes(
          'word/media/${media.name.removeAllWhitespaces()}.${media.extension}',
          media.bytes,
        ),
      );
    }
    archive
      ..add(core)
      ..add(document)
      ..add(styles)
      ..add(numbering)
      ..add(documentRels)
      ..add(themes)
      ..add(fontTable)
      ..add(settings)
      ..add(webSettings);

    return encoder.encodeBytes(archive);
  }

  List<RelationShip> buildRelationShips({
    required List<SimpleContent> hyperlinks,
    required Map<String, ImageContent> images,
    required Map<String, String> registeredMediaNames,
    required int lastId,
  }) {
    int lastMediaId = 1;
    return <RelationShip>[
      ...images.values.map<RelationShip>(
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
            target: 'media/${name.removeAllWhitespaces()}.${e.data.extension}',
            type: namespaces['images']!,
          );
        },
      ),
      ...hyperlinks.map<RelationShip>((SimpleContent hyperlink) {
        lastId++;
        if (hyperlink.rId == null) hyperlink.rId = 'rId$lastId';
        return RelationShip(
          rId: hyperlink.rId!,
          target: hyperlink.link,
          type: namespaces['hyperlinks']!,
          mode: 'External',
        );
      }),
    ];
  }

  List<SimpleContent> getAllHyperlinks(ContentContainer data) {
    final List<SimpleContent> hyperlinks = <SimpleContent>[];
    for (final ParentContent parent in data.contents) {
      final List<SimpleContent> hyperlink = List<SimpleContent>.from(
        parent.visitAllElement(
              (Content el) => el is SimpleContent && el.isLink,
              visitChildrenIfNeeded: true,
            ) ??
            <SimpleContent>[],
      );
      if (hyperlink.isNotEmpty) {
        hyperlinks.addAll(hyperlink);
      }
    }
    return hyperlinks;
  }

  (Map<String, ImageContent>, Set<String>) getAllMedia(ContentContainer data) {
    final Map<String, ImageContent> images = <String, ImageContent>{};
    final Set<String> knowedExtensions = <String>{};
    for (final ParentContent parent in data.contents) {
      if (parent is ParagraphContent) {
        final ImageContent? image = parent.visitElement(
          (Content el) =>
              el is ImageContent &&
              options.supportedFileExtensions.contains(
                el.data.extension,
              ),
          visitChildrenIfNeeded: true,
        ) as ImageContent?;
        if (image != null) {
          images[image.id] = image;
          knowedExtensions.add(image.data.extension);
        }
        continue;
      }
      final ImageContent? image = parent.visitElement(
        (el) =>
            el is ImageContent &&
            options.supportedFileExtensions.contains(
              el.data.extension,
            ),
      ) as ImageContent?;
      if (image != null) {
        images[image.id] = image;
        knowedExtensions.add(image.data.extension);
      }
    }
    return (images, knowedExtensions);
  }
}
