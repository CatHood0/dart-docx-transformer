import 'package:xml/xml.dart' as xml;

import '../default/default_size_to_heading.dart';
import '../generators/convert_xml_styles_to_doc.dart';
import '../generators/hexadecimal_generator.dart';
import '../generators/styles_creator.dart';

/// Represents the common styles used by the document
///
/// Note: **all the styles into this class will be writted into [styles.xml]**
class DocumentStylesSheet {
  const DocumentStylesSheet({
    required this.styles,
    required this.paragraphStyleSheet,
  });

  factory DocumentStylesSheet.fromStyles(
    xml.XmlDocument styleDoc,
    ConverterFromXmlContext context, {
    bool computeIndents = false,
  }) {
    return DocumentStylesSheet(
      styles: convertXmlStylesToStyles(styleDoc, context, computeIndents: computeIndents),
      paragraphStyleSheet: null,
    );
  }

  /// These are the default styles applied to the paragraphs
  final ParagraphStyleSheet? paragraphStyleSheet;

  /// These are the global styles
  final List<Style> styles;

  /// Return a deep collection with the styles that contains the id that relatedWith param has
  ///
  /// If a internal style contains a link to another Style, will search to found a style that does
  /// not contain a relation
  Iterable<Iterable<Style>> getDeepRelationships(Style style) {
    if (style.relatedWith.isEmpty) return <Iterable<Style>>[];
    return styles.map((Style e) {
      if (e.relatedWith.isEmpty) return <Style>[e];
      return <Style>[e, ...?getRelationships(e)];
    });
  }

  Style getParentOf(Style style, {bool deep = false}) {
    final Style parent = styles.firstWhere(
      (Style s) => s.styleId == style.basedOn,
      orElse: Style.invalid,
    );
    if (parent.id != 'invalid') {
      if (parent.basedOn.isNotEmpty && deep) {
        return getParentOf(parent);
      }
      return parent;
    }
    return style;
  }

  /// Return all the styles that contains the id that relatedWith param has
  Iterable<Style>? getRelationships(Style style) {
    if (style.relatedWith.isEmpty) return null;
    return styles.where(
      (Style e) => e.id == style.relatedWith || e.styleId == style.relatedWith,
    );
  }

  Style? getStyleById(String id) {
    if (id.isEmpty) return null;
    return styles.firstWhere(
      (Style e) => e.id == id || e.styleId == id,
    );
  }

  Style? getStyleByName(String name) {
    if (name.isEmpty) return null;
    return styles.firstWhere(
      (Style e) => e.styleName == name,
    );
  }

  StyleConfigurator getParagraphStylesOf(Style style) {
    return style.configurators.firstWhere(
      (StyleConfigurator e) => e.propertyName == 'pPr',
      orElse: () => StyleConfigurator(propertyName: 'invalid'),
    );
  }

  StyleConfigurator getInlineParagraphStylesOf(Style style) {
    return style.configurators.firstWhere(
      (StyleConfigurator e) => e.propertyName == 'rPr',
      orElse: () => StyleConfigurator(propertyName: 'invalid'),
    );
  }
}

/// Represent the styles of the document
/// and will be builded automatically
///
/// Example:
///
/// Assume that we build a style like this
/// ```dart
/// final style = Style(
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
///   configurators: [
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
///   <w:name w:val="Header 1" />
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
class Style {
  Style({
    required this.type,
    required this.styleId,
    required this.styleName,
    this.defaultValue,
    this.configurators = const <StyleConfigurator>[],
    this.block,
    this.inline,
    this.extra,
    this.relatedWith = '',
    this.basedOn = '',
    String? id,
  }) : id = id ?? nanoid(8);

  factory Style.invalid() {
    return Style(
      id: 'invalid',
      type: 'invalid',
      styleId: 'invalid',
      styleName: 'invalid',
    );
  }
  // the internal identifier of this style
  late String id;
  final String type;

  /// Represents the id that will be used by the XmlNodes
  /// of Word to applies any existent style in style.xml
  final String styleId;

  /// The id of the another Style that has a
  /// relation with this
  final String relatedWith;

  final String basedOn;

  /// This is the name of the style that
  /// will be showed by the Word Editor
  final String styleName;
  final Object? defaultValue;
  final List<StyleConfigurator> configurators;

  /// correspond to the <w:pPr>
  final Map<String, dynamic>? block;

  /// correspond to the <w:rPr>
  final Map<String, dynamic>? inline;

  /// any extra data that need to be here
  final Map<String, dynamic>? extra;

