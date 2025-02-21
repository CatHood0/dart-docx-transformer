import 'package:docx_transformer/src/common/generators/convert_xml_styles_to_doc.dart';
import 'package:docx_transformer/src/common/generators/hexadecimal_generator.dart';
import 'package:docx_transformer/src/common/generators/styles_creator.dart';
import 'package:xml/xml.dart' as xml;

/// Represents the common styles used by the document
///
/// Note: **all the styles into this class will be writted into [styles.xml]**
class DocumentStylesSheet {
  /// These are the default styles applied to the paragraphs
  final ParagraphStyleSheet? paragraphStyleSheet;

  /// These are the global styles
  final List<Styles> styles;

  const DocumentStylesSheet({
    required this.styles,
    required this.paragraphStyleSheet,
  });

  factory DocumentStylesSheet.fromStyles(
    xml.XmlDocument styleDoc,
    ConverterFromXmlContext context,
  ) {
    return DocumentStylesSheet(
      styles: convertXmlStylesToStyles(styleDoc, context),
      paragraphStyleSheet: null,
    );
  }

  /// Return all the styles that contains the id that relatedWith param has
  Iterable<Styles>? getRelationships(Styles style) {
    if (style.relatedWith.isEmpty) return null;
    return styles.where(
      (e) => e.id == style.relatedWith || e.styleId == style.relatedWith,
    );
  }

  /// Return a deep collection with the styles that contains the id that relatedWith param has
  ///
  /// If a internal style contains a link to another Style, will search to found a style that does
  /// not contain a relation
  Iterable<Iterable<Styles>> getDeepRelationships(Styles style) {
    if (style.relatedWith.isEmpty) return [];
    return styles.map((e) {
      if (e.relatedWith.isEmpty) return [e];
      return [e, ...?getRelationships(e)];
    });
  }

  Styles? getStyleById(String id) {
    if (id.isEmpty) return null;
    return styles.firstWhere(
      (e) => e.id == id || e.styleId == id,
    );
  }

  Styles? getStyleByName(String name) {
    if (name.isEmpty) return null;
    return styles.firstWhere(
      (e) => e.styleName == name,
    );
  }
}

class SubStyles {
  // correspond to the node localname
  final String propertyName;
  final Object? value;

  /// Represents the attributes of the [Node] style
  /// will be builded as a [XmlAttribute] if not null
  final Map<String, dynamic>? extraInfo;
  SubStyles({
    required this.propertyName,
    required this.value,
    required this.extraInfo,
  });
  @override
  String toString() {
    return 'SubStyles($propertyName, $value, $extraInfo)';
  }
}

/// Represent the styles of the document
/// and will be builded automatically
///
/// Example:
///
/// Assume that we build a style like this
/// ```dart
/// final style = Styles(
///   styleId: '624'
///   type: 'paragraph',
///   styleName: 'Header 1'
///   block: {
///     'header': 1,
///     'align': center,
///   },
///   inline: {
///     'font': 'Times new roman',
///     'size': 24,
///   },
///   subStyles: [
///     SubStyles(
///       propertyName: 'keepLines',
///       value: null,
///     ),
///     SubStyles(
///       propertyName: 'spacing',
///       value: null,
///       extraInfo: {'before': 360, 'after': 180},
///     ),
///   ],
/// );
/// ```
///
/// ```xml
/// <w:style type="paragraph" w:styleId="624">
///   <w:name w:val="Header 1"
///   <w:pPr>
///     <w:jc w:val="center"/>
///   </w:pPr>
///   </w:rPr>
///     <w:rFonts w:asciiTheme="Times new roman"/>
///     <w:size w:val="24"/>
///     <w:sizeCs w:val="24"/>
///   </w:rPr>
///   <w:keepLines />
///   <w:spacing w:before="360" w:after="180" />
/// </w:style>
/// ```
class Styles {
  // the internal identifier of this style
  late String id;
  final String type;

  /// Represents the id that will be used by the XmlNodes
  /// of Word to applies any existent style in style.xml
  final String styleId;

  /// The id of the another Style that has a
  /// relation with this
  final String relatedWith;

  ///
  final String baseOn;

  /// This is the name of the style that
  /// will be showed by the Word Editor
  final String styleName;
  final Object? defaultValue;
  final List<SubStyles> subStyles;

