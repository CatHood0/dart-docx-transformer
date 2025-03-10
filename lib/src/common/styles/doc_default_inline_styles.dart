import 'package:xml/xml.dart';
import '../schemas/common_node_keys/xml_keys.dart';

class DocDefaultInlineStyles {
  DocDefaultInlineStyles({
    this.script,
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.strike = false,
    this.foregroundColor,
    this.backgroundColor,
  });

  DocDefaultInlineStyles.base()
      : script = null,
        bold = false,
        italic = false,
        underline = false,
        strike = false,
        foregroundColor = null,
        backgroundColor = null;

  final bool bold;
  final bool italic;
  final bool underline;
  final bool strike;
  final String? script;
  final String? foregroundColor;
  final String? backgroundColor;

  XmlElement? toNode() {
    return null;
  }
}
