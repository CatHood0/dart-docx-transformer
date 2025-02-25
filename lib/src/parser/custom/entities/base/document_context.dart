import 'package:xml/xml.dart';

import '../../../../common/document/document_styles.dart';
import 'content.dart';

class DocumentContext {
  DocumentContext({
    required this.styles,
    required Map<String, MediaData> media,
  }) : _media = <String, MediaData>{...media};

  final DocumentStylesSheet styles;
  // all the media are saved
  // {filename: rid}
  final Map<String, MediaData> _media;

  Map<String, MediaData> get media => Map<String, MediaData>.unmodifiable(_media);

  int _lastIdGenerated = 1;

  int generateMediaId() {
    if(media.isEmpty) return 1;
    _lastIdGenerated = media.entries.last.value.generatedId + 1;
    return _lastIdGenerated;
  }

  XmlNode? _currentNode;
  XmlNode? get currentNode => _currentNode?.copy();
  set currentNode(XmlNode? node) {
    if (_currentNode == node) return;
    _currentNode = node;
  }

  Content? _currentContentPart;
  Content? get currentContentPart => _currentContentPart?.copy;
  set currentContentPart(Content? node) {
    if (_currentContentPart == node) return;
    _currentContentPart = node;
  }
}

class MediaData {
  MediaData({
    required this.mediaId,
    required this.generatedId,
  });

  // this id is manually generated in other parts
  final String mediaId;
  // this id is auto-generated
  final int generatedId;
}
