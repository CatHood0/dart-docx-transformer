import 'package:docx_transformer/src/constants.dart';

String getListStyleType(listType) {
  switch (listType) {
    case 'upper-roman':
      return 'upperRoman';
    case 'lower-roman':
      return 'lowerRoman';
    case 'upper-alpha':
    case 'upper-alpha-bracket-end':
      return 'upperLetter';
    case 'lower-alpha':
    case 'lower-alpha-bracket-end':
      return 'lowerLetter';
    case 'decimal':
    case 'decimal-bracket':
      return 'decimal';
    default:
      return defaultOrderedListStyleType;
  }
}

String getListPrefixSuffix(Map<String, dynamic>? style, int lvl) {
  String listType = defaultOrderedListStyleType;

  if (style != null && style['list-style-type'] != null) {
    listType = style['list-style-type'];
  }

  switch (listType) {
    case 'upper-roman':
    case 'lower-roman':
    case 'upper-alpha':
    case 'lower-alpha':
      return '%${lvl + 1}.';
    case 'upper-alpha-bracket-end':
    case 'lower-alpha-bracket-end':
    case 'decimal-bracket-end':
      return '%${lvl + 1})';
    case 'decimal-bracket':
      return '(%${lvl + 1})';
    case 'decimal':
    default:
      return '%${lvl + 1}.';
  }
}
