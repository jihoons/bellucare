class User {
  User({
    required this.name,
    required this.grade,
  });
  final String name;
  final String grade;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'grade': grade,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      grade: json['grade'],
    );
  }
}

class RequestCodeResponse {
  RequestCodeResponse({
    required this.requestCode,
  });
  final String requestCode;

  factory RequestCodeResponse.fromJson(Map<String, dynamic> json) {
    return RequestCodeResponse(
      requestCode: json["requestCode"] as String,
    );
  }
}

class VerifyResponse {
  VerifyResponse({
    required this.status,
    this.token,
  });
  final VerifyStatus status;
  final String? token;

  factory VerifyResponse.fromJson(Map<String, dynamic> json) {
    return VerifyResponse(
      status: VerifyStatus.fromString(json["status"] as String),
      token: json["token"] as String?,
    );
  }
}

class Tokens {
  Tokens({
    required this.accessToken,
    required this.refreshToken,
  });
  final String accessToken;
  final String refreshToken;

  factory Tokens.fromJson(Map<String, dynamic> json) {
    return Tokens(
        accessToken: json["accessToken"] as String,
        refreshToken: json["refreshToken"] as String,
    );
  }
}

enum VerifyStatus {
  expiried,
  wrongCode,
  alreadyRegistered,
  newUser;

  static VerifyStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case "expiried":
        return VerifyStatus.expiried;
      case "wrongcode":
        return VerifyStatus.wrongCode;
      case "alreadyregistered":
        return VerifyStatus.alreadyRegistered;
      case "newuser":
        return VerifyStatus.newUser;
      default:
        throw ArgumentError("Invalid VerifyStatus string: $status");
    }
  }
}

class LogInResponse {
  LogInResponse({
    required this.tokens,
    required this.user,
  });
  final Tokens tokens;
  final User user;

  factory LogInResponse.fromJson(Map<String, dynamic> json) {
    var user = json["user"] as Map<String, dynamic>;
    var tokens = json["tokens"] as Map<String, dynamic>;

    return LogInResponse(
      tokens: Tokens.fromJson(tokens),
      user: User.fromJson(user),
    );
  }
}

class Terms {
  Terms({
    required this.termsId,
    required this.termsType,
    required this.title,
    required this.linkType,
    required this.contents,
    required this.required,
  });
  final int termsId;
  final String termsType;
  final String title;
  final String linkType;
  final String contents;
  final bool required;

  factory Terms.fromJson(Map<String, dynamic> json) {
    return Terms(
      termsId: json["termsId"] as int,
      termsType: json["termsType"] as String,
      title: json["title"] as String,
      linkType: json["linkType"] as String,
      contents: json["contents"] as String,
      required: json["required"] as bool,
    );
  }
}