  String toPrettyString() {
    return 'Style => $id\n'
        'Type: ${type.isEmpty ? 'no-type' : type},\n'
        'StyleId: $styleId, ${defaultValue ?? extra},\n'
        'Block: $block, \n'
        'inline: $inline,\n'
        'related with: $relatedWith, \n'
        'based on: $basedOn, \n'
        'Style name: $styleName\n'
        'SubStyles: ${configurators.join('\n')}\n';
  }

  @override
  String toString() {
    return 'Style($id, '
        '${type.isEmpty ? 'no-type' : type}, '
        '$styleId, ${defaultValue ?? extra}, '
        'block: $block, '
        'inline: $inline, '
        'related: $relatedWith, '
        'base on: $basedOn), '
        'Style name: $styleName => [$configurators]';
  }

  String toXmlString({bool useOnlyConfigurators = true}) {
    return '''
      <w:style type="$type" w:styleId="$styleId">
        <w:name w:val="$styleName" />
        ${relatedWith.isEmpty ? '<w:link w:val="$relatedWith" />' : ''}
        ${basedOn.isEmpty ? '<w:basedOn w:val="$basedOn" />' : ''}
        ${configurators.map(
              (StyleConfigurator c) => c.toXmlString(),
            ).join('\n')}
        ${useOnlyConfigurators ? '''
          <w:pPr>
            ${_buildXmlBlockAttributesString()}
          </w:pPr>
          <w:rPr>
            ${_buildXmlInlineAttributesString()}
          </w:rPr>
        ''' : ''}
      </w:style>
''';
  }

  String _buildXmlBlockAttributesString() {
    if (block == null || block!.isEmpty) return '';
    return '''''';
  }

  String _buildXmlInlineAttributesString() {
    if (inline == null || inline!.isEmpty) return '';
    final bool ignoreInlineSize = block?['header'] != null;
    return '''
      ${inline?['font'] == null ? '' : _buildXmlPart('rFonts', 'w:ascii="${inline!['font']}" '
            'w:hAnsi="${inline!['font']}" '
            'w:eastAsia="${inline!['font']}" '
            'w:cs="${inline!['font']}"', true)}
      ${!ignoreInlineSize && inline?['size'] == null ? '' : _buildXmlPart('size', 'w:val="${inline!['size']}"', true)}
      ${!ignoreInlineSize && inline?['size'] == null ? '' : _buildXmlPart('sizeCs', 'w:val="${inline!['size']}"', true)}
      ${!ignoreInlineSize ? '' : _buildXmlPart('size', 'w:val="${defaultHeadingToSize(block!['header'] as int)}"', true)}
      ${!ignoreInlineSize ? '' : _buildXmlPart('sizeCs', 'w:val="${defaultHeadingToSize(block!['header'] as int)}"', true)}
      ${inline?['bold'] == null ? '' : _buildXmlPart('b', '', true)}
      ${inline?['italic'] == null ? '' : _buildXmlPart('i', '', true)}
      ${inline?['underline'] == null ? '' : _buildXmlPart('u', '', true)}
      ${inline?['strikethrough'] == null ? '' : _buildXmlPart('strike', '', true)}
      ${inline?['script'] == null ? '' : _buildXmlPart('vertAlign', 'w:val="${inline!['script']}"', true)}
      ${inline?['color'] == null ? '' : _buildXmlPart('color', 'w:val="${inline!['color'].toString().replaceAll(
              '#',
              '',
            )}"', true)}
      ${inline?['background'] == null ? '' : _buildXmlPart('shd', 'w:val="${inline!['background'].toString().replaceAll(
              '#',
              '',
            )}"', true)}
    ''';
  }

  String _buildXmlPart(String localName, String attrs, bool isAutoClosure) {
    return '<w:$localName $attrs${isAutoClosure ? ' /' : ''}>${isAutoClosure ? '' : '</w:$localName>'}';
  }
}

//TODO: rework on this to be more easy to create sub part of a style (like adding spacing nodes and etc)
class StyleConfigurator {
  StyleConfigurator({
    required this.propertyName,
    this.value,
    this.attributes,
    this.configurators = const <StyleConfigurator>[],
  });
  // correspond to the node localname
  final String propertyName;
  final Object? value;
  final Map<String, dynamic>? attributes;
  final Iterable<StyleConfigurator> configurators;
  @override
  String toString() {
    return 'StyleConfigurator($propertyName, $value, $attributes)';
  }

  String toXmlString() {
    final bool needsEndNodeClosure = configurators.isNotEmpty;
    return '''
      <w:$propertyName${value != null ? ' w:val="$value"' : ''} '
      '${needsEndNodeClosure ? '' : '/'}>\n'
      '${configurators.map(
              (StyleConfigurator c) => c.toXmlString(),
            ).join('\n')} 
      ${needsEndNodeClosure ? '\n</w:$propertyName>' : ''}
    ''';
  }
}
