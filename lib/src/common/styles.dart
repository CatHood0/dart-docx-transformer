import 'generators/hexadecimal_generator.dart';

/// Represent the styles of the document
class Style extends IterableConfigurators {
  Style({
    required this.type,
    required this.styleId,
    required this.styleName,
    this.defaultValue,
    super.configurators = const <StyleConfigurator>[],
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

  /// This is the name of the style that
  /// will be showed by the Word Editor
  final String styleName;
  final Object? defaultValue;

  String toPrettyString() {
    return 'Style => $id\n'
        'Type: ${type.isEmpty ? 'no-type' : type},\n'
        'StyleId: $styleId, '
        'Value: $defaultValue,\n'
        'Style name: $styleName\n'
        'SubStyles: ${configurators.join('\n')}\n';
  }

  @override
  String toString() {
    return 'Style($id, '
        '${type.isEmpty ? 'no-type' : type}, '
        '$styleId, '
        '$defaultValue), '
        'Style name: $styleName => [$configurators]';
  }

  String toXmlString() {
    final String xmlChildren = configurators
        .map(
          (StyleConfigurator c) => c.toXmlString(),
        )
        .join();
    return ' <w:style type="$type" w:styleId="$styleId">$xmlChildren</w:style>';
  }
}

class StyleConfigurator extends IterableConfigurators {
  StyleConfigurator.autoClosure({
    required this.propertyName,
    this.prefix,
    this.value,
    this.attributes,
    super.configurators = const <StyleConfigurator>[],
  }) : isAutoClosure = true;

  StyleConfigurator.invalid()
      : propertyName = 'invalid',
        prefix = '',
        value = null,
        attributes = null,
        isAutoClosure = false,
        super(configurators: const <StyleConfigurator>[]);

  StyleConfigurator.noAutoClosure({
    required this.propertyName,
    this.prefix,
    this.value,
    this.attributes,
    super.configurators = const <StyleConfigurator>[],
  }) : isAutoClosure = false;

  final String propertyName;
  final String? prefix;
  final Object? value;
  // the attributes of the node
  final Map<String, dynamic>? attributes;
  final bool isAutoClosure;

  bool get isInvalid =>
      propertyName == 'invalid' ||
      propertyName.isEmpty &&
          value == null &&
          (attributes == null || attributes!.isEmpty) &&
          configurators.isEmpty &&
          isAutoClosure;
  bool get hasChildren => configurators.isNotEmpty;

  @override
  String toString() {
    return 'StyleConfigurator($propertyName, $value, $attributes)';
  }

  String toXmlString() {
    final String styleValue = value != null ? ' w:val="$value"' : '';
    final String slashIfNeeded = isAutoClosure ? ' /' : '';
    final String xmlChildren = !hasChildren
        ? ''
        : configurators
            .map(
              (StyleConfigurator c) => c.toXmlString(),
            )
            .join();
    final String endOfNode = !isAutoClosure ? '</w:$propertyName>' : '';
    return '<w:$propertyName$styleValue$slashIfNeeded>$xmlChildren$endOfNode';
  }
}

abstract class IterableConfigurators {
  IterableConfigurators({
    required this.configurators,
  });

  final Iterable<StyleConfigurator> configurators;

  StyleConfigurator? get link {
    if (configurators.isEmpty) return null;
    return configurators.firstWhere((StyleConfigurator e) => e.propertyName == 'link',
        orElse: StyleConfigurator.invalid);
  }

  StyleConfigurator? get basedOn {
    if (configurators.isEmpty) return null;
    return configurators.firstWhere((StyleConfigurator e) => e.propertyName == 'basedOn',
        orElse: StyleConfigurator.invalid);
  }

  StyleConfigurator? get name {
    if (configurators.isEmpty) return null;
    return configurators.firstWhere((StyleConfigurator e) => e.propertyName == 'name',
        orElse: StyleConfigurator.invalid);
  }

  StyleConfigurator? getConfigurator(String matcher) {
    if (configurators.isEmpty) return null;
    return configurators.firstWhere((StyleConfigurator e) => e.propertyName == matcher,
        orElse: StyleConfigurator.invalid);
  }

  Iterable<StyleConfigurator> findAllElements(String matcher) {
    if (configurators.isEmpty) return <StyleConfigurator>[];
    return configurators.where(
      (StyleConfigurator e) => e.propertyName == matcher,
    );
  }
}
