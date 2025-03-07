class ContentTypeException implements Exception {
  ContentTypeException({required this.message});

  final String message;
  @override
  String toString() {
    return 'ContentTypeException: $message';
  }
}
