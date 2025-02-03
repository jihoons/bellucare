import 'package:bellucare/model/user.dart';
import 'package:bellucare/service/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserState {
  UserState({
    this.user
  });
  User? user;
}

class UserStateNotifier extends StateNotifier<UserState> {
  UserStateNotifier(): super(UserState());
  void setUser(LogInResponse response) {
    var tokenManager = TokenManager();
    tokenManager.accessToken = response.tokens.accessToken;
    tokenManager.refreshToken = response.tokens.refreshToken;
    var storageService = StorageService();
    storageService.saveData(StorageService.accessTokenKey, tokenManager.accessToken);
    storageService.saveData(StorageService.refreshTokenKey, tokenManager.refreshToken);
    state = UserState(user: response.user);
  }

  void logout() {
    var tokenManager = TokenManager();
    var storageService = StorageService();
    tokenManager.accessToken = null;
    tokenManager.refreshToken = null;
    storageService.removeData(StorageService.accessTokenKey);
    storageService.removeData(StorageService.refreshTokenKey);
    state = UserState(user: null);
  }
}

final userProvider = StateNotifierProvider<UserStateNotifier, UserState>((ref) => UserStateNotifier(),);
class TokenManager {
  TokenManager._privateConstructor();

  static final TokenManager _instance = TokenManager._privateConstructor();

  factory TokenManager() {
    return _instance;
  }

  String? _accessToken;
  String? _refreshToken;
  
  String get accessToken => _accessToken ?? "";
  String get refreshToken => _refreshToken ?? "";

  set accessToken(String? token) {
    _accessToken = token;
  }

  set refreshToken(String? token) {
    _refreshToken = token;
  }
}