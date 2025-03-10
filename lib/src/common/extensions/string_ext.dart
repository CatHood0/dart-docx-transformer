import 'package:xml/xml.dart';

extension AlignString on String {
  /// Compare if the string is equals to [compare] String passed
  ///
  /// if it is, then just return the replacement
  /// if not, return itself
  String toFixedString({required String replacement, required String compare}) {
    return this == compare ? replacement : this;
  }

  String removeAllWhitespaces(){
    return replaceAll(RegExp(r'\s+'), '');
  }

  String toFixedAlignStr() {
    return toFixedString(replacement: 'justify', compare: 'both');
  }

  /// Convert this string to a XmlName
  XmlName toName() {
    return XmlName.fromString(this).copy();
  }

  bool get isAlignStr =>
      toLowerCase() == 'left' ||
      toLowerCase() == 'right' ||
      toLowerCase() == 'justify' ||
      toLowerCase() == 'both' ||
      toLowerCase() == 'center';
}
