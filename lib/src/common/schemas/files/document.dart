import 'package:docx_transformer/docx_transformer.dart';
import 'package:docx_transformer/src/common/namespaces.dart';

String generateDocumentXml(DocumentProperties properties) => '''
  <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <w:document
     xmlns:a="${namespaces['a']}"
     xmlns:cdr="${namespaces['cdr']}"
     xmlns:o="${namespaces['o']}"
     xmlns:pic="${namespaces['pic']}"
     xmlns:r="${namespaces['r']}"
     xmlns:v="${namespaces['v']}"
     xmlns:ve="${namespaces['ve']}"
     xmlns:vt="${namespaces['vt']}"
     xmlns:w="${namespaces['w']}"
     xmlns:w10="${namespaces['w10']}"
     xmlns:wp="${namespaces['wp']}"
     xmlns:wne="${namespaces['wne']}"
    >
      <w:body>
        <w:sectPr>
          <w:pgSz 
            w:w="${properties.editorSettings.pageSize.width}" 
            w:h="${properties.editorSettings.pageSize.height}" 
            w:orient="${properties.orientation}" 
          />
          <w:pgMar w:top="${properties.margins.top}"
            w:right="${properties.margins.right}"
            w:bottom="${properties.margins.bottom}"
            w:left="${properties.margins.left}"
            w:header="${properties.margins.header}"
            w:footer="${properties.margins.footer}"
            w:gutter="${properties.margins.gutter}"
          />
        </w:sectPr>
      </w:body>
    </w:document>
''';
