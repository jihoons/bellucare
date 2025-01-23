import 'package:bellucare/model/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProvider = StateProvider<User?>((ref) => null);

class TokenManager {
  TokenManager._privateConstructor();

  static final TokenManager _instance = TokenManager._privateConstructor();

  factory TokenManager() {
    return _instance;
  }

  String? accessToken;
  String? refreshToken;
}