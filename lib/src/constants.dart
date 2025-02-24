import 'common/document/document_margins.dart';
import 'common/document/document_properties.dart';
import 'common/document/document_styles.dart';
import 'common/document/editor_properties.dart';

const String defaultFont = 'Times New Roman';
const int defaultFontSize = 22;
const String defaultLang = 'en-US';

const String defaultOrderedListStyleType = 'decimal';
final Map<String, dynamic> kDefaultPreserveWhitespaceMark =
    Map<String, String>.unmodifiable(<String, dynamic>{'xml:space': 'preserved'});

const Orientation defaultOrientation = Orientation.portrait;

/// Every `0.5` spacing, is equals to 120
/// it means, that `1.0` is equals to 240,
/// `1.5` is equals to 360, and etc
///
/// to get correct spacing to a value that we can understand
/// we can use a `formula` like:
///
/// _Note: "n" represents the value that we found in `w:line` attribute_
///
///```
/// lineSpacing = n / 240
///```
const double kDefaultSpacing1 = 240;
const double kDefaultSpacing15 = 360;
const double kDefaultSpacing2 = 400;
const double landscapeHeight = 12240;
const DocumentMargins landscapeMargins = DocumentMargins(
  top: 1800,
  right: 1440,
  bottom: 1800,
  left: 1440,
  header: 720,
  footer: 720,
  gutter: 0,
);
const double landscapeWidth = 15840;

const DocumentMargins portraitMargins = DocumentMargins(
  top: 1440,
  right: 1800,
  bottom: 1440,
  left: 1800,
  header: 720,
  footer: 720,
  gutter: 0,
);

final RegExp imageNamePattern = RegExp(r'.*\/');

DocumentProperties defaultDocumentProperties({
  String title = '',
  String owner = '',
  String subject = '',
  String description = '',
  String lastModifiedBy = '',
  List<String> keywords = const <String>[],
  DocumentStylesSheet? styles,
  int revisions = 1,
}) =>
    DocumentProperties(
      title: title,
      owner: owner,
      subject: subject,
      description: description,
      lastModifiedBy: lastModifiedBy,
      modifiedAt: DateTime.now(),
      createdAt: DateTime.now(),
      keywords: keywords,
      docStyles: styles,
      revisions: 1,
      orientation: defaultOrientation,
      editorSettings: EditorSettings.basic(
        size: PageSize(
          width: landscapeWidth,
          height: landscapeHeight,
        ),
      ),
    );

EditorProperties defaultEditorProperties({
  required String content,
}) =>
    EditorProperties(
      numberOfRevisions: 1,
      paragraphs: content.countParagraphs,
      lines: content.isEmpty ? 0 : content.countLines,
      characters: content.charsLength,
      charactersWithSpaces: content.charsWithoutSpaces,
      words: content.countWords,
      pages: 0,
    );

extension on String {
  int get countParagraphs => split('\n')
      .where(
        (String p) => p.trim().isNotEmpty,
      )
      .length;

  int get countLines => split('\n').length;

  int get countWords => split(RegExp(r'\s+'))
      .where(
        (String p) => p.trim().isNotEmpty,
      )
      .length;

  int get charsWithoutSpaces {
    return replaceAll(RegExp(r'\s+'), '').length;
  }

  int get charsLength {
    return length;
  }
}
