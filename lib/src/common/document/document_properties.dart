import '../../../docx_transformer.dart';
import '../../constants.dart';
import 'document_margins.dart';

/// Represents the common properties to be filled
/// in the document. E.g: subject, owner, modified date,
/// revisions, etc
class DocumentProperties {
  DocumentProperties({
    required this.lastModifiedBy,
    required this.owner,
    required this.subject,
    required this.title,
    required this.modifiedAt,
    required this.description,
    required this.createdAt,
    required this.revisions,
    required this.editorSettings,
    required this.orientation,
    DocumentMargins? margins,
    List<String> keywords = const <String>[],
    DocumentStylesSheet? styles,
  })  : docStyles = styles ?? DocumentStylesSheet.base(),
        standalone = 'yes',
        keywords = keywords.join(','),
        encoding = 'UTF-8' {
    final bool isPortraitOrientation = orientation == defaultOrientation;
    final double height = !editorSettings.pageSize.height.isNegative
        ? editorSettings.pageSize.height
        : landscapeHeight;
    final double width =
        !editorSettings.pageSize.width.isNegative ? editorSettings.pageSize.width : landscapeWidth;

    // we probably want to update the pageSize param if the orientation passed
    // is already
    editorSettings.pageSize = PageSize(
      width: isPortraitOrientation ? width : height,
      height: isPortraitOrientation ? height : width,
    );
    this.margins = margins ?? (isPortraitOrientation ? portraitMargins : landscapeMargins);
    availableDocumentSpace = editorSettings.pageSize.width - this.margins.left - this.margins.right;
  }
  factory DocumentProperties.blank({String? owner}) {
    return DocumentProperties(
      lastModifiedBy: owner ?? '',
      owner: owner ?? '',
      subject: '',
      title: '',
      revisions: 1,
      modifiedAt: DateTime.now(),
      description: '',
      createdAt: DateTime.now(),
      editorSettings: EditorSettings.basic(),
      orientation: Orientation.portrait,
      keywords: const <String>[],
      styles: null,
    );
  }

  /// name of the person
  /// that makes the last modify to the document
  final String title;
  final String description;
  final String owner;
  final String subject;
  final String lastModifiedBy;
  final String keywords;

  final String encoding;
  final Orientation orientation;

  /// [standalone] Indicates whether the document relies on external entities or not. It can have two values:
  /// * standalone="yes": The document is self-contained and does not depend on external entities (e.g., external DTDs or schemas).
  /// * standalone="no": The document may rely on external entities.
  final String standalone;
  final DateTime modifiedAt;
  final DateTime createdAt;
  final DocumentStylesSheet docStyles;
  final EditorSettings editorSettings;
  final int revisions;

  late final DocumentMargins margins;

  late final double availableDocumentSpace;
}

class EditorSettings {
  EditorSettings({
    required this.fontFamily,
    required this.fontSize,
    required this.headerType,
    required this.showHeader,
    required this.footerType,
    required this.showFooter,
    required this.pageSize,
    required this.language,
    required this.defaultOrderedListStyleType,
    required this.showPageNumber,
    required this.showLineNumber,
    required this.lineNumberOptions,
    required this.decodeUnicode,
    required this.complexScriptFontSize,
  });
  factory EditorSettings.basic({PageSize? size}) {
    return EditorSettings(
      fontFamily: defaultFont,
      fontSize: defaultFontSize,
      complexScriptFontSize: defaultFontSize,
      headerType: 'default',
      showHeader: false,
      footerType: 'default',
      showFooter: false,
      pageSize: size ?? PageSize.zero(),
      language: defaultLang,
      defaultOrderedListStyleType: 'decimal',
      showPageNumber: false,
      showLineNumber: false,
      lineNumberOptions: <String, dynamic>{
        'countBy': 1,
        'start': 0,
        'restart': 'continuous',
      },
      decodeUnicode: false,
    );
  }
  String fontFamily;
  String headerType;
  String footerType;
  String language;
  String defaultOrderedListStyleType;
  bool showHeader;
  bool showFooter;
  int fontSize;
  int complexScriptFontSize;
  PageSize pageSize;
  bool showPageNumber;
  bool showLineNumber;

  Map<String, dynamic> lineNumberOptions;

  bool decodeUnicode;
}

enum Orientation {
  portrait,
  landscape,
}

class PageSize {
  PageSize({
    required this.width,
    required this.height,
  })  : assert(!width.isNegative, 'width cannot be negative'),
        assert(!height.isNegative, 'height cannot be negative');
  PageSize.zero()
      : width = 0,
        height = 0;

  final double width;

  final double height;
}
