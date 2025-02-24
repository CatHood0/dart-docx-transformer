import 'package:docx_transformer/src/common/namespaces.dart' show namespaces;

String webSettingsXML() => '''
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>

    <w:webSettings xmlns:w="${namespaces['w']}" xmlns:r="${namespaces['r']}">
    </w:webSettings>
''';
