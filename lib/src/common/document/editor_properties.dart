/// Represents the editor properties that are always
/// showed like: number of lines, paragraphs, characters, etc
class EditorProperties {
  EditorProperties({
    required this.paragraphs,
    required this.lines,
    required this.characters,
    required this.charactersWithSpaces,
    required this.words,
    required this.pages,
  });

  final int paragraphs;
  final int lines;
  final int characters;
  final int charactersWithSpaces;
  final int words;
  final int pages;
}
