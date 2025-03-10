import '../document/document_styles.dart';
import '../styles.dart';

class DefaultDocumentStyles {
  const DefaultDocumentStyles._();
  static DocumentStylesSheet get kDefaultDocumentStyleSheet => DocumentStylesSheet(
        styles: <Style>[
          Style(
            type: 'character',
            styleId: 'Hyperlink',
            styleName: 'Hyperlink',
            configurators: <StyleConfigurator>[
              StyleConfigurator.noAutoClosure(
                prefix: 'w',
                propertyName: 'rPr',
                configurators: <StyleConfigurator>[
                  StyleConfigurator.autoClosure(
                      prefix: 'w', propertyName: 'color', value: '0000FF'),
                  StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'u', value: 'single'),
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
                prefix: 'w',
                propertyName: 'basedOn',
                value: 'Normal',
              ),
              StyleConfigurator.autoClosure(
                prefix: 'w',
                propertyName: 'uiPriority',
                value: 9,
                attributes: null,
              ),
              StyleConfigurator.noAutoClosure(
                prefix: 'w',
                propertyName: 'pPr',
                configurators: <StyleConfigurator>[
                  StyleConfigurator.autoClosure(
                    prefix: 'w',
                    propertyName: 'spacing',
                    attributes: <String, dynamic>{'before': 480},
                  ),
                  StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'keepNext'),
                  StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'keepLines'),
                  StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'outlineLvl', value: 0),
                ],
              ),
              StyleConfigurator.noAutoClosure(
                prefix: 'w',
                propertyName: 'rPr',
                configurators: <StyleConfigurator>[
                  StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'b'),
                  StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'sz', value: 48),
                  StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'szCs', value: 48),
                ],
              ),
              StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'qFormat'),
            ],
          ),
          Style(
            type: 'paragraph',
            styleId: 'Heading2',
            styleName: 'Heading 2',
            configurators: <StyleConfigurator>[
              StyleConfigurator.autoClosure(
                prefix: 'w',
                propertyName: 'basedOn',
                value: 'Normal',
              ),
              StyleConfigurator.autoClosure(
                prefix: 'w',
                propertyName: 'uiPriority',
                value: 9,
                attributes: null,
              ),
              StyleConfigurator.noAutoClosure(
                prefix: 'w',
                propertyName: 'pPr',
                configurators: <StyleConfigurator>[
                  StyleConfigurator.autoClosure(
                    prefix: 'w',
                    propertyName: 'spacing',
                    attributes: <String, dynamic>{
                      'before': 360,
                      'after': 80,
                    },
                  ),
                  StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'keepNext'),
                  StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'keepLines'),
                  StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'outlineLvl', value: 1),
                ],
              ),
              StyleConfigurator.noAutoClosure(
                prefix: 'w',
                propertyName: 'rPr',
                configurators: <StyleConfigurator>[
                  StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'b'),
                  StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'sz', value: 36),
                  StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'szCs', value: 36),
                ],
              ),
              StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'qFormat'),
              StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'unhideWhenUsed'),
            ],
          ),
          Style(
            type: 'paragraph',
            styleId: 'Heading3',
            styleName: 'Heading 3',
            configurators: <StyleConfigurator>[
              StyleConfigurator.autoClosure(
                prefix: 'w',
                propertyName: 'basedOn',
                value: 'Normal',
              ),
              StyleConfigurator.autoClosure(
                prefix: 'w',
                propertyName: 'uiPriority',
                value: 9,
                attributes: null,
              ),
              StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'next', value: 'Normal'),
              StyleConfigurator.noAutoClosure(
                prefix: 'w',
                propertyName: 'pPr',
                configurators: <StyleConfigurator>[
                  StyleConfigurator.autoClosure(
                    prefix: 'w',
                    propertyName: 'spacing',
                    attributes: <String, dynamic>{
                      'before': 280,
                      'after': 80,
                    },
                  ),
                  StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'keepNext'),
                  StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'keepLines'),
                  StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'outlineLvl', value: 2),
                ],
              ),
              StyleConfigurator.noAutoClosure(
                prefix: 'w',
                propertyName: 'rPr',
                configurators: <StyleConfigurator>[
                  StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'b'),
                  StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'sz', value: 28),
                  StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'szCs', value: 28),
                ],
              ),
              StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'qFormat'),
              StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'semiHidden'),
              StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'unhideWhenUsed'),
            ],
          ),
          Style(
            type: 'paragraph',
            styleId: 'Heading4',
            styleName: 'Heading 4',
            configurators: <StyleConfigurator>[
              StyleConfigurator.autoClosure(
                prefix: 'w',
                propertyName: 'basedOn',
                value: 'Normal',
              ),
              StyleConfigurator.autoClosure(
                prefix: 'w',
                propertyName: 'uiPriority',
                value: 9,
                attributes: null,
              ),
              StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'next', value: 'Normal'),
              StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'unhideWhenUsed'),
              StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'semiHidden'),
              StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'qFormat'),
              StyleConfigurator.noAutoClosure(
                prefix: 'w',
                propertyName: 'pPr',
                configurators: <StyleConfigurator>[
                  StyleConfigurator.autoClosure(
                    prefix: 'w',
                    propertyName: 'spacing',
                    attributes: <String, dynamic>{
                      'before': 220,
                      'after': 40,
                    },
                  ),
                  StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'keepNext'),
                  StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'keepLines'),
                  StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'outlineLvl', value: 3),
                ],
              ),
              StyleConfigurator.noAutoClosure(
                prefix: 'w',
                propertyName: 'rPr',
                configurators: <StyleConfigurator>[
                  StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'b'),
                  StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'sz', value: 24),
                  StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'szCs', value: 24),
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
                prefix: 'w',
                propertyName: 'basedOn',
                value: 'Normal',
              ),
              StyleConfigurator.autoClosure(
                prefix: 'w',
                propertyName: 'uiPriority',
                value: 9,
                attributes: null,
              ),
              StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'next', value: 'Normal'),
              StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'unhideWhenUsed'),
              StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'semiHidden'),
              StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'qFormat'),
              StyleConfigurator.noAutoClosure(
                prefix: 'w',
                propertyName: 'pPr',
                configurators: <StyleConfigurator>[
                  StyleConfigurator.autoClosure(
                    prefix: 'w',
                    propertyName: 'spacing',
                    attributes: <String, dynamic>{
                      'before': 200,
                      'after': 40,
                    },
                  ),
                  StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'keepNext'),
                  StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'keepLines'),
                  StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'outlineLvl', value: 4),
                ],
              ),
              StyleConfigurator.noAutoClosure(
                prefix: 'w',
                propertyName: 'rPr',
                configurators: <StyleConfigurator>[
                  StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'b'),
                  StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'sz', value: 20),
                  StyleConfigurator.autoClosure(prefix: 'w', propertyName: 'szCs', value: 20),
                ],
              ),
            ],
          ),
        ],
      );
}
