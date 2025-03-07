import 'dart:typed_data';

import '../../docx_transformer.dart';
import '../util/predicate.dart';

enum ParseTo {
  odt,
  docx,
}

class BasicParserOptions extends ParserOptions {
  BasicParserOptions({
    required this.title,
    super.onDetectImage,
    this.subject = '',
    this.owner = '',
    this.description = '',
    this.lastModifiedBy = '',
    this.keywords = const <String>[],
    this.revisions = 1,
    this.properties,
  }) : super(ignoreColorWhenNoSupported: false);
  final String title;
  final String owner;
  final String subject;
  final String description;
  final String lastModifiedBy;
  final List<String> keywords;
  final int revisions;
  final DocumentProperties? properties;
}

abstract class ParserOptions {
  ParserOptions({
    required this.ignoreColorWhenNoSupported,
    this.onDetectImage,
    this.acceptFontValueWhen,
    this.acceptSizeValueWhen,
    this.acceptSpacingValueWhen,
    this.colorBuilder,
    this.checkColor,
    this.parseXmlSpacing,
    this.transformSizeValueTo,
  });

  final Predicate<String>? acceptFontValueWhen;
  final Predicate<String>? acceptSizeValueWhen;
  final Predicate<int>? acceptSpacingValueWhen;
  final bool ignoreColorWhenNoSupported;

  final String? Function(String? hex)? colorBuilder;
  final bool Function(String? hex)? checkColor;
  final Future<String?> Function(Uint8List bytes, String name)? onDetectImage;
  final ParseSpacingCallback? parseXmlSpacing;
  /// a way to build a custom size from Word
  /// to a know value for Quill Delta
  ///
  /// like: "28" can be converted to "huge"
  final String Function(String)? transformSizeValueTo;
}

class DeltaParserOptions extends ParserOptions {
  DeltaParserOptions({
    required this.shouldParserSizeToHeading,
    required super.onDetectImage,
    required super.ignoreColorWhenNoSupported,
    super.colorBuilder,
    super.checkColor,
    super.acceptSpacingValueWhen,
    super.acceptFontValueWhen,
    super.acceptSizeValueWhen,
    super.parseXmlSpacing,
    this.transformSizeToHeading,
    super.transformSizeValueTo,
    this.buildDeltaFromMisspelledOps,
  });

  /// a way to build a custom size from Word
  /// to a know value for Quill Delta
  ///
  /// like: "28" can be converted to "1"
  /// that will be saved as "header": 1
  final int Function(String)? transformSizeToHeading;

  /// This is a callback that decides if the operations
  /// founded at this point, contains misspelled attribute
  /// from &lt;w:proofErr/&gt;
  final PredicateMisspell? buildDeltaFromMisspelledOps;
  final ParseSizeToHeadingCallback? shouldParserSizeToHeading;
}

class DocxParserOptions extends ParserOptions {
  DocxParserOptions({
    required this.documentProperties,
    super.transformSizeValueTo,
    super.colorBuilder,
  }) : super(
          acceptFontValueWhen: null,
          acceptSizeValueWhen: null,
          acceptSpacingValueWhen: null,
          ignoreColorWhenNoSupported: false,
          checkColor: null,
          onDetectImage: _defaultOnDetectImage,
          parseXmlSpacing: null,
        );
  final DocumentProperties documentProperties;
}

Future<String?> _defaultOnDetectImage(Uint8List bytes, String name) async => null;
