import 'package:xml/xml.dart';

import '../../../default/xml_defaults.dart';
import '../../../namespaces.dart';

XmlDocument generateSettingsXML() => XmlDocument(
      [
        XmlDefaults.declaration,
        XmlElement(
          XmlName('w:settings'),
          [
            XmlAttribute(XmlName('xmlns:mc'), namespaces['mc']!),
            XmlAttribute(XmlName('xmlns:o'), namespaces['o']!),
            XmlAttribute(XmlName('xmlns:r'), namespaces['r']!),
            XmlAttribute(XmlName('xmlns:m'), namespaces['m']!),
            XmlAttribute(XmlName('xmlns:v'), namespaces['v']!),
            XmlAttribute(XmlName('xmlns:w10'), namespaces['w10']!),
            XmlAttribute(XmlName('xmlns:w'), namespaces['w']!),
            XmlAttribute(XmlName('xmlns:w14'), namespaces['w14']!),
            XmlAttribute(XmlName('xmlns:w15'), namespaces['w15']!),
            XmlAttribute(XmlName('xmlns:sl'), namespaces['sl']!),
            XmlAttribute(XmlName('mc:Ignorable'), 'w14 w15'),
          ],
          [
            XmlElement(
              XmlName('w:zoom'),
              [
                XmlAttribute(XmlName('w:percent'), '100'),
              ],
            ),
            XmlElement(
              XmlName('w:trackRevisions'),
              [
                XmlAttribute(XmlName('w:val'), 'false'),
              ],
            ),
            XmlElement(XmlName('w:documentProtection')),
            XmlElement(
              XmlName('w:defaultTabStop'),
              [
                XmlAttribute(XmlName('w:val'), '720'),
              ],
            ),
            XmlElement(
              XmlName('w:characterSpacingControl'),
              [
                XmlAttribute(XmlName('w:val'), 'doNotCompress'),
              ],
            ),
            XmlElement(
              XmlName('w:footnotePr'),
              [],
              [
                XmlElement(
                  XmlName('w:pos'),
                  [
                    XmlAttribute(XmlName('w:val'), 'pageBottom'),
                  ],
                ),
                XmlElement(
                  XmlName('w:numFmt'),
                  [
                    XmlAttribute(XmlName('w:val'), 'decimal'),
                  ],
                ),
                XmlElement(
                  XmlName('w:numStart'),
                  [
                    XmlAttribute(XmlName('w:val'), '1'),
                  ],
                ),
                XmlElement(
                  XmlName('w:numRestart'),
                  [
                    XmlAttribute(XmlName('w:val'), 'continuous'),
                  ],
                ),
                XmlElement(
                  XmlName('w:footnote'),
                  [
                    XmlAttribute(XmlName('w:id'), '-1'),
                  ],
                ),
                XmlElement(
                  XmlName('w:footnote'),
                  [
                    XmlAttribute(XmlName('w:id'), '0'),
                  ],
                ),
              ],
            ),
            XmlElement(
              XmlName('w:endnotePr'),
              [],
              [
                XmlElement(
                  XmlName('w:pos'),
                  [
                    XmlAttribute(XmlName('w:val'), 'docEnd'),
                  ],
                ),
                XmlElement(
                  XmlName('w:numFmt'),
                  [
                    XmlAttribute(XmlName('w:val'), 'lowerRoman'),
                  ],
                ),
                XmlElement(
                  XmlName('w:numStart'),
                  [
                    XmlAttribute(XmlName('w:val'), '1'),
                  ],
                ),
                XmlElement(
                  XmlName('w:numRestart'),
                  [
                    XmlAttribute(XmlName('w:val'), 'continuous'),
                  ],
                ),
                XmlElement(
                  XmlName('w:endnote'),
                  [
                    XmlAttribute(XmlName('w:id'), '-1'),
                  ],
                ),
                XmlElement(
                  XmlName('w:endnote'),
                  [
                    XmlAttribute(XmlName('w:id'), '0'),
                  ],
                ),
              ],
            ),
            XmlElement(
              XmlName('w:compat'),
              [],
              [
                XmlElement(
                  XmlName('w:compatSetting'),
                  [
                    XmlAttribute(XmlName('w:name'), 'compatibilityMode'),
                    XmlAttribute(XmlName('w:uri'), 'http://schemas.microsoft.com/office/word'),
                    XmlAttribute(XmlName('w:val'), '15'),
                  ],
                ),
                XmlElement(
                  XmlName('w:compatSetting'),
                  [
                    XmlAttribute(XmlName('w:name'), 'overrideTableStyleFontSizeAndJustification'),
                    XmlAttribute(XmlName('w:uri'), 'http://schemas.microsoft.com/office/word'),
                    XmlAttribute(XmlName('w:val'), '1'),
                  ],
                ),
                XmlElement(
                  XmlName('w:compatSetting'),
                  [
                    XmlAttribute(XmlName('w:name'), 'enableOpenTypeFeatures'),
                    XmlAttribute(XmlName('w:uri'), 'http://schemas.microsoft.com/office/word'),
                    XmlAttribute(XmlName('w:val'), '1'),
                  ],
                ),
                XmlElement(
                  XmlName('w:compatSetting'),
                  [
                    XmlAttribute(XmlName('w:name'), 'doNotFlipMirrorIndents'),
                    XmlAttribute(XmlName('w:uri'), 'http://schemas.microsoft.com/office/word'),
                    XmlAttribute(XmlName('w:val'), '1'),
                  ],
                ),
              ],
            ),
            XmlElement(XmlName('m:mathPr')),
            XmlElement(
              XmlName('w:themeFontLang'),
              [
                XmlAttribute(XmlName('w:val'), 'en-US'),
                XmlAttribute(XmlName('w:eastAsia'), 'zh-CN'),
              ],
            ),
            XmlElement(
              XmlName('w:clrSchemeMapping'),
              [
                XmlAttribute(XmlName('w:bg1'), 'light1'),
                XmlAttribute(XmlName('w:t1'), 'dark1'),
                XmlAttribute(XmlName('w:bg2'), 'light2'),
                XmlAttribute(XmlName('w:t2'), 'dark2'),
                XmlAttribute(XmlName('w:accent1'), 'accent1'),
                XmlAttribute(XmlName('w:accent2'), 'accent2'),
                XmlAttribute(XmlName('w:accent3'), 'accent3'),
                XmlAttribute(XmlName('w:accent4'), 'accent4'),
                XmlAttribute(XmlName('w:accent5'), 'accent5'),
                XmlAttribute(XmlName('w:accent6'), 'accent6'),
                XmlAttribute(XmlName('w:hyperlink'), 'hyperlink'),
                XmlAttribute(XmlName('w:followedHyperlink'), 'followedHyperlink'),
              ],
            ),
            XmlElement(
              XmlName('w:shapeDefaults'),
              [],
              [
                XmlElement(
                  XmlName('o:shapedefaults'),
                  [
                    XmlAttribute(XmlName('v:ext'), 'edit'),
                    XmlAttribute(XmlName('spidmax'), '1026'),
                    XmlAttribute(XmlName('strokecolor'), '000000'),
                  ],
                ),
                XmlElement(
                  XmlName('o:shapelayout'),
                  [
                    XmlAttribute(XmlName('v:ext'), 'edit'),
                  ],
                  [
                    XmlElement(
                      XmlName('o:idmap'),
                      [
                        XmlAttribute(XmlName('v:ext'), 'edit'),
                        XmlAttribute(XmlName('data'), '1'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            XmlElement(
              XmlName('w:decimalSymbol'),
              [
                XmlAttribute(XmlName('w:val'), '.'),
              ],
            ),
            XmlElement(
              XmlName('w:listSeparator'),
              [
                XmlAttribute(XmlName('w:val'), ','),
              ],
            ),
          ],
        ),
      ],
    );
