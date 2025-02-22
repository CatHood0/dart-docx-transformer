import 'package:docx_transformer/src/common/document/document_margins.dart';
import 'package:docx_transformer/src/common/document/document_properties.dart';
import 'package:docx_transformer/src/common/document/document_styles.dart';

const String defaultFont = 'Times New Roman';
const int defaultFontSize = 22;
const String defaultLang = 'en-US';
const Orientation defaultOrientation = Orientation.portrait;
const double landscapeWidth = 15840;
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

const DocumentMargins portraitMargins = DocumentMargins(
  top: 1440,
  right: 1800,
  bottom: 1440,
  left: 1800,
  header: 720,
  footer: 720,
  gutter: 0,
);

DocumentProperties defaultDocumentProperties({
  String title = '',
  String owner = '',
  String subject = '',
  String description = '',
  String lastModifiedBy = '',
  List<String> keywords = const [],
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
