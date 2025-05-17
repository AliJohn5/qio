import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final _storage = FlutterSecureStorage();

  static Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  static Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}

enum UserType { private, company }

class User {
  String firstName;
  String lastName;
  String email;
  UserType userType;
  String imageUrl;
  String phoneNumber;
  List<String> followingEmails;
  List<String> followersEmails;

  User({
    required this.email,
    required this.userType,
    this.firstName = "",
    this.lastName = "",
    this.imageUrl = "",
    this.followersEmails = const [],
    this.followingEmails = const [],
    this.phoneNumber = "",
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'],
      phoneNumber: json['phone_number'] ?? '',
      userType:
          json['user_type'] == 'company' ? UserType.company : UserType.private,
      imageUrl: json['image_url'] ?? '',
      followersEmails: List<String>.from(json['followers_emails'] ?? []),
      followingEmails: List<String>.from(json['following_emails'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
      'user_type': userType == UserType.company ? 'company' : 'private',
      'image_url': imageUrl,
      'followers_emails': followersEmails,
      'following_emails': followingEmails,
    };
  }

  void setImage(String url) {
    imageUrl = url;
  }

  void addFollowing(String email) {
    followingEmails.add(email);
  }

  void addFollower(String email) {
    followersEmails.add(email);
  }
}
