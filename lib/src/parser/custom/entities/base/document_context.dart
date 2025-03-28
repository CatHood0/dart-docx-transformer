import 'dart:typed_data';

import '../../../../common/document/document_properties.dart';
import '../../../../common/document/document_styles.dart';
import 'content.dart';

class DocumentContext {
  DocumentContext({
    required this.styles,
    required this.properties,
    required Map<String, MediaData> media,
  }) : _media = <String, MediaData>{...media};

  final DocumentProperties properties;
  final DocumentStylesSheet styles;
  // all the media are saved
  // {filename: rid}
  final Map<String, MediaData> _media;

  Map<String, MediaData> get media => Map<String, MediaData>.unmodifiable(_media);

  int _lastIdGenerated = 1;

  int? getMediaIdForImage(String imageRefId) {
    for(final MediaData media in _media.values){
      if(media.imageRefId == imageRefId) {
        return media.id;
      } 
    }
    return null; 
  }

  int generateMediaId() {
    if (media.isEmpty) return 1;
    _lastIdGenerated = media.entries.last.value.id;
    return _lastIdGenerated;
  }

  Content? _currentContentPart;
  Content? get currentContentPart => _currentContentPart?.copy;
  set currentContentPart(Content? content) {
    if (_currentContentPart == content) return;
    _currentContentPart = content;
  }
}

class MediaData {
  MediaData({
    required this.name,
    required this.id,
    required this.extension,
    required this.bytes,
    required this.imageRefId,
  });

  // this is the rId of the image
  final String imageRefId;
  final Uint8List bytes;
  // the name of the image into DOCX file 
  final String name;
  // this id is auto-generated
  // to be pasted 
  final int id;
  // the extension of this media
  final String extension;

  @override
  String toString() {
    return 'MediaData(name: $name.$extension, id: $id)';
  }
}
