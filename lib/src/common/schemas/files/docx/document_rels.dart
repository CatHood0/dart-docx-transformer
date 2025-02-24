import '../../../namespaces.dart';
import '../../entities/relation_ship.dart';

/// Correspond to file word/_rels/document.xml.rels
///
/// You should use this to create the image relationships
///
/// (relationships creates a way to references multimedia from word/media to the document.xml
/// and this file is related with word/media/[files] that adds all files with its binaries)
// Note: <Relationship Id="rId5" Type="${namespaces['images']}" Target="media/name_image.jpeg" />
String generateDocumentXmlRels(RelationShipsBuilder? relationsBuilder) => '''
  <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <Relationships xmlns="${namespaces['relationship']}">
      <Relationship Id="rId1" Type="${namespaces['settingsRelation']}" Target="settings.xml" />
      <Relationship Id="rId2" Type="${namespaces['themes']}" Target="theme/theme1.xml" />
      <Relationship Id="rId3" Type="${namespaces['styles']}" Target="styles.xml" />
      <Relationship Id="rId4" Type="${namespaces['numbering']}" Target="numbering.xml" />
      <Relationship Id="rId5" Type="${namespaces['fontTable']}" Target="fontTable.xml" />
      <Relationship Id="rId6" Type="${namespaces['webSettingsRelation']}" Target="webSettings.xml" />
      ${relationsBuilder?.call(6).map<String>((RelationShip re) => re.toXmlString(
          leftIndent: _kDefaultIndent,
        )).join('\n') ?? ''}
    </Relationships>
''';

const String _kDefaultIndent = '     ';
