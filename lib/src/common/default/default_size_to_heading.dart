int? defaultSizeToHeading(String size) {
  if (size == 'small' || size == 'huge' || size == 'large') return null;
  final sizeNumber = double.tryParse(size) ?? int.tryParse(size);
  if (sizeNumber == null) return null;
  if (sizeNumber >= 26 && sizeNumber <= 30) {
    return 4;
  } else if (sizeNumber >= 31 && sizeNumber <= 33.5) {
    return 3;
  } else if (sizeNumber >= 33.6 && sizeNumber <= 37) {
    return 2;
  } else if (sizeNumber >= 38) {
    return 1;
  }
  return null;
}
