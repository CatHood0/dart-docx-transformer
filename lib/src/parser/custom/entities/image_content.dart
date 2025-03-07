import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart';
import '../attributes/attribute.dart';
import 'base/content.dart';
import 'base/document_context.dart';
import 'base/simple_content.dart';

class ImageContent extends SimpleContent<ImageData> {
  ImageContent({
    required super.data,
    super.parent,
  });

  @override
  ImageContent get copy => ImageContent(
        data: ImageData(
          bytes: data.bytes,
          extension: data.extension,
          styles: data.styles,
          width: data.width,
          height: data.height,
        ),
      );

  String get getImageName => data.name ?? '';

  @override
  XmlElement buildXml({required DocumentContext context}) {
    // this part is the size of the image <wp:extent cx="width" cy="height"/>
    final String imageName = getImageName;
    final String? imageId = context.media[imageName]?.name;
    if (imageId == null) {
      throw Exception('The image "${data.name}" couldn\'t be founded');
    }
    final int generatedId = context.getMediaIdForImage(rId!) ?? context.generateMediaId();
    return runParent(
      runAttributes: buildXmlStyle(context: context),
      isLink: false,
      nodes: <XmlNode>[
        XmlElement.tag(
          'w:drawing',
          isSelfClosing: false,
          children: <XmlNode>[
            XmlElement.tag(
              'wp:inline',
              isSelfClosing: false,
              attributes: [
                XmlAttribute(XmlName.fromString('distT'), '0'),
                XmlAttribute(XmlName.fromString('distB'), '0'),
                XmlAttribute(XmlName.fromString('distL'), '0'),
                XmlAttribute(XmlName.fromString('distR'), '0'),
                XmlAttribute(
                  XmlName.fromString('xmlns:wp'),
                  'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing',
                ),
              ],
              children: <XmlNode>[
                XmlElement.tag(
                  'wp:extent',
                  attributes: [
                    XmlAttribute(XmlName.fromString('cx'), '${data.width}'),
                    XmlAttribute(XmlName.fromString('cy'), '${data.height}'),
                  ],
                  isSelfClosing: false,
                ),
                XmlElement.tag(
                  'wp:docPr',
                  isSelfClosing: false,
                  attributes: [
                    XmlAttribute(XmlName.fromString('id'), generatedId.toString()),
                    XmlAttribute(XmlName.fromString('name'), imageName),
                    XmlAttribute(XmlName.fromString('descr'), imageName),
                  ],
                ),
                XmlElement.tag(
                  'a:graphic',
                  isSelfClosing: false,
                  attributes: [
                    XmlAttribute(
                      XmlName.fromString('xmlns:a'),
                      'http://schemas.openxmlformats.org/drawingml/2006/main',
                    ),
                  ],
                  children: [
                    XmlElement.tag(
                      'a:graphicData',
                      isSelfClosing: false,
                      attributes: [
                        XmlAttribute(
                          XmlName.fromString('uri'),
                          'http://schemas.openxmlformats.org/drawingml/2006/picture',
                        ),
                      ],
                      children: [
                        XmlElement.tag(
                          'pic:pic',
                          isSelfClosing: false,
                          attributes: [
                            XmlAttribute(
                              XmlName.fromString('xmlns:pic'),
                              'http://schemas.openxmlformats.org/drawingml/2006/picture',
                            ),
                          ],
                          children: [
                            XmlElement.tag(
                              'pic:pic',
                              isSelfClosing: false,
                              attributes: [
                                XmlAttribute(
                                  XmlName.fromString('xmlns:pic'),
                                  'http://schemas.openxmlformats.org/drawingml/2006/picture',
                                ),
                              ],
                              children: [
                                XmlElement.tag(
                                  'pic:nvPicPr',
                                  isSelfClosing: false,
                                  attributes: [
                                    XmlAttribute(
                                      XmlName.fromString('xmlns:pic'),
                                      'http://schemas.openxmlformats.org/drawingml/2006/picture',
                                    ),
                                  ],
                                  children: [
                                    XmlElement.tag(
                                      'pic:cNvPr',
                                      attributes: [
                                        XmlAttribute(XmlName.fromString('id'), generatedId.toString()),
                                        XmlAttribute(XmlName.fromString('name'), imageName),
                                      ],
                                    ),
                                    XmlElement.tag('pic:cNvPicPr'),
                                  ],
                                ),
                                XmlElement.tag(
                                  'pic:blipFill',
                                  isSelfClosing: false,
                                  children: [
                                    XmlElement.tag(
                                      'a:blipFill',
                                      attributes: [
                                        XmlAttribute(
                                          XmlName.fromString('r:embed'),
                                          rId!,
                                        ),
                                      ],
                                      isSelfClosing: false,
                                    ),
                                    XmlElement.tag(
                                      'a:stretch',
                                      children: [
                                        XmlElement.tag('a:fillRect'),
                                      ],
                                      isSelfClosing: false,
                                    ),
                                  ],
                                ),
                                XmlElement.tag(
                                  'pic:spPr',
                                  isSelfClosing: false,
                                  children: [
                                    XmlElement.tag(
                                      'a:xfrm',
                                      children: [
                                        XmlElement.tag(
                                          'a:off',
                                          attributes: [
                                            XmlAttribute(
                                              XmlName.fromString('x'),
                                              '0',
                                            ),
                                            XmlAttribute(
                                              XmlName.fromString('y'),
                                              '0',
                                            ),
                                          ],
                                        ),
                                        XmlElement.tag(
                                          'a:ext',
                                          attributes: [
                                            XmlAttribute(
                                              XmlName.fromString('cx'),
                                              data.width.toString(),
                                            ),
                                            XmlAttribute(
                                              XmlName.fromString('cy'),
                                              data.height.toString(),
                                            ),
                                          ],
                                        ),
                                      ],
                                      isSelfClosing: false,
                                    ),
                                    XmlElement.tag(
                                      'a:prstGeom',
                                      attributes: [
                                        XmlAttribute(
                                          XmlName.fromString('prst'),
                                          'rect',
                                        ),
                                      ],
                                      children: [
                                        XmlElement.tag(
                                          'a:avLst',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  List<XmlElement> buildXmlStyle({required DocumentContext context}) {
    return [];
  }

  @override
  ImageContent? visitElement(bool Function(Content element) shouldGetElement) {
    if (shouldGetElement(this)) return this;
    return null;
  }

  @override
  String toString() {
    return 'ImageContent(id: $id, data: $data)';
  }

  @override
  String toPlainText() {
    return '';
  }
}

class ImageData {
  ImageData({
    required this.bytes,
    required this.extension,
    required this.width,
    required this.height,
    this.styles = const <NodeAttribute>[],
  });

  final Uint8List bytes;
  final String extension;
  final double width;
  final double height;
  final List<NodeAttribute> styles;
  String? name;

  @override
  String toString() {
    return 'ImageData(bytes: ${bytes.elementSizeInBytes}, extension: img.$extension, options: [width: $width, height: $height], styles: $styles)';
  }
}
