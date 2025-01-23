import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static final String userTokenKey = "userToken";
  final _secureStorage = FlutterSecureStorage();
  StorageService._privateConstructor();

  static final StorageService _instance = StorageService._privateConstructor();
  factory StorageService() {
    return _instance;
  }

  Future<void> saveData(String key, String value) {
    return _secureStorage.write(
      key: key,
      value: value
    );
  }

  Future<String> getData(String key) async {
    return (await _secureStorage.read(key: key)) ?? "";
  }
}
