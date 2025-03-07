// Note:
// The rsIds references the document styles
// into word/styles.xml
const String localXmlKeyParagraphNode = 'p';
// internals of <p>
// block
const String localXmlKeyParagraphBlockAttrsNode = 'pPr';

/// this is a node that specifies to the Word editor
/// that this sentence or paragraph has misspelled words
///
/// if you want to traverse between the errors placing them correctly
/// you will need to traverse in all Nodes of the <p> to avoid placing
/// the proof error in wrong sides.
///
/// ## Example:
///
/// <proofErr type="spellStart">
/// <r>
///  <t>text misspelled</t>
/// </r>
/// <proofErr type="spellEnd">
///
/// this example shows how you will need to traverse
/// between nodes, because, are placed by a different way of the
/// other XmlNodes
///
/// place type can be: "spellStart" or "spellEnd"
const String localXmlKeyProofErrorNode = 'proofErr', xmlProofErrorPlaceTypeNode = 'type';
// inline
/// <w:rPr> is always an internal node from <w:pPr> or <w:sdtPr>
/// _Note: when a part of text, has a different value from the common of the paragrah_
/// _<w:rPr> can be founded into <w:r>_
const String localXmlKeyParagraphInlineAttrsNode = 'rPr';

/// text
const String localXmlKeyTextNode = 't', xmlTextPartNode = 'r';

/// <w:r> can be founded internally
// seems it works as paragraph node
const String localXmlKeyHyperlinkNode = 'hyperlink'; // r:id="" w:history="number"
// block attrs (<w:pPr> or <w:sdtContent>)
const String localXmlKeyListNode = 'numPr'; // this is always an internal node from w:pPr
const String localXmlKeyTabNode = 'tabs', xmlValueTabNode = 'tab'; // like tab indenting?
const String localXmlKeySpacingNode = 'spacing';
//                                                            `w:sz` correspond to the size of the border
// w:(top|left|bottom|right|between) w:val="none|single" w:color="hex" w:sz="size" w:space="num"
const String localXmlKeyBorderNode = 'pBdr';
const String localXmlKeyIndentNode = 'ind';
const String localXmlKeyAlignmentNode = 'jc';
const String localXmlKeypStyleNode = 'pStyle'; // w:val="any_type_value"
const String localXmlKeyDirectionalNode = 'bidi';
//
// it can be inline and block level
const String localXmlKeyBackgroundCharacterColorNode = 'shd'; // w:val="hex"

/// represents the indentation of the list
const String localXmlKeyListIndentLevelNode = 'ilvl'; // w:val="number" = default "0"
/// represents the type of the list using a code num value
///  - 2 => bullet list
///  - 3 => ordered list
///  - ?
const String localXmlKeyListTypeNode = 'numId'; // w.val="number"
// internals of <w:rPr> and <w:pPr>
// inline attrs
const String localXmlKeyStyleNode = 'rStyle'; // w:val="any_type_value"
const String localXmlKeyFontsNode = 'rFonts'; // w:ascci="" w:hAnsi="" w:eastAsia="" w:cs="" w:bidi=""

const String localXmlKeySizeFontNode = 'sz'; // w:val="number"
const String localXmlKeyUnderlineNode = 'u'; // val="single" = the basic underline used by Delta
const String localXmlKeyStrikethroughNode = 'strike'; //
const String localXmlKeyScriptNode = 'vertAlign'; // val="superscript" | val="subscript"
const String localXmlKeyCharacterColorNode = 'color'; // val="hex"
const String localXmlKeyHighlightCharacterColorNode = 'highlight'; // val="color" > red, blue, orange, etc
// is an autoclosed node (<b/> or <bCs/>)
const String localXmlKeyBoldNode = 'b', xmlBoldCsNode = 'bCs';
// is an autoclosed node (<b/> or <bCs/>)
const String localXmlKeyItalicNode = 'i', xmlItalicCsNode = 'iCs';
const String localXmlKeySizeCsFontNode = 'szCs'; // val="number"
const String localXmlKeyLanFontNode = 'lang'; // val="lan-code"

/// system control tags
const String localXmlKeySdtNode = 'sdt';

/// internal of <std>
/// the internal inline nodes inside corresponds to the common used in <pPr>
const String localXmlKeysdtParagraNode = 'sdtPr';
// block attributes
// internal of <sdtPr>
const String localXmlKeySdtAliasNode = 'alias'; // val="value"
const String localXmlKeySdtTagNode = 'tag'; // val="value_type"
// paragraph
// the internal nodes inside corresponds to the common used in <p>
// and even <p> can be founded
const String localXmlKeySdtContentNode = 'sdtContent';
