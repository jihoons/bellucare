import 'package:bellucare/api/http_client.dart';
import 'package:bellucare/model/user.dart';
import 'package:uuid/uuid.dart';

class UserApi {
  final _uuid = const Uuid();
  UserApi._privateConstructor();
  static final UserApi _instance = UserApi._privateConstructor();
  factory UserApi() {
    return _instance;
  }

  Future<LogInResponse?> fetchUserByToken(String userToken, String pushToken) async {
    var client = HttpClient();
    client.setToken(userToken);
    var json = await client.post("/auth/login", {"pushToken": pushToken});
    client.clearToken();
    if (json == null) {
      return null;
    }
    return LogInResponse.fromJson(json);
  }

  Future<String> requestAuthenticationCode(String phoneNumber) async {
    var json = await HttpClient().post("/auth/code", {"phoneNumber": phoneNumber});
    if (json != null) {
      return RequestCodeResponse.fromJson(json).requestCode;
    } else {
      return "";
    }
  }

  Future<VerifyResponse?> validateAuthenticationCode(String phoneNumber, String sessionKey, String authenticationCode) async {
    var json = await HttpClient().post("/auth/verify", {
      "phoneNumber": phoneNumber,
      "authenticationCode": authenticationCode,
      "requestId": sessionKey
    });
    if (json != null) {
      return VerifyResponse.fromJson(json);
    } else {
      return null;
    }
  }

  Future<LogInResponse?> signup({
    required String token,
    required String phoneNumber,
    required String name,
    required String gender,
    required String birthDay,
    required List<Map<String, dynamic>> agreeTerms,
    required String pushToken,
  }) async {
    var client = HttpClient();
    client.setToken(token);
    var json = await client.post("/auth/user", {
      "phoneNumber": phoneNumber,
      "name": name,
      "gender": gender,
      "birthDay": birthDay,
      "agreeTerms": agreeTerms,
      "pushToken": pushToken,
    });
    client.clearToken();
    if (json != null) {
      return LogInResponse.fromJson(json);
    } else {
      return null;
    }
  }
  
  Future<List<Terms>> getTerms(String token) async {
    var client = HttpClient();
    client.setToken(token);
    var list = await client.getList("/terms");
    client.clearToken();
    return list.map((e) => Terms.fromJson(e)).toList();
  }

  Future<LogInResponse?> checkUser(String token, String birthDay, String pushToken) async {
    var client = HttpClient();
    client.setToken(token);
    var json = await client.post("/auth/user/check", {
      "birthDay": birthDay,
      "pushToken": pushToken,
    });
    client.clearToken();
    if (json != null) {
      return LogInResponse.fromJson(json);
    } else {
      return null;
    }
  }
}
