/// Represents the editor properties that are always
/// showed like: number of lines, paragraphs, characters, etc
class EditorProperties {
  final int numberOfRevisions;
  final String template;
  final int paragraphs;
  final int lines;
  final int characters;
  final int charactersWithSpaces;
  final int words;
  final int pages;
  final int docSecurity;
  final String appVersion;

  EditorProperties({
    required this.numberOfRevisions,
    required this.paragraphs,
    required this.lines,
    required this.characters,
    required this.charactersWithSpaces,
    required this.words,
    required this.pages,
    this.docSecurity = 0,
    this.template = 'Normal',
    this.appVersion = '16.0000',
  }) : assert(numberOfRevisions > 0, 'revisions cannot be less than 1');
}
