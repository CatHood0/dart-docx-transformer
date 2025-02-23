import 'package:docx_transformer/src/common/document/document_styles.dart';
import 'package:docx_transformer/src/common/generators/styles_creator.dart';

final DocumentStylesSheet defaultDocumentStyles = DocumentStylesSheet(
  styles: [
    Style(
      type: 'paragraph',
      styleId: 'Header 1',
      styleName: 'Header 1',
      subStyles: [
        SubStyles(
          propertyName: 'keepLines',
          value: null,
          extraInfo: null,
        ),
        SubStyles(
          propertyName: 'spacing',
          value: null,
          extraInfo: {'before': 360, 'after': 180},
        ),
      ],
    ),
  ],
  paragraphStyleSheet: ParagraphStyleSheet(
    blockStyles: ParagraphBlockStyleSheet(),
    inlineStyles: ParagraphInlineStyleSheet.defaultStyle(),
  ),
);
