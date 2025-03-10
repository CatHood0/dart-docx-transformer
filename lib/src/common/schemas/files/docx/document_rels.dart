import 'package:xml/xml.dart';
import '../../../default/xml_defaults.dart';
import '../../entities/relation_ship.dart';

/// Correspond to file word/_rels/document.xml.rels
///
XmlDocument generateDocumentXmlRels(RelationShipsBuilder? relationsBuilder) {
  return XmlDocument([
    XmlDefaults.declaration,
    XmlDefaults.relationships(
      children: relationsBuilder?.call(6).map<XmlElement>((RelationShip re) => re.toXml()) ?? <XmlElement>[],
      generateDefaultDocumentRelations: true,
    ),
  ]);
}
