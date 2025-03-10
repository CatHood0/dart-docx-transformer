import 'package:collection/collection.dart';

/// Splits a string [str] by new line characters ("\n"), preserving empty lines
/// as separate tokens in the resulting array.
///
/// Example:
/// ```dart
/// String input = "hello\n\nworld\n ";
/// List<String> tokens = tokenizeWithNewLines(input);
/// print(tokens); // Output: ["hello", "\n", "\n", "world", "\n", " "]
/// ```
///
/// Returns a list of strings where each element represents either a line of text
/// or a new line character.
List<String> tokenizeWithNewLines(String str) {
  const String newLine = '\n';

  if (str == newLine) {
    return <String>[str];
  }

  final List<String> lines = str.split(newLine);

  if (lines.length == 1) {
    return lines;
  }

  final int lastIndex = lines.length - 1;

  return lines.foldIndexed(<String>[], (int ind, List<String> pv, String line) {
    if (ind != lastIndex) {
      if (line != '') {
        pv
          ..add(line)
          ..add(newLine);
      } else {
        pv.add(newLine);
      }
    } else if (line != '') {
      pv.add(line);
    }
    return pv;
  });
}
