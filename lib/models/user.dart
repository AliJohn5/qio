class User {
  final String name;
  final String email;
  final String password;
  final UserType type;
  final int followers;

  User({
    required this.name,
    required this.email,
    required this.password,
    required this.type,
    this.followers = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      password: json['password'],
      type: json['type'] == 'private' ? UserType.private : UserType.company,
      followers: json['followers'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'type': type == UserType.private ? 'private' : 'company',
      'followers': followers,
    };
  }
}

enum UserType {
  private,
  company,
}
