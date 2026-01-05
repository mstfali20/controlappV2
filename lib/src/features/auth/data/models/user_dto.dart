import '../../domain/entities/app_user.dart';

class UserDto {
  UserDto({
    required this.username,
    required this.name,
    required this.lastname,
    required this.email,
    required this.userId,
    required this.firmName,
    this.firmId,
    this.imageUrl,
    this.pages = const [],
    this.unitPrices = const {},
    this.password,
    this.raw,
  });

  final String username;
  final String name;
  final String lastname;
  final String email;
  final int userId;
  final String firmName;
  final int? firmId;
  final String? imageUrl;
  final List<String> pages;
  final Map<String, dynamic> unitPrices;
  final String? password;
  final Map<String, dynamic>? raw;

  factory UserDto.fromJson(Map<String, dynamic> json) {
    final unitPrices = (json['unit_prices'] as Map<dynamic, dynamic>?)
            ?.map((key, value) => MapEntry(key.toString(), value)) ??
        const <String, dynamic>{};
    return UserDto(
      username: json['username']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      lastname: json['lastname']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      userId: json['user_id'] is int
          ? json['user_id'] as int
          : int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      firmName: json['firm_name']?.toString() ?? '',
      firmId: json['firm_id'] is int
          ? json['firm_id'] as int?
          : int.tryParse(json['firm_id']?.toString() ?? ''),
      pages: (json['pages'] as List?)?.map((e) => e.toString()).toList() ??
          const <String>[],
      unitPrices: unitPrices,
      password: json['password']?.toString(),
      raw: json,
    );
  }

  AppUser toDomain() {
    return AppUser(
      username: username,
      name: name,
      lastname: lastname,
      email: email,
      userId: userId,
      firmName: firmName,
      firmId: firmId,
      imageUrl: imageUrl,
      pages: pages,
      unitPrices: unitPrices,
    );
  }

  Map<String, dynamic> toLegacyExtras() {
    return {
      'username': username,
      'name': name,
      'lastname': lastname,
      'email': email,
      'image_url': imageUrl,
      'user_id': userId,
      'firm_name': firmName,
      'firm_id': firmId,
      'unit_prices': unitPrices,
    }..removeWhere((_, value) => value == null);
  }
}
