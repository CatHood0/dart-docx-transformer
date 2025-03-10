import 'package:xml/xml.dart' as xml;
import '../../util/predicate.dart';
import '../extensions/node_to_configurator.dart';
import '../styles.dart';

List<Style> convertXmlStylesToStyles(
  xml.XmlDocument styles, {
  bool computeIndents = false,
}) {
  final List<Style> result = <Style>[];

  final Iterable<xml.XmlElement> rawStyles = styles.findAllElements('w:style');
  if (rawStyles.isEmpty) return result;
  for (final xml.XmlElement styleElement in rawStyles) {
    final String type = styleElement.getAttribute('w:type') ?? '';
    final String styleId = styleElement.getAttribute('w:styleId') ?? '';
    final String rsId = styleElement.getElement('w:rsId')?.getAttribute('w:val') ?? '';
    final xml.XmlElement? nameElement = styleElement.getElement('w:name');
    final String styleName = nameElement?.getAttribute('w:val') ?? '';

    final List<StyleConfigurator> configurators = List<StyleConfigurator>.from(
      _buildConfigurators(
        styleElement,
      ),
    );

    result.add(
      Style(
        id: rsId.isEmpty ? null : rsId,
        type: type,
        styleId: styleId,
        styleName: styleName,
        configurators: configurators,
      ),
    );
  }
  return result;
}

Iterable<StyleConfigurator> _buildConfigurators(xml.XmlElement? element) {
  final List<StyleConfigurator> configurators = <StyleConfigurator>[];
  if (element == null) return configurators;
  for (final xml.XmlElement node in element.children.whereType<xml.XmlElement>()) {
    configurators.add(node.toConfigurator);
  }
  return configurators;
}

class ConverterFromXmlContext {
  ConverterFromXmlContext({
    required this.ignoreColorWhenNoSupported,
    required this.defaultTabStop,
    this.acceptFontValueWhen,
    this.acceptSizeValueWhen,
    this.acceptSpacingValueWhen,
    this.shouldParserSizeToHeading,
    this.parseSpacing,
    this.colorBuilder,
    this.checkColor,
  });

  ParseSizeToHeadingCallback? shouldParserSizeToHeading;
  ParseSpacingCallback? parseSpacing;
  bool Function(String? hex)? checkColor;
  final Predicate<String>? acceptFontValueWhen;
  final Predicate<String>? acceptSizeValueWhen;
  final Predicate<int>? acceptSpacingValueWhen;
  final bool ignoreColorWhenNoSupported;
  final String? Function(String? hex)? colorBuilder;
  final double defaultTabStop;
}
