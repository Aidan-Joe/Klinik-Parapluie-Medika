class User {
  final String role;
  final String code;
  final String name;

  User({
    required this.role,
    required this.code,
    required this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      role: json['role'],
      code: json['code'],
      name: json['name'],
    );
  }
}