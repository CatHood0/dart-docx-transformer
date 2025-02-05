import 'package:quill_delta_docx_parser/src/common/default/default_document_styles.dart';
import 'package:quill_delta_docx_parser/src/common/document/document_styles.dart';

/// Represents the common properties to be filled
/// in the document. E.g: subject, owner, modified date,
/// encoding (UTF-8 by default), time
class DocumentProperties {
  /// name of the person
  /// that makes the last modify to the document
  final String title;
  final String description;
  final String owner;
  final String subject;
  final String modifiedBy;
  final String keywords;
  final String encoding;
  final String standalone;
  final DateTime time;
  final DateTime createdAt;
  final DocumentStylesSheet? docStyles;

  DocumentProperties({
    required this.modifiedBy,
    required this.owner,
    required this.subject,
    required this.title,
    required this.time,
    required this.description,
    required this.createdAt,
    required bool standalone,
    List<String> keywords = const [],
    String encoding = 'UTF-8',
    this.docStyles,
  })  : standalone = standalone ? 'yes' : 'No',
        keywords = keywords.join(','),
        encoding = encoding.toUpperCase();

  factory DocumentProperties.blank({String? owner}) {
    return DocumentProperties(
      encoding: 'UTF-8',
      modifiedBy: owner ?? '',
      owner: owner ?? '',
      subject: '',
      title: '',
      time: DateTime.now(),
      description: '',
      createdAt: DateTime.now(),
      standalone: true,
    );
  }
}
