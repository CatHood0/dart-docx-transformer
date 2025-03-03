String paragraphStyles(ParagraphStyleSheet styles) =>
    ''' <w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:asciiTheme="minorHAnsi" w:eastAsiaTheme="minorEastAsia" w:hAnsiTheme="minorHAnsi" w:cstheme="minorBidi" /><w:kern w:val="2" /><w:sz w:val="24" /><w:szCs w:val="24" /><w:lang w:val="es-US" w:eastAsia="es-ES" w:bidi="ar-SA" /><w14:ligatures w14:val="standardContextual" /></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="160" w:line="278" w:lineRule="auto" /></w:pPr></w:pPrDefault></w:docDefaults>''';

/// Represents the styles used into the editor
class ParagraphStyleSheet {
  ParagraphStyleSheet({
    required this.blockStyles,
    required this.inlineStyles,
  });
  final ParagraphInlineStyleSheet inlineStyles;
  final ParagraphBlockStyleSheet blockStyles;
}

class ParagraphInlineStyleSheet {
  ParagraphInlineStyleSheet({
    required this.bold,
    required this.italic,
    required this.underline,
    required this.fontSize,
    required this.fontFamily,
    required this.lang,
    required this.ligatures,
  });

  factory ParagraphInlineStyleSheet.defaultStyle([int size = 24]) {
    return ParagraphInlineStyleSheet(
      bold: false,
      italic: false,
      underline: false,
      fontSize: !size.isNegative ? size : 24,
      fontFamily: 'Times New Roman',
      ligatures: true,
      lang: 'en-ES',
    );
  }
  final bool bold;
  final bool italic;
  final bool underline;
  final bool ligatures;
  final String fontFamily;
  final String lang;
  final int fontSize;
}

class ParagraphBlockStyleSheet {
  ParagraphBlockStyleSheet({
    this.spacing,
    this.alignment,
  });
  final String? alignment;
  final int? spacing;
}
