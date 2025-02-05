import 'dart:math';

const String _hexDigits = '0123456789ABCDEF';

String nanoid(int length) {
  final Random random = Random.secure();
  final StringBuffer buffer = StringBuffer();

  for (int i = 0; i < length; i++) {
    buffer.write(_hexDigits[random.nextInt(_hexDigits.length)]);
  }

  return buffer.toString();
}
