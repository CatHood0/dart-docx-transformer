import '../document/document_styles.dart';
import '../generators/styles_creator.dart';

final DocumentStylesSheet defaultDocumentStyles = DocumentStylesSheet(
  styles: <Style>[
    Style(
      type: 'paragraph',
      styleId: 'Heading1',
      styleName: 'Heading 1',
      basedOn: 'Normal',
      configurators: <StyleConfigurator>[
        StyleConfigurator(
          propertyName: 'uiPriority',
          value: 9,
          attributes: null,
        ),
        StyleConfigurator(
          propertyName: 'pPr',
          configurators: <StyleConfigurator>[
            StyleConfigurator(
              propertyName: 'spacing',
              attributes: <String, dynamic>{'before': 480},
            ),
            StyleConfigurator(propertyName: 'keepNext'),
            StyleConfigurator(propertyName: 'keepLines'),
            StyleConfigurator(propertyName: 'outlineLvl', value: 0),
          ],
        ),
        StyleConfigurator(
          propertyName: 'rPr',
          configurators: <StyleConfigurator>[
            StyleConfigurator(propertyName: 'b'),
            StyleConfigurator(propertyName: 'sz', value: 48),
            StyleConfigurator(propertyName: 'szCs', value: 48),
          ],
        ),
        StyleConfigurator(propertyName: 'qFormat'),
      ],
    ),
    Style(
      type: 'paragraph',
      styleId: 'Heading2',
      styleName: 'Heading 2',
      basedOn: 'Normal',
      configurators: <StyleConfigurator>[
        StyleConfigurator(
          propertyName: 'uiPriority',
          value: 9,
          attributes: null,
        ),
        StyleConfigurator(
          propertyName: 'pPr',
          configurators: <StyleConfigurator>[
            StyleConfigurator(
              propertyName: 'spacing',
              attributes: <String, dynamic>{
                'before': 360,
                'after': 80,
              },
            ),
            StyleConfigurator(propertyName: 'keepNext'),
            StyleConfigurator(propertyName: 'keepLines'),
            StyleConfigurator(propertyName: 'outlineLvl', value: 1),
          ],
        ),
        StyleConfigurator(
          propertyName: 'rPr',
          configurators: <StyleConfigurator>[
            StyleConfigurator(propertyName: 'b'),
            StyleConfigurator(propertyName: 'sz', value: 36),
            StyleConfigurator(propertyName: 'szCs', value: 36),
          ],
        ),
        StyleConfigurator(propertyName: 'qFormat'),
        StyleConfigurator(propertyName: 'unhideWhenUsed'),
      ],
    ),
    Style(
      type: 'paragraph',
      styleId: 'Heading3',
      styleName: 'Heading 3',
      basedOn: 'Normal',
      configurators: <StyleConfigurator>[
        StyleConfigurator(
          propertyName: 'uiPriority',
          value: 9,
          attributes: null,
        ),
        StyleConfigurator(propertyName: 'next', value: 'Normal'),
        StyleConfigurator(
          propertyName: 'pPr',
          configurators: <StyleConfigurator>[
            StyleConfigurator(
              propertyName: 'spacing',
              attributes: <String, dynamic>{
                'before': 280,
                'after': 80,
              },
            ),
            StyleConfigurator(propertyName: 'keepNext'),
            StyleConfigurator(propertyName: 'keepLines'),
            StyleConfigurator(propertyName: 'outlineLvl', value: 2),
          ],
        ),
        StyleConfigurator(
          propertyName: 'rPr',
          configurators: <StyleConfigurator>[
            StyleConfigurator(propertyName: 'b'),
            StyleConfigurator(propertyName: 'sz', value: 28),
            StyleConfigurator(propertyName: 'szCs', value: 28),
          ],
        ),
        StyleConfigurator(propertyName: 'qFormat'),
        StyleConfigurator(propertyName: 'semiHidden'),
        StyleConfigurator(propertyName: 'unhideWhenUsed'),
      ],
    ),
    Style(
      type: 'paragraph',
      styleId: 'Heading4',
      styleName: 'Heading 4',
      basedOn: 'Normal',
      configurators: <StyleConfigurator>[
        StyleConfigurator(
          propertyName: 'uiPriority',
          value: 9,
          attributes: null,
        ),
        StyleConfigurator(propertyName: 'next', value: 'Normal'),
        StyleConfigurator(propertyName: 'unhideWhenUsed'),
        StyleConfigurator(propertyName: 'semiHidden'),
        StyleConfigurator(propertyName: 'qFormat'),
        StyleConfigurator(
          propertyName: 'pPr',
          configurators: <StyleConfigurator>[
            StyleConfigurator(
              propertyName: 'spacing',
              attributes: <String, dynamic>{
                'before': 220,
                'after': 40,
              },
            ),
            StyleConfigurator(propertyName: 'keepNext'),
            StyleConfigurator(propertyName: 'keepLines'),
            StyleConfigurator(propertyName: 'outlineLvl', value: 3),
          ],
        ),
        StyleConfigurator(
          propertyName: 'rPr',
          configurators: <StyleConfigurator>[
            StyleConfigurator(propertyName: 'b'),
            StyleConfigurator(propertyName: 'sz', value: 24),
            StyleConfigurator(propertyName: 'szCs', value: 24),
          ],
        ),
      ],
    ),
    Style(
      type: 'paragraph',
      styleId: 'Heading5',
      styleName: 'Heading 5',
      basedOn: 'Normal',
      configurators: <StyleConfigurator>[
        StyleConfigurator(
          propertyName: 'uiPriority',
          value: 9,
          attributes: null,
        ),
        StyleConfigurator(propertyName: 'next', value: 'Normal'),
        StyleConfigurator(propertyName: 'unhideWhenUsed'),
        StyleConfigurator(propertyName: 'semiHidden'),
        StyleConfigurator(propertyName: 'qFormat'),
        StyleConfigurator(
          propertyName: 'pPr',
          configurators: <StyleConfigurator>[
            StyleConfigurator(
              propertyName: 'spacing',
              attributes: <String, dynamic>{
                'before': 200,
                'after': 40,
              },
            ),
            StyleConfigurator(propertyName: 'keepNext'),
            StyleConfigurator(propertyName: 'keepLines'),
            StyleConfigurator(propertyName: 'outlineLvl', value: 4),
          ],
        ),
        StyleConfigurator(
          propertyName: 'rPr',
          configurators: <StyleConfigurator>[
            StyleConfigurator(propertyName: 'b'),
            StyleConfigurator(propertyName: 'sz', value: 20),
            StyleConfigurator(propertyName: 'szCs', value: 20),
          ],
        ),
      ],
    ),
  ],
  paragraphStyleSheet: ParagraphStyleSheet(
    blockStyles: ParagraphBlockStyleSheet(),
    inlineStyles: ParagraphInlineStyleSheet.defaultStyle(),
  ),
);
