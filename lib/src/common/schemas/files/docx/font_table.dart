import 'package:docx_transformer/src/common/namespaces.dart';
import 'package:xml/xml.dart';

import '../../../default/xml_defaults.dart';

/// Font data available here: https://fossies.org/linux/pandoc/data/docx/word/fontTable.xml
XmlDocument generateFontTableXML() => XmlDocument(
      [
        XmlDefaults.declaration,
        XmlElement(
          XmlName('w:fonts'),
          [
            XmlAttribute(XmlName('xmlns:mc'), namespaces['mc']!),
            XmlAttribute(XmlName('xmlns:r'), namespaces['r']!),
            XmlAttribute(XmlName('xmlns:w'), namespaces['w']!),
            XmlAttribute(XmlName('xmlns:w14'), namespaces['w14']!),
            XmlAttribute(XmlName('xmlns:wp14'), namespaces['wp14']!),
            XmlAttribute(XmlName('xmlns:w15'), namespaces['w15']!),
            XmlAttribute(XmlName('xmlns:w16cex'), namespaces['w16cex']!),
            XmlAttribute(XmlName('xmlns:w16cid'), namespaces['w16cid']!),
            XmlAttribute(XmlName('xmlns:w16'), namespaces['w16']!),
            XmlAttribute(XmlName('xmlns:w16sdtdh'), namespaces['w16sdtdh']!),
            XmlAttribute(XmlName('xmlns:w16se'), namespaces['w16se']!),
            XmlAttribute(XmlName('mc:Ignorable'), namespaces['ignorable']!),
          ],
          [
            // Fuente: Times New Roman
            XmlElement(
              XmlName('w:font'),
              [
                XmlAttribute(XmlName('w:name'), 'Times New Roman'),
              ],
              [
                XmlElement(
                  XmlName('w:panose1'),
                  [
                    XmlAttribute(XmlName('w:val'), '02020603050405020304'),
                  ],
                ),
                XmlElement(
                  XmlName('w:charset'),
                  [
                    XmlAttribute(XmlName('w:val'), '00'),
                  ],
                ),
                XmlElement(
                  XmlName('w:family'),
                  [
                    XmlAttribute(XmlName('w:val'), 'roman'),
                  ],
                ),
                XmlElement(
                  XmlName('w:pitch'),
                  [
                    XmlAttribute(XmlName('w:val'), 'variable'),
                  ],
                ),
                XmlElement(
                  XmlName('w:sig'),
                  [
                    XmlAttribute(XmlName('w:usb0'), 'E0002EFF'),
                    XmlAttribute(XmlName('w:usb1'), 'C000785B'),
                    XmlAttribute(XmlName('w:usb2'), '00000009'),
                    XmlAttribute(XmlName('w:usb3'), '00000000'),
                    XmlAttribute(XmlName('w:csb0'), '000001FF'),
                    XmlAttribute(XmlName('w:csb1'), '00000000'),
                  ],
                ),
              ],
            ),
            // Repite el mismo patrón para las demás fuentes...
          ],
        ),
      ],
    );
