class User {
  User({
    required this.userSeq,
    required this.name,
  });
  final int userSeq;
  final String name;

  Map<String, dynamic> toJson() {
    return {
      'userSeq': userSeq,
      'name': name,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userSeq: json['userSeq'],
      name: json['name'],
    );
  }
}