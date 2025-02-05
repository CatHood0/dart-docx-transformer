// Note:
// The rsIds references the document styles
// into word/styles.xml
const String xmlParagraphNode = 'w:p';
// internals of <w:p>
// block
const String xmlParagraphBlockAttrsNode = 'w:pPr';

/// this is a node that specifies to the Word editor
/// that this sentence or paragraph has misspelled words
///
/// if you want to traverse between the errors placing them correctly
/// you will need to traverse in all Nodes of the <w:p> to avoid placing
/// the proof error in wrong sides.
///
/// ## Example:
///
/// <w:proofErr w:type="spellStart">
/// <w:r>
///  <w:t>text misspelled</w:t>
/// </w:r>
/// <w:proofErr w:type="spellEnd">
///
/// this example shows how you will need to traverse
/// between nodes, because, are placed by a different way of the
/// other XmlNodes
///
/// place type can be: "spellStart" or "spellEnd"
const String xmlProofErrorNode = 'w:proofErr', xmlProofErrorPlaceTypeNode = 'w:type';
// inline
/// <w:rPr> is always an internal node from <w:pPr> or <w:sdtPr>
/// _Note: when a part of text, has a different value from the common of the paragrah_
/// _<w:rPr> can be founded into <w:r>_
const String xmlParagraphInlineAttsrNode = 'w:rPr';

/// text
const String xmlTextNode = 'w:t', xmlTextPartNode = 'w:r';

/// <w:r> can be founded internally
// seems it works as paragraph node
const String xmlHyperlinkNode = 'w:hyperlink'; // r:id="" w:history="number"
// block attrs (<w:pPr> or <w:sdtContent>)
const String xmlListNode = 'w:numPr'; // this is always an internal node from w:pPr
const String xmlTabNode = 'w:tabs', xmlValueTabNode = 'w:tab'; // like tab indenting?
const String xmlSpacingNode = 'w:spacing';
const String xmlIndentNode = 'w:ind';
const String xmlAlignmentNode = 'w:jc';
const String xmlpStyleNode = 'w:pStyle'; // w:val="any_type_value"
const String xmlDirectionalNode = 'w:bidi';
//
// it can be inline and block level
const String xmlBackgroundCharacterColorNode = 'w:shd'; // w:val="hex"

/// represents the indentation of the list
const String xmlListIndentLevelNode = 'w:ilvl'; // w:val="number" = default "0"
/// represents the type of the list using a code num value
///  - 2 => bullet list
///  - 3 => ordered list
///  - ?
const String xmlListTypeNode = 'w:numId'; // w.val="number"
// internals of <w:rPr> and <w:pPr>
// inline attrs
const String xmlStyleNode = 'w:rStyle'; // w:val="any_type_value"
const String xmlFontsNode = 'w:rFonts'; // w:ascci="" w:hAnsi="" w:cs=""
const String xmlSizeFontNode = 'w:sz'; // w:val="number"
const String xmlUnderlineNode = 'w:u'; // w:val="single" = the basic underline used by Delta
const String xmlStrikethroughNode = 'w:strike'; //
const String xmlCharacterColorNode = 'w:color'; // w:val="hex"
const String xmlHighlightCharacterColorNode = 'w:highlight'; // w:val="color" > red, blue, orange, etc
// is an autoclosed node (<w:b/> or <w:bCs/>)
const String xmlBoldNode = 'w:b', xmlBoldCsNode = 'w:bCs';
// is an autoclosed node (<w:b/> or <w:bCs/>)
const String xmlItalicNode = 'w:i', xmlItalicCsNode = 'w:iCs';
const String xmlSizeCsFontNode = 'w:szCs'; // w:val="number"
const String xmlLanFontNode = 'w:lang'; // w:val="lan-code"

/// system control tags
const String xmlSdtNode = 'w:sdt';

/// internal of <w:std>
/// the internal inline nodes inside corresponds to the common used in <w:pPr>
const String xmlsdtParagraNode = 'w:sdtPr';
// block attributes
// internal of <w:sdtPr>
const String xmlSdtAliasNode = 'w:alias'; // w:val="value"
const String xmlSdtTagNode = 'w:tag'; // w:val="value_type"
// paragraph
// the internal nodes inside corresponds to the common used in <w:p>
// and even <w:p> can be founded
const String xmlSdtContentNode = 'w:sdtContent';