  /// correspond to the <w:pPr>
  final Map<String, dynamic>? block;

  /// correspond to the <w:rPr>
  final Map<String, dynamic>? inline;

  /// any extra data that need to be here
  final Map<String, dynamic>? extra;
  Styles({
    required this.type,
    required this.styleId,
    required this.styleName,
    this.defaultValue,
    this.subStyles = const [],
    this.block,
    this.inline,
    this.extra,
    this.relatedWith = '',
    this.baseOn = '',
    String? id,
  }) : id = id ?? nanoid(8);

  @override
  String toString() {
    return 'Styles($id, '
        '${type.isEmpty ? 'no-type' : type}, '
        '$styleId, ${defaultValue ?? extra}, '
        'block: $block, '
        'inline: $inline, '
        'related: $relatedWith, '
        'base on: $baseOn), '
        'Style name: $styleName => [$subStyles]';
  }

  String toPrettyString() {
    return 'Styles => $id\n'
        'Type: ${type.isEmpty ? 'no-type' : type},\n'
        'StyleId: $styleId, ${defaultValue ?? extra},\n'
        'Block: $block, \n'
        'inline: $inline,\n'
        'related with: $relatedWith, \n'
        'based on: $baseOn, \n'
        'Style name: $styleName\n'
        'SubStyles: ${subStyles.join('\n')}\n';
  }
}

