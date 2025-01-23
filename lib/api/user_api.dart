import 'package:bellucare/model/user.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/v4.dart';

class UserApi {
  final _uuid = const Uuid();
  UserApi._privateConstructor();
  static final UserApi _instance = UserApi._privateConstructor();
  factory UserApi() {
    return _instance;
  }

  Future<User> fetchUserByToken(String userToken) async {
    return Future.delayed(Duration(milliseconds: 50), () {
      return User(userSeq: 1, name: "김지훈");
    });
  }

  String _lastUUID = "";
  Future<String> requestAuthenticationCode(String phoneNumber) async {
    return Future.delayed(Duration(milliseconds: 100), () {
      _lastUUID = _uuid.v4();
      return _lastUUID;
    });
  }

  Future<LoginResult?> validateAuthenticationCode(String phoneNumber, String sessionKey, String authenticationCode) async {
    return Future.delayed(Duration(milliseconds: 100), () {
      if (authenticationCode == "123456" && _lastUUID == sessionKey) {
        return LoginResult(
          user: User(userSeq: 1, name: "김지훈"),
          accessToken: _uuid.v4(),
          refreshToken: _uuid.v4(),
        );
      } else {
        return null;
      }
    });
  }
}

class LoginResult {
  LoginResult({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });
  final User user;
  final String accessToken;
  final String refreshToken;
}