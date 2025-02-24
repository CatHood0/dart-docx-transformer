import 'dart:io';

import '../../../constants.dart';
import '../attributes/attribute.dart';
import 'base/content.dart';
import 'base/document_context.dart';

class ImageContent extends Content<ImageData> {
  ImageContent({
    required super.data,
    super.parent,
  });

  String get getImageName => data.file.path.replaceAll(imageNamePattern, '');

  @override
  String buildXml({required DocumentContext context}) {
    final String imageName = getImageName;
    final String? imageId = context.media[imageName]?.mediaId;
    if (imageId == null) {
      throw Exception("the image with path: ${data.file.path} couldn't be founded");
    }
    final int generatedId = context.generateMediaId();
    return '''
      <w:r>
        <w:drawing>
          <wp:inline distT="0" distB="0" distL="0" distR="0" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing">
            <wp:extent cx="${data.width}" cy="${data.height}"/>
            <wp:docPr id="$generatedId" name="${imageName.replaceAll(RegExp(r'\..*'), '')}" descr="$imageName"/>
            <a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
              <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
                <pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
                  <pic:nvPicPr>
                    <pic:cNvPr id="$generatedId" name="${imageName.replaceAll(RegExp(r'\..*'), '')}"/>
                    <pic:cNvPicPr/>
                  </pic:nvPicPr>
                  <pic:blipFill>
                    <a:blip r:embed="$imageId"></a:blip>
                    <a:stretch>
                      <a:fillRect/>
                    </a:stretch>
                  </pic:blipFill>
                  <pic:spPr>
                    <a:xfrm>
                      <a:off x="0" y="0"/>
                      <a:ext cx="${data.width}" cy="${data.height}"/>
                    </a:xfrm>
                    <a:prstGeom prst="rect">
                      <a:avLst/>
                    </a:prstGeom>
                  </pic:spPr>
                </pic:pic>
              </a:graphicData>
            </a:graphic>
          </wp:inline>
        </w:drawing>
      </w:r>
    ''';
  }

  @override
  String buildXmlStyle({required DocumentContext context}) {
    return '';
  }

  @override
  ImageContent get copy => ImageContent(
        data: ImageData(
          file: data.file,
          styles: data.styles,
          width: data.width,
          height: data.height,
        ),
      );
}

class ImageData {
  ImageData({
    required this.file,
    required this.styles,
    required this.width,
    required this.height,
  });

  final File file;
  final double width;
  final double height;
  final List<Attribute> styles;
}
