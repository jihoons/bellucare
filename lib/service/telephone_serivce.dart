import 'dart:io';

import 'package:bellucare/utils/logger.dart';
import 'package:flutter/services.dart';

class TelephoneService {
  static final TelephoneService _instance = TelephoneService._privateConstructor();
  static TelephoneService get instance => _instance;

  final MethodChannel _channel = MethodChannel("co.weseeks.bellucare.android.channel");
  TelephoneService._privateConstructor();

  Future<List<String>> getPhoneNumbers() async {
    if (!Platform.isAndroid) {
      return List.empty();
    }
    debug("call getPhoneNumbers");
    var result = await _channel.invokeListMethod("getPhoneNumber") as List<dynamic>;
    debug("phone numbers $result");
    return result.map((e) => "$e",).toList();
  }
}