import 'dart:isolate';

import 'package:bellucare/utils/string_utils.dart';
import 'package:flutter/foundation.dart';

void debug(String log) {
  if (kDebugMode) {
    debugPrint("[${Isolate.current.hashCode}][${_getSource()}][${StringUtils.formatDateTime(DateTime.now())}] <app> $log");
  }
}

String _getSource() {
  var trace = StackTrace.current.toString();
  var index = trace.indexOf("\n");
  var index2 = trace.indexOf("\n", index + 1);
  index = trace.indexOf("\n", index2 + 1);
  return _getSourceLocation(trace.substring(index2 + 1, index));
}

String _getSourceLocation(String value) {
  var index = value.indexOf("(");
  var index2 = value.indexOf(")", index);
  return value.substring(index + 1, index2);
}
