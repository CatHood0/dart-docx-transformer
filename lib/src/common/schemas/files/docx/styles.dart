import 'package:xml/xml.dart';

import '../../../../../docx_transformer.dart';
import '../../../default/xml_defaults.dart';
import '../../../extensions/string_ext.dart';
import '../../../extensions/style_to_from_node.dart';

XmlDocument generateStylesXML(
  DocumentProperties properties,
) {
  final List<Style> styles = properties.docStyles.styles;
  final XmlDocument document = XmlDocument(
    <XmlNode>[
      XmlDefaults.declaration,
      XmlElement.tag(
        'w:styles',
        attributes: <XmlAttribute>[
          XmlAttribute('xmlns:mc'.toName(), '${namespaces['mc']}'),
          XmlAttribute('xmlns:r'.toName(), '${namespaces['r']}'),
          XmlAttribute('xmlns:w'.toName(), '${namespaces['w']}'),
          XmlAttribute('xmlns:w15'.toName(), '${namespaces['w15']}'),
          XmlAttribute('xmlns:w14'.toName(), '${namespaces['w14']}'),
          XmlAttribute('mc:Ignorable'.toName(), 'w14'),
        ],
        children: <XmlNode>[
          XmlElement.tag(
            'w:docDefaults',
            children: <XmlNode>[
              //blocks
              XmlElement.tag(
                'w:pPrDefault',
                children: <XmlNode>[
                  XmlElement.tag(
                    'w:pPr',
                    children: [
                      properties.docStyles.docDefaultParagraphStyles.toNode(),
                      XmlElement.tag(
                        'w:spacing',
                        attributes: [
                          XmlAttribute(XmlName('w:after'), '120'),
                          XmlAttribute(XmlName('w:line'), '240'),
                          XmlAttribute(XmlName('w:lineRule'), 'atLeast'),
                        ],
                      ),
                    ],
                    isSelfClosing: false,
                  )
                ],
                isSelfClosing: false,
              ),
              // inlines
              XmlElement(
                XmlName('w:rPrDefault'),
                <XmlAttribute>[],
                <XmlNode>[
                  XmlElement(
                    XmlName('w:rPr'),
                    <XmlAttribute>[],
                    <XmlNode>[
                      if (properties.docStyles.docDefaultInlineStyles().toNode() != null)
                        properties.docStyles.docDefaultInlineStyles().toNode()!,
                      XmlElement(XmlName('w:rFonts'), [
                        XmlAttribute(XmlName('w:ascii'), properties.editorSettings.fontFamily),
                        XmlAttribute(XmlName('w:eastAsiaTheme'), 'minorHAnsi'),
                        XmlAttribute(XmlName('w:hAnsiTheme'), 'minorHAnsi'),
                        XmlAttribute(XmlName('w:cstheme'), 'minorBidi'),
                      ]),
                      XmlElement(XmlName('w:sz'), [
                        XmlAttribute(XmlName('w:val'), '${properties.editorSettings.fontSize}'),
                      ]),
                      XmlElement(
                        XmlName('w:szCs'),
                        [
                          XmlAttribute(
                            XmlName('w:val'),
                            '${properties.editorSettings.complexScriptFontSize}',
                          ),
                        ],
                      ),
                      XmlElement(
                        XmlName('w:lang'),
                        [
                          XmlAttribute(XmlName('w:val'), properties.editorSettings.language),
                          XmlAttribute(XmlName('w:eastAsia'), properties.editorSettings.language),
                          XmlAttribute(XmlName('w:bidi'), 'ar-SA'),
                        ],
                      ),
                    ],
                    false,
                  ),
                ],
                false,
              ),
            ],
            isSelfClosing: false,
          ),
          ...styles.where(_avoidInvalidStyles).map<XmlElement>(
                (Style style) => style.toNode()!,
              ),
        ],
        isSelfClosing: false,
      ),
    ],
  );
  return document;
}

