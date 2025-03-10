import 'package:xml/xml.dart';

import '../../../default/xml_defaults.dart';
import '../../../namespaces.dart';
import '../../common_node_keys/word_files_common.dart';

/// Correspond to file _rels/.rels.xml
XmlDocument generateRelsXml() => XmlDocument(
      [
        XmlDefaults.declaration,
        XmlDefaults.relationships(
          generateDefaultDocumentRelations: false,
          children: <XmlElement>[
            XmlDefaults.relation(rId: 'rId1', type: namespaces['extendedProperties']!, target: appFilePath),
            XmlDefaults.relation(rId: 'rId2', type: namespaces['corePropertiesRelation']!, target: coreFilePath),
            XmlDefaults.relation(rId: 'rId3', type: namespaces['officeDocumentRelation']!, target: documentFilePath),
          ],
        ),
      ],
    );

