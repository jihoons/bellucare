import 'dart:convert';

import 'package:bellucare/utils/logger.dart';
import 'package:flutter/services.dart';

class ConfigService {
  ConfigService._privateConstructor();

  late AppConfig _appConfig;
  AppConfig get appConfig => _appConfig;
  Future<void> init() async {
    const environment = String.fromEnvironment('ENV', defaultValue: 'prod');
    debug("=====> $environment <=========");
    var configFile = await rootBundle.loadString("asset/config/$environment.json");
    var json = jsonDecode(configFile);
    _appConfig = AppConfig.fromJson(json);
  }

  static final ConfigService _instance = ConfigService._privateConstructor();

  factory ConfigService() {
    return _instance;
  }

  void someMethod() {
    print("This is a singleton method.");
  }
}

class AppConfig {
  const AppConfig({
    required this.api
  });
  final String api;

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      api: json["api"] as String,
    );
  }
}
