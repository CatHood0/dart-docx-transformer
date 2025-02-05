import 'dart:io';
import 'dart:typed_data';

class FileCreator {
  final File file;
  final Uint8List bytes;

  FileCreator({
    required this.file,
    required this.bytes,
  });
}
