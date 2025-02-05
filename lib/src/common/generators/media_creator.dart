import 'dart:io';
import 'dart:typed_data';

import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:quill_delta_docx_parser/src/common/file_creator.dart';

typedef FileName = String;
typedef FileExtension = String;

/// Correspond to file word/media/files
///
/// Return the keys with the files to create media
///
// Note: we will need to add to the ContentTypes media supported
// from this to avoid any error.
// probably we will need to create elements like: <Default Extension="jpeg" ContentType="image/jpeg" />
Map<String, FileCreator> mediaCreator(
  List<Operation> operationWithEmbeds,
  (Uint8List, FileName, FileExtension) Function(Operation) buildFileFromEmbed, {
  required void Function(String ext) onDetectExtension,
  String Function(String existentName)? onCatchExistentRegister,
}) {
  Map<String, FileCreator> namesRegistered = {};
  int lastNumberGenerated = 0;
  for (final op in operationWithEmbeds) {
    final fileProps = buildFileFromEmbed(op);
    // check if the file name and the extension is fine
    assert(fileProps.$2.isNotEmpty && !fileProps.$2.contains('/'),
        'file name cannot be empty or contains slash or invert slash "/|\\"');
    assert(fileProps.$3.isNotEmpty && !fileProps.$3.contains('/'),
        'file extension name cannot be empty or contains slash or invert slash "/|\\"');
    final mediaName = '${fileProps.$2}${lastNumberGenerated + 1}${fileProps.$3}';
    // register the new extension type if needed
    onDetectExtension(fileProps.$3);
    final fileCreator = FileCreator(
      /// should build => media/image[number].jpeg or media/video[number].mp4
      file: File('media/$mediaName'),
      bytes: fileProps.$1,
    );
    lastNumberGenerated++;
    if (namesRegistered.containsKey(mediaName)) {
      final nameFallback = onCatchExistentRegister?.call(fileProps.$2);
      if (nameFallback == null) {
        throw StateError('$mediaName is already registered into the media registers and cannot be accepted');
      }
      assert(nameFallback.isNotEmpty && !nameFallback.contains('/'),
          'file name cannot be empty or contains slash or invert slash "/|\\"');
      namesRegistered['$nameFallback${fileProps.$3}'] = fileCreator;
      continue;
    }
    namesRegistered[mediaName] = fileCreator;
  }
  return {...namesRegistered};
}