bool _avoidInvalidStyles(Style style) {
  return style.styleName == 'invalid' || style.styleId == 'invalid';
}
/*
    '''
  <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
  <w:styles xmlns:w="${namespaces['w']}" xmlns:r="${namespaces['r']}">
	<w:docDefaults>
	  <w:rPrDefault>
		<w:rPr>
		  <w:rFonts w:ascii="${properties.editorSettings.fontFamily}" w:eastAsiaTheme="minorHAnsi" w:hAnsiTheme="minorHAnsi" w:cstheme="minorBidi" />
		  <w:sz w:val="${properties.editorSettings.fontSize}" />
		  <w:szCs w:val="${properties.editorSettings.complexScriptFontSize}" />
		  <w:lang w:val="${properties.editorSettings.language}" w:eastAsia="${properties.editorSettings.language}" w:bidi="ar-SA" />
		</w:rPr>
	  </w:rPrDefault>
	  <w:pPrDefault>
		<w:pPr>
		  <w:spacing w:after="120" w:line="240" w:lineRule="atLeast" />
		</w:pPr>
	  </w:pPrDefault>
	</w:docDefaults>
	<w:style w:type="character" w:styleId="Hyperlink">
	  <w:name w:val="Hyperlink" />
	  <w:rPr>
		  <w:color w:val="0000FF" />
		  <w:u w:val="single" />
	  </w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="Heading1">
	  <w:name w:val="heading 1" />
	  <w:basedOn w:val="Normal" />
	  <w:next w:val="Normal" />
	  <w:uiPriority w:val="9" />
	  <w:qFormat />
	  <w:pPr>
		  <w:keepNext />
		  <w:keepLines />
		  <w:spacing w:before="480" />
		  <w:outlineLvl w:val="0" />
	  </w:pPr>
	  <w:rPr>
		  <w:b />
		  <w:sz w:val="48" />
		  <w:szCs w:val="48" />
	  </w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="Heading2">
	  <w:name w:val="heading 2" />
	  <w:basedOn w:val="Normal" />
	  <w:next w:val="Normal" />
	  <w:uiPriority w:val="9" />
	  <w:unhideWhenUsed />
	  <w:qFormat />
	  <w:pPr>
		  <w:keepNext />
		  <w:keepLines />
		  <w:spacing w:before="360" w:after="80" />
		  <w:outlineLvl w:val="1" />
	  </w:pPr>
	  <w:rPr>
		  <w:b />
		  <w:sz w:val="36" />
		  <w:szCs w:val="36" />
	  </w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="Heading3">
	  <w:name w:val="heading 3" />
	  <w:basedOn w:val="Normal" />
	  <w:next w:val="Normal" />
	  <w:uiPriority w:val="9" />
	  <w:semiHidden />
	  <w:unhideWhenUsed />
	  <w:qFormat />
	  <w:pPr>
		  <w:keepNext />
		  <w:keepLines />
		  <w:spacing w:before="280" w:after="80" />
		  <w:outlineLvl w:val="2" />
	  </w:pPr>
	  <w:rPr>
		  <w:b />
		  <w:sz w:val="28" />
		  <w:szCs w:val="28" />
	  </w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="Heading4">
	  <w:name w:val="heading 4" />
	  <w:basedOn w:val="Normal" />
	  <w:next w:val="Normal" />
	  <w:uiPriority w:val="9" />
	  <w:semiHidden />
	  <w:unhideWhenUsed />
	  <w:qFormat />
	  <w:pPr>
		  <w:keepNext />
		  <w:keepLines />
		  <w:spacing w:before="240" w:after="40" />
		  <w:outlineLvl w:val="3" />
	  </w:pPr>
	  <w:rPr>
		  <w:b />
		  <w:sz w:val="24" />
		  <w:szCs w:val="24" />
	  </w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="Heading5">
	  <w:name w:val="heading 5" />
	  <w:basedOn w:val="Normal" />
	  <w:next w:val="Normal" />
	  <w:uiPriority w:val="9" />
	  <w:semiHidden />
	  <w:unhideWhenUsed />
	  <w:qFormat />
	  <w:pPr>
		  <w:keepNext />
		  <w:keepLines />
		  <w:spacing w:before="220" w:after="40" />
		  <w:outlineLvl w:val="4" />
	  </w:pPr>
	  <w:rPr>
		  <w:b />
	  </w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="Heading6">
	  <w:name w:val="heading 6" />
	  <w:basedOn w:val="Normal" />
	  <w:next w:val="Normal" />
	  <w:uiPriority w:val="9" />
	  <w:semiHidden />
	  <w:unhideWhenUsed />
	  <w:qFormat />
	  <w:pPr>
		  <w:keepNext />
		  <w:keepLines />
		  <w:spacing w:before="200" w:after="40" />
		  <w:outlineLvl w:val="5" />
	  </w:pPr>
	  <w:rPr>
		  <w:b />
		  <w:sz w:val="20" />
		  <w:szCs w:val="20" />
	  </w:rPr>
	</w:style>
  </w:styles>
''';


*/
