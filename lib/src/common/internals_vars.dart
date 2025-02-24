import 'package:meta/meta.dart';

// every 720 tab value, means 1 level of the indentation
//
// we need to take in account that we need to check settings.xml
// where contains this value (could be different and we need to check it)
@internal
double kDefaultTabStop = 720;
