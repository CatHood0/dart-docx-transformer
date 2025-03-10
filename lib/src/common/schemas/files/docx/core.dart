import 'package:xml/xml.dart';
import '../../../../../docx_transformer.dart';
import '../../../default/xml_defaults.dart';
import '../../../extensions/num_extensions.dart';
import '../../../extensions/string_ext.dart';
import '../../../namespaces.dart';

/// Correspond to file docProps/core.xml
XmlDocument generateCoreXml(DocumentProperties properties) =>
    XmlDocument(
      [
        XmlDefaults.declaration,
        XmlElement.tag(
          'cp:coreProperties',
          attributes: <XmlAttribute>[
            XmlAttribute('xmlns:cp'.toName(), namespaces['coreProperties']!),
            XmlAttribute('xmlns:dc'.toName(), namespaces['dc']!),
            XmlAttribute('xmlns:dcterms'.toName(), namespaces['dcterms']!),
            XmlAttribute('xmlns:dcmitype'.toName(), namespaces['dcmitype']!),
            XmlAttribute('xmlns:xsi'.toName(), namespaces['xsi']!),
          ],
          children: <XmlNode>[
            XmlElement.tag(
              'dc:title',
              children: [
                if (properties.title.isNotEmpty) XmlDefaults.text(properties.title),
              ],
              isSelfClosing: false,
            ),
            XmlElement.tag(
              'dc:subject',
              children: [
                if (properties.subject.isNotEmpty) XmlDefaults.text(properties.subject),
              ],
              isSelfClosing: false,
            ),
            XmlElement.tag(
              'dc:creator',
              children: [if (properties.owner.isNotEmpty) XmlText(properties.owner)],
              isSelfClosing: false,
            ),
            XmlElement.tag(
              'dc:keywords',
              children: [
                if (properties.keywords.isNotEmpty) XmlDefaults.text(properties.keywords),
              ],
              isSelfClosing: false,
            ),
            XmlElement.tag(
              'dc:description',
              children: [
                if (properties.description.isNotEmpty) XmlDefaults.text(properties.description),
              ],
              isSelfClosing: false,
            ),
            XmlElement.tag(
              'dc:lastModifiedBy',
              children: [
                if (properties.lastModifiedBy.isNotEmpty)
                  XmlDefaults.text(properties.lastModifiedBy),
              ],
              isSelfClosing: false,
            ),
            XmlElement.tag(
              'cp:revision',
              children: [
                XmlDefaults.text('${properties.revisions.nonNegative}'),
              ],
              isSelfClosing: false,
            ),
            XmlElement.tag(
              'dcterms:created',
              attributes: [XmlAttribute('xsi:type'.toName(), 'dcterms:W3CDTF')],
              children: [
                XmlDefaults.text(properties.createdAt.toUtc().toIso8601String()),
              ],
              isSelfClosing: false,
            ),
            XmlElement.tag(
              'dcterms:modified',
              attributes: [XmlAttribute('xsi:type'.toName(), 'dcterms:W3CDTF')],
              children: [
                XmlDefaults.text(properties.modifiedAt.toUtc().toIso8601String()),
              ],
              isSelfClosing: false,
            ),
          ],
          isSelfClosing: false,
        ),
      ],
    );
