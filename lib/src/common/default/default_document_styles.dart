import '../document/document_styles.dart';
import '../styles.dart';

final DocumentStylesSheet defaultDocumentStyles = DocumentStylesSheet(
  styles: <Style>[
    Style(
      type: 'character',
      styleId: 'Hyperlink',
      styleName: 'Hyperlink',
      configurators: <StyleConfigurator>[
        StyleConfigurator.noAutoClosure(
          propertyName: 'rPr',
          configurators: <StyleConfigurator>[
            StyleConfigurator.autoClosure(propertyName: 'color', value: '0000FF'),
            StyleConfigurator.autoClosure(propertyName: 'u', value: 'single'),
          ],
        ),
      ],
    ),
    Style(
      type: 'paragraph',
      styleId: 'Heading1',
      styleName: 'Heading 1',
      configurators: <StyleConfigurator>[
        StyleConfigurator.autoClosure(
          propertyName: 'basedOn',
          value: 'Normal',
        ),
        StyleConfigurator.autoClosure(
          propertyName: 'uiPriority',
          value: 9,
          attributes: null,
        ),
        StyleConfigurator.noAutoClosure(
          propertyName: 'pPr',
          configurators: <StyleConfigurator>[
            StyleConfigurator.autoClosure(
              propertyName: 'spacing',
              attributes: <String, dynamic>{'before': 480},
            ),
            StyleConfigurator.autoClosure(propertyName: 'keepNext'),
            StyleConfigurator.autoClosure(propertyName: 'keepLines'),
            StyleConfigurator.autoClosure(propertyName: 'outlineLvl', value: 0),
          ],
        ),
        StyleConfigurator.noAutoClosure(
          propertyName: 'rPr',
          configurators: <StyleConfigurator>[
            StyleConfigurator.autoClosure(propertyName: 'b'),
            StyleConfigurator.autoClosure(propertyName: 'sz', value: 48),
            StyleConfigurator.autoClosure(propertyName: 'szCs', value: 48),
          ],
        ),
        StyleConfigurator.autoClosure(propertyName: 'qFormat'),
      ],
    ),
    Style(
      type: 'paragraph',
      styleId: 'Heading2',
      styleName: 'Heading 2',
      configurators: <StyleConfigurator>[
        StyleConfigurator.autoClosure(
          propertyName: 'basedOn',
          value: 'Normal',
        ),
        StyleConfigurator.autoClosure(
          propertyName: 'uiPriority',
          value: 9,
          attributes: null,
        ),
        StyleConfigurator.noAutoClosure(
          propertyName: 'pPr',
          configurators: <StyleConfigurator>[
            StyleConfigurator.autoClosure(
              propertyName: 'spacing',
              attributes: <String, dynamic>{
                'before': 360,
                'after': 80,
              },
            ),
            StyleConfigurator.autoClosure(propertyName: 'keepNext'),
            StyleConfigurator.autoClosure(propertyName: 'keepLines'),
            StyleConfigurator.autoClosure(propertyName: 'outlineLvl', value: 1),
          ],
        ),
        StyleConfigurator.noAutoClosure(
          propertyName: 'rPr',
          configurators: <StyleConfigurator>[
            StyleConfigurator.autoClosure(propertyName: 'b'),
            StyleConfigurator.autoClosure(propertyName: 'sz', value: 36),
            StyleConfigurator.autoClosure(propertyName: 'szCs', value: 36),
          ],
        ),
        StyleConfigurator.autoClosure(propertyName: 'qFormat'),
        StyleConfigurator.autoClosure(propertyName: 'unhideWhenUsed'),
      ],
    ),
    Style(
      type: 'paragraph',
      styleId: 'Heading3',
      styleName: 'Heading 3',
      configurators: <StyleConfigurator>[
        StyleConfigurator.autoClosure(
          propertyName: 'basedOn',
          value: 'Normal',
        ),
        StyleConfigurator.autoClosure(
          propertyName: 'uiPriority',
          value: 9,
          attributes: null,
        ),
        StyleConfigurator.autoClosure(propertyName: 'next', value: 'Normal'),
        StyleConfigurator.noAutoClosure(
          propertyName: 'pPr',
          configurators: <StyleConfigurator>[
            StyleConfigurator.autoClosure(
              propertyName: 'spacing',
              attributes: <String, dynamic>{
                'before': 280,
                'after': 80,
              },
            ),
            StyleConfigurator.autoClosure(propertyName: 'keepNext'),
            StyleConfigurator.autoClosure(propertyName: 'keepLines'),
            StyleConfigurator.autoClosure(propertyName: 'outlineLvl', value: 2),
          ],
        ),
        StyleConfigurator.noAutoClosure(
          propertyName: 'rPr',
          configurators: <StyleConfigurator>[
            StyleConfigurator.autoClosure(propertyName: 'b'),
            StyleConfigurator.autoClosure(propertyName: 'sz', value: 28),
            StyleConfigurator.autoClosure(propertyName: 'szCs', value: 28),
          ],
        ),
        StyleConfigurator.autoClosure(propertyName: 'qFormat'),
        StyleConfigurator.autoClosure(propertyName: 'semiHidden'),
        StyleConfigurator.autoClosure(propertyName: 'unhideWhenUsed'),
      ],
    ),
    Style(
      type: 'paragraph',
      styleId: 'Heading4',
      styleName: 'Heading 4',
      configurators: <StyleConfigurator>[
        StyleConfigurator.autoClosure(
          propertyName: 'basedOn',
          value: 'Normal',
        ),
        StyleConfigurator.autoClosure(
          propertyName: 'uiPriority',
          value: 9,
          attributes: null,
        ),
        StyleConfigurator.autoClosure(propertyName: 'next', value: 'Normal'),
        StyleConfigurator.autoClosure(propertyName: 'unhideWhenUsed'),
        StyleConfigurator.autoClosure(propertyName: 'semiHidden'),
        StyleConfigurator.autoClosure(propertyName: 'qFormat'),
        StyleConfigurator.noAutoClosure(
          propertyName: 'pPr',
          configurators: <StyleConfigurator>[
            StyleConfigurator.autoClosure(
              propertyName: 'spacing',
              attributes: <String, dynamic>{
                'before': 220,
                'after': 40,
              },
            ),
            StyleConfigurator.autoClosure(propertyName: 'keepNext'),
            StyleConfigurator.autoClosure(propertyName: 'keepLines'),
            StyleConfigurator.autoClosure(propertyName: 'outlineLvl', value: 3),
          ],
        ),
        StyleConfigurator.noAutoClosure(
          propertyName: 'rPr',
          configurators: <StyleConfigurator>[
            StyleConfigurator.autoClosure(propertyName: 'b'),
            StyleConfigurator.autoClosure(propertyName: 'sz', value: 24),
            StyleConfigurator.autoClosure(propertyName: 'szCs', value: 24),
          ],
        ),
      ],
    ),
    Style(
      type: 'paragraph',
      styleId: 'Heading5',
      styleName: 'Heading 5',
      configurators: <StyleConfigurator>[
        StyleConfigurator.autoClosure(
          propertyName: 'basedOn',
          value: 'Normal',
        ),
        StyleConfigurator.autoClosure(
          propertyName: 'uiPriority',
          value: 9,
          attributes: null,
        ),
        StyleConfigurator.autoClosure(propertyName: 'next', value: 'Normal'),
        StyleConfigurator.autoClosure(propertyName: 'unhideWhenUsed'),
        StyleConfigurator.autoClosure(propertyName: 'semiHidden'),
        StyleConfigurator.autoClosure(propertyName: 'qFormat'),
        StyleConfigurator.noAutoClosure(
          propertyName: 'pPr',
          configurators: <StyleConfigurator>[
            StyleConfigurator.autoClosure(
              propertyName: 'spacing',
              attributes: <String, dynamic>{
                'before': 200,
                'after': 40,
              },
            ),
            StyleConfigurator.autoClosure(propertyName: 'keepNext'),
            StyleConfigurator.autoClosure(propertyName: 'keepLines'),
            StyleConfigurator.autoClosure(propertyName: 'outlineLvl', value: 4),
          ],
        ),
        StyleConfigurator.noAutoClosure(
          propertyName: 'rPr',
          configurators: <StyleConfigurator>[
            StyleConfigurator.autoClosure(propertyName: 'b'),
            StyleConfigurator.autoClosure(propertyName: 'sz', value: 20),
            StyleConfigurator.autoClosure(propertyName: 'szCs', value: 20),
          ],
        ),
      ],
    ),
  ],
);
