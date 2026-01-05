// ignore_for_file: file_names

class User {
  final int errorCode;
  final String errorDescription;
  final UserData data;

  User(
      {required this.errorCode,
      required this.errorDescription,
      required this.data});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      errorCode: json['Error_Code'] ?? 0,
      errorDescription: json['Error_Description'] ?? "",
      data: UserData.fromJson(json['Data']),
    );
  }
}

class UserData {
  final String username;
  final String name;
  final String lastname;
  final String email;
  final String imageUrl;
  final int userId;
  final String firmName;
  final List<String> pages;
  final String password;

  UserData({
    required this.username,
    required this.name,
    required this.lastname,
    required this.email,
    required this.imageUrl,
    required this.userId,
    required this.firmName,
    required this.pages,
    required this.password,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      username: json['username'] ?? "",
      name: json['name'] ?? "",
      lastname: json['lastname'] ?? "",
      email: json['email'] ?? "",
      imageUrl: json['image_url'] ?? "",
      userId: json['user_id'] ?? 0,
      firmName: json['firm_name'] ?? "",
      pages: List<String>.from(json['pages'] ?? []),
      password: json['password'] ?? "",
    );
  }
}
