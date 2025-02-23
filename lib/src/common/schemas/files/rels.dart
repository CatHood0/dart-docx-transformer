import 'package:docx_transformer/src/common/namespaces.dart';

/// Correspond to file _rels/.rels.xml
String generateRelsXml() => '''
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
      <Relationship Id="rId3" Type="${namespaces['extendedProperties']}" Target="docProps/app.xml" />
      <Relationship Id="rId2" Type="${namespaces['corePropertiesRelation']}" Target="docProps/core.xml" />
      <Relationship Id="rId1" Type="${namespaces['officeDocumentRelation']}" Target="word/document.xml" />
    </Relationships>
''';
