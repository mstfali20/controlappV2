import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({
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

  AppUser copyWith({
    String? username,
    String? name,
    String? lastname,
    String? email,
    int? userId,
    String? firmName,
    int? firmId,
    String? imageUrl,
    List<String>? pages,
    Map<String, dynamic>? unitPrices,
  }) {
    return AppUser(
      username: username ?? this.username,
      name: name ?? this.name,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      userId: userId ?? this.userId,
      firmName: firmName ?? this.firmName,
      firmId: firmId ?? this.firmId,
      imageUrl: imageUrl ?? this.imageUrl,
      pages: pages ?? this.pages,
      unitPrices: unitPrices ?? this.unitPrices,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'name': name,
      'lastname': lastname,
      'email': email,
      'user_id': userId,
      'firm_name': firmName,
      'firm_id': firmId,
      'image_url': imageUrl,
      'pages': pages,
      'unit_prices': unitPrices,
    }..removeWhere((_, value) => value == null);
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      username: map['username'] as String? ?? '',
      name: map['name'] as String? ?? '',
      lastname: map['lastname'] as String? ?? '',
      email: map['email'] as String? ?? '',
      userId: map['user_id'] is int
          ? map['user_id'] as int
          : int.tryParse(map['user_id']?.toString() ?? '') ?? 0,
      firmName: map['firm_name'] as String? ?? '',
      firmId: map['firm_id'] is int
          ? map['firm_id'] as int?
          : int.tryParse(map['firm_id']?.toString() ?? ''),
      imageUrl: map['image_url'] as String?,
      pages: (map['pages'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      unitPrices: (map['unit_prices'] as Map?)?.cast<String, dynamic>() ?? const {},
    );
  }

  @override
  List<Object?> get props => [
        username,
        name,
        lastname,
        email,
        userId,
        firmName,
        firmId,
        imageUrl,
        pages,
        unitPrices,
      ];
}