// the exceptions where the common StyleSheet wont be applied
String defaultStyles() =>
    '''<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal" /><w:qFormat /></w:style><w:style w:type="paragraph" w:styleId="Ttulo1"><w:name w:val="heading 1" /><w:basedOn w:val="Normal" /><w:next w:val="Normal" /><w:link w:val="Ttulo1Car" /><w:uiPriority w:val="9" /><w:qFormat /><w:rsid w:val="00D11D86" /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="360" w:after="80" /><w:outlineLvl w:val="0" /></w:pPr><w:rPr><w:rFonts w:asciiTheme="majorHAnsi" w:eastAsiaTheme="majorEastAsia" w:hAnsiTheme="majorHAnsi" w:cstheme="majorBidi" /><w:color w:val="0F4761" w:themeColor="accent1" w:themeShade="BF" /><w:sz w:val="40" /><w:szCs w:val="40" /></w:rPr></w:style><w:style w:type="paragraph" w:styleId="Ttulo2"><w:name w:val="heading 2" /><w:basedOn w:val="Normal" /><w:next w:val="Normal" /><w:link w:val="Ttulo2Car" /><w:uiPriority w:val="9" /><w:semiHidden /><w:unhideWhenUsed /><w:qFormat /><w:rsid w:val="00D11D86" /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="160" w:after="80" /><w:outlineLvl w:val="1" /></w:pPr><w:rPr><w:rFonts w:asciiTheme="majorHAnsi" w:eastAsiaTheme="majorEastAsia" w:hAnsiTheme="majorHAnsi" w:cstheme="majorBidi" >

    </w:color w:val="0F4761" w:themeColor="accent1" w:themeShade="BF" /><w:sz w:val="32" /><w:szCs w:val="32" /></w:rPr></w:style><w:style w:type="paragraph" w:styleId="Ttulo3"><w:name w:val="heading 3" /><w:basedOn w:val="Normal" /><w:next w:val="Normal" /><w:link w:val="Ttulo3Car" /><w:uiPriority w:val="9" /><w:semiHidden /><w:unhideWhenUsed /><w:qFormat /><w:rsid w:val="00D11D86" /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="160" w:after="80" /><w:outlineLvl w:val="2" /></w:pPr><w:rPr><w:rFonts w:eastAsiaTheme="majorEastAsia" w:cstheme="majorBidi" /><w:color w:val="0F4761" w:themeColor="accent1" w:themeShade="BF" /><w:sz w:val="28" /><w:szCs w:val="28" /></w:rPr></w:style><w:style w:type="paragraph" w:styleId="Ttulo4"><w:name w:val="heading 4" /><w:basedOn w:val="Normal" /><w:next w:val="Normal" /><w:link w:val="Ttulo4Car" /><w:uiPriority w:val="9" /><w:semiHidden /><w:unhideWhenUsed /><w:qFormat /><w:rsid w:val="00D11D86" /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="80" w:after="40" /><w:outlineLvl w:val="3" /></w:pPr><w:rPr><w:rFonts w:eastAsiaTheme="majorEastAsia" w:cstheme="majorBidi" /><w:i /><w:iCs /><w:color w:val="0F4761" w:themeColor="accent1" w:themeShade="BF />

    <"/w:rPr></w:style><w:style w:type="paragraph" w:styleId="Ttulo5"><w:name w:val="heading 5" /><w:basedOn w:val="Normal" /><w:next w:val="Normal" /><w:link w:val="Ttulo5Car" /><w:uiPriority w:val="9" /><w:semiHidden /><w:unhideWhenUsed /><w:qFormat /><w:rsid w:val="00D11D86" /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="80" w:after="40" /><w:outlineLvl w:val="4" /></w:pPr><w:rPr><w:rFonts w:eastAsiaTheme="majorEastAsia" w:cstheme="majorBidi" /><w:color w:val="0F4761" w:themeColor="accent1" w:themeShade="BF" /></w:rPr></w:style><w:style w:type="paragraph" w:styleId="Ttulo6"><w:name w:val="heading 6" /><w:basedOn w:val="Normal" /><w:next w:val="Normal" /><w:link w:val="Ttulo6Car" /><w:uiPriority w:val="9" /><w:semiHidden /><w:unhideWhenUsed /><w:qFormat /><w:rsid w:val="00D11D86" /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="40" w:after="0" /><w:outlineLvl w:val="5" /></w:pPr><w:rPr><w:rFonts w:eastAsiaTheme="majorEastAsia" w:cstheme="majorBidi" /><w:i /><w:iCs /><w:color w:val="595959" w:themeColor="text1" w:themeTint="A6" /></w:rPr></w:style><w:style w:type="paragraph" w:styleId="Ttulo7"><w:name w:val="heading 7" /><w:basedOn w:val="Normal" /><w:next w:val="Normal" /><w:link w:val="Ttulo7Car" /><w:uiPriority w:val="9" /><w:semiHidden /><w:unhideWhenUsed /><w:qFormat /><w:rsid w:val="00D11D86" /><w:pPr><w:keepNext />

    <w:keepLines /><w:spacing w:before="40" w:after="0" /><w:outlineLvl w:val="6" /></w:pPr><w:rPr><w:rFonts w:eastAsiaTheme="majorEastAsia" w:cstheme="majorBidi" /><w:color w:val="595959" w:themeColor="text1" w:themeTint="A6" /></w:rPr></w:style><w:style w:type="paragraph" w:styleId="Ttulo8"><w:name w:val="heading 8" /><w:basedOn w:val="Normal" /><w:next w:val="Normal" /><w:link w:val="Ttulo8Car" /><w:uiPriority w:val="9" /><w:semiHidden /><w:unhideWhenUsed /><w:qFormat /><w:rsid w:val="00D11D86" /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:after="0" /><w:outlineLvl w:val="7" /></w:pPr><w:rPr><w:rFonts w:eastAsiaTheme="majorEastAsia" w:cstheme="majorBidi" /><w:i /><w:iCs /><w:color w:val="272727" w:themeColor="text1" w:themeTint="D8" /></w:rPr></w:style><w:style w:type="paragraph" w:styleId="Ttulo9"><w:name w:val="heading 9" /><w:basedOn w:val="Normal" /><w:next w:val="Normal" /><w:link w:val="Ttulo9Car" /><w:uiPriority w:val="9" /><w:semiHidden /><w:unhideWhenUsed /><w:qFormat /><w:rsid w:val="00D11D86" /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:after="0" /><w:outlineLvl w:val="8" /></w:pPr><w:rPr><w:rFonts w:eastAsiaTheme="majorEastAsia" w:cstheme="majorBidi" /><w:color w:val="272727" w:themeColor="text1" w:themeTint="D8" /></w:rPr></w:style><w:style w:type="character" w:default="1" w:styleId="Fuentedeprrafopredeter"><w:name w:val="Default Paragraph Font" /><w:uiPriority w:val="1" /><w:semiHidden /><w:unhideWhenUsed /></w:style><w:style w:type="table" w:default="1" w:styleId="Tablanormal"><w:name w:val="Normal Table" /><w:uiPriority w:val="99" /><w:semiHidden /><w:unhideWhenUsed /><w:tblPr><w:tblInd w:w="0" w:type="dxa" /><w:tblCellMar><w:top w:w="0" w:type="dxa" /><w:left w:w="108" w:type="dxa" /><w:bottom w:w="0" w:type="dxa" /><w:right w:w="108" w:type="dxa" /></w:tblCellMar></w:tblPr></w:style><w:style w:type="numbering" w:default="1" w:styleId="Sinlista"><w:name w:val="No List" /><w:uiPriority w:val="99" /><w:semiHidden /><w:unhideWhenUsed /></w:style><w:style w:type="character" w:customStyle="1" w:styleId="Ttulo1Car"><w:name w:val="Título 1 Car" /><w:basedOn w:val="Fuentedeprrafopredeter" /><w:link w:val="Ttulo1" /><w:uiPriority w:val="9" /><w:rsid w:val="00D11D86" /><w:rPr><w:rFonts w:asciiTheme="majorHAnsi" w:eastAsiaTheme="majorEastAsia" w:hAnsiTheme="majorHAnsi" w:cstheme="majorBidi" /><w:color w:val="0F4761" w:themeColor="accent1" w:themeShade="BF" /><w:sz w:val="40" /><w:szCs w:val="40" /></w:rPr></w:style><w:style w:type="character" w:customStyle="1" w:styleId="Ttulo2Car"><w:name w:val="Título 2 Car" /><w:basedOn w:val="Fuentedeprrafopredeter" /><w:link w:val="Ttulo2" /><w:uiPriority w:val="9" /><w:semiHidden /><w:rsid w:val="00D11D86" /><w:rPr><w:rFonts w:asciiTheme="majorHAnsi" w:eastAsiaTheme="majorEastAsia" w:hAnsiTheme="majorHAnsi" w:cstheme="majorBidi" /><w:color w:val="0F4761" w:themeColor="accent1" w:themeShade="BF" /><w:sz w:val="32" /><w:szCs w:val="32" /></w:rPr></w:style><w:style w:type="character" w:customStyle="1" w:styleId="Ttulo3Car"><w:name w:val="Título 3 Car" /><w:basedOn w:val="Fuentedeprrafopredeter" /><w:link w:val="Ttulo3" /><w:uiPriority w:val="9" /><w:semiHidden /><w:rsid w:val="00D11D86" /><w:rPr><w:rFonts w:eastAsiaTheme="majorEastAsia" w:cstheme="majorBidi" /><w:color w:val="0F4761" w:themeColor="accent1" w:themeShade="BF" /><w:sz w:val="28" /><w:szCs w:val="28" /></w:rPr></w:style><w:style w:type="character" w:customStyle="1" w:styleId="Ttulo4Car"><w:name w:val="Título 4 Car" /><w:basedOn w:val="Fuentedeprrafopredeter" /><w:link w:val="Ttulo4" /><w:uiPriority w:val="9" /><w:semiHidden /><w:rsid w:val="00D11D86" /><w:rPr><w:rFonts w:eastAsiaTheme="majorEastAsia" w:cstheme="majorBidi" /><w:i /><w:iCs /><w:color w:val="0F4761" w:themeColor="accent1" w:themeShade="BF" /></w:rPr></w:style><w:style w:type="character" w:customStyle="1" w:styleId="Ttulo5Car"><w:name w:val="Título 5 Car" /><w:basedOn w:val="Fuentedeprrafopredeter" /><w:link w:val="Ttulo5" /><w:uiPriority w:val="9" /><w:semiHidden /><w:rsid w:val="00D11D86" /><w:rPr><w:rFonts w:eastAsiaTheme="majorEastAsia" w:cstheme="majorBidi" /><w:color w:val="0F4761" w:themeColor="accent1" w:themeShade="BF" /></w:rPr></w:style><w:style w:type="character" w:customStyle="1" w:styleId="Ttulo6Car"><w:name w:val="Título 6 Car" /><w:basedOn w:val="Fuentedeprrafopredeter" /><w:link w:val="Ttulo6" /><w:uiPriority w:val="9" /><w:semiHidden /><w:rsid w:val="00D11D86" /><w:rPr><w:rFonts w:eastAsiaTheme="majorEastAsia" w:cstheme="majorBidi" /><w:i /><w:iCs /><w:color w:val="595959" w:themeColor="text1" w:themeTint="A6" /></w:rPr></w:style><w:style w:type="character" w:customStyle="1" w:styleId="Ttulo7Car"><w:name w:val="Título 7 Car" /><w:basedOn w:val="Fuentedeprrafopredeter" /><w:link w:val="Ttulo7" /><w:uiPriority w:val="9" /><w:semiHidden /><w:rsid w:val="00D11D86" /><w:rPr><w:rFonts w:eastAsiaTheme="majorEastAsia" w:cstheme="majorBidi" /><w:color w:val="595959" w:themeColor="text1" w:themeTint="A6" /></w:rPr></w:style><w:style w:type="character" w:customStyle="1" w:styleId="Ttulo8Car"><w:name w:val="Título 8 Car" /><w:basedOn w:val="Fuentedeprrafopredeter" /><w:link w:val="Ttulo8" /><w:uiPriority w:val="9" /><w:semiHidden /><w:rsid w:val="00D11D86" /><w:rPr><w:rFonts w:eastAsiaTheme="majorEastAsia" w:cstheme="majorBidi" /><w:i /><w:iCs /><w:color w:val="272727" w:themeColor="text1" w:themeTint="D8" /></w:rPr></w:style><w:style w:type="character" w:customStyle="1" w:styleId="Ttulo9Car"><w:name w:val="Título 9 Car" /><w:basedOn w:val="Fuentedeprrafopredeter" /><w:link w:val="Ttulo9" /><w:uiPriority w:val="9" /><w:semiHidden /><w:rsid w:val="00D11D86" /><w:rPr><w:rFonts w:eastAsiaTheme="majorEastAsia" w:cstheme="majorBidi" /><w:color w:val="272727" w:themeColor="text1" w:themeTint="D8" /></w:rPr></w:style><w:style w:type="paragraph" w:styleId="Ttulo"><w:name w:val="Title" /><w:basedOn w:val="Normal" /><w:next w:val="Normal" /><w:link w:val="TtuloCar" /><w:uiPriority w:val="10" /><w:qFormat /><w:rsid w:val="00D11D86" /><w:pPr><w:spacing w:after="80" w:line="240" w:lineRule="auto" /><w:contextualSpacing /></w:pPr><w:rPr><w:rFonts w:asciiTheme="majorHAnsi" w:eastAsiaTheme="majorEastAsia" w:hAnsiTheme="majorHAnsi" w:cstheme="majorBidi" /><w:spacing w:val="-10" /><w:kern w:val="28" /><w:sz w:val="56" /><w:szCs w:val="56" /></w:rPr></w:style><w:style w:type="character" w:customStyle="1" w:styleId="TtuloCar"><w:name w:val="Título Car" /><w:basedOn w:val="Fuentedeprrafopredeter" /><w:link w:val="Ttulo" /><w:uiPriority w:val="10" /><w:rsid w:val="00D11D86" /><w:rPr><w:rFonts w:asciiTheme="majorHAnsi" w:eastAsiaTheme="majorEastAsia" w:hAnsiTheme="majorHAnsi" w:cstheme="majorBidi" /><w:spacing w:val="-10" /><w:kern w:val="28" /><w:sz w:val="56" /><w:szCs w:val="56" /></w:rPr></w:style><w:style w:type="paragraph" w:styleId="Subttulo"><w:name w:val="Subtitle" /><w:basedOn w:val="Normal" /><w:next w:val="Normal" /><w:link w:val="SubttuloCar" /><w:uiPriority w:val="11" /><w:qFormat /><w:rsid w:val="00D11D86" /><w:pPr><w:numPr><w:ilvl w:val="1" /></w:numPr></w:pPr><w:rPr><w:rFonts w:eastAsiaTheme="majorEastAsia" w:cstheme="majorBidi" /><w:color w:val="595959" w:themeColor="text1" w:themeTint="A6" /><w:spacing w:val="15" /><w:sz w:val="28" /><w:szCs w:val="28" /></w:rPr></w:style><w:style w:type="character" w:customStyle="1" w:styleId="SubttuloCar"><w:name w:val="Subtítulo Car" /><w:basedOn w:val="Fuentedeprrafopredeter" /><w:link w:val="Subttulo" /><w:uiPriority w:val="11" /><w:rsid w:val="00D11D86" /><w:rPr><w:rFonts w:eastAsiaTheme="majorEastAsia" w:cstheme="majorBidi" /><w:color w:val="595959" w:themeColor="text1" w:themeTint="A6" /><w:spacing w:val="15" /><w:sz w:val="28" /><w:szCs w:val="28" /></w:rPr></w:style><w:style w:type="paragraph" w:styleId="Cita"><w:name w:val="Quote" /><w:basedOn w:val="Normal" /><w:next w:val="Normal" /><w:link w:val="CitaCar" /><w:uiPriority w:val="29" /><w:qFormat /><w:rsid w:val="00D11D86" /><w:pPr><w:spacing w:before="160" /><w:jc w:val="center" /></w:pPr><w:rPr><w:i /><w:iCs /><w:color w:val="404040" w:themeColor="text1" w:themeTint="BF" /></w:rPr></w:style><w:style w:type="character" w:customStyle="1" w:styleId="CitaCar"><w:name w:val="Cita Car" /><w:basedOn w:val="Fuentedeprrafopredeter" /><w:link w:val="Cita" /><w:uiPriority w:val="29" /><w:rsid w:val="00D11D86" /><w:rPr><w:i /><w:iCs /><w:color w:val="404040" w:themeColor="text1" w:themeTint="BF" /></w:rPr></w:style><w:style w:type="paragraph" w:styleId="Prrafodelista"><w:name w:val="List Paragraph" /><w:basedOn w:val="Normal" /><w:uiPriority w:val="34" /><w:qFormat /><w:rsid w:val="00D11D86" /><w:pPr><w:ind w:left="720" /><w:contextualSpacing /></w:pPr></w:style><w:style w:type="character" w:styleId="nfasisintenso"><w:name w:val="Intense Emphasis" /><w:basedOn w:val="Fuentedeprrafopredeter" /><w:uiPriority w:val="21" /><w:qFormat /><w:rsid w:val="00D11D86" /><w:rPr><w:i /><w:iCs /><w:color w:val="0F4761" w:themeColor="accent1" w:themeShade="BF" /></w:rPr></w:style><w:style w:type="paragraph" w:styleId="Citadestacada"><w:name w:val="Intense Quote" /><w:basedOn w:val="Normal" /><w:next w:val="Normal" /><w:link w:val="CitadestacadaCar" /><w:uiPriority w:val="30" /><w:qFormat /><w:rsid w:val="00D11D86" /><w:pPr><w:pBdr><w:top w:val="single" w:sz="4" w:space="10" w:color="0F4761" w:themeColor="accent1" w:themeShade="BF" /><w:bottom w:val="single" w:sz="4" w:space="10" w:color="0F4761" w:themeColor="accent1" w:themeShade="BF" /></w:pBdr><w:spacing w:before="360" w:after="360" /><w:ind w:left="864" w:right="864" /><w:jc w:val="center" /></w:pPr><w:rPr><w:i /><w:iCs /><w:color w:val="0F4761" w:themeColor="accent1" w:themeShade="BF" /></w:rPr></w:style><w:style w:type="character" w:customStyle="1" w:styleId="CitadestacadaCar"><w:name w:val="Cita destacada Car" /><w:basedOn w:val="Fuentedeprrafopredeter" /><w:link w:val="Citadestacada" /><w:uiPriority w:val="30" /><w:rsid w:val="00D11D86" /><w:rPr><w:i /><w:iCs /><w:color w:val="0F4761" w:themeColor="accent1" w:themeShade="BF" /></w:rPr></w:style><w:style w:type="character" w:styleId="Referenciaintensa"><w:name w:val="Intense Reference" /><w:basedOn w:val="Fuentedeprrafopredeter" /><w:uiPriority w:val="32" /><w:qFormat /><w:rsid w:val="00D11D86" /><w:rPr><w:b /><w:bCs /><w:smallCaps /><w:color w:val="0F4761" w:themeColor="accent1" w:themeShade="BF" /><w:spacing w:val="5" /></w:rPr></w:style></w:styles>
''';
