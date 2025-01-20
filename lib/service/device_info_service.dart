import 'dart:io';

import 'package:bellucare/utils/logger.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoService {
  static final DeviceInfoService _instance = DeviceInfoService._postConstructor();
  static DeviceInfoService get instance => _instance;

  DeviceInfoService._postConstructor() {
    _init();
  }

  final _deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo? _android;
  IosDeviceInfo? _ios;
  bool _initialized = false;
  Future<void> _init() async {
    if (Platform.isAndroid) {
      _android = await _deviceInfo.androidInfo;
    } else {
      _ios = await _deviceInfo.iosInfo;
    }
    _initialized = true;
  }

  Future<bool> canUseHealth() async {
    if (_initialized == false) {
      await _init();
    }
    if (Platform.isAndroid) {
      debug("android sdk_version: ${_android?.version.sdkInt}");
      return _android != null && _android!.version.sdkInt >= 26;
    } else {
      return _ios != null;
    }
  }
}
