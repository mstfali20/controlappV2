import 'package:equatable/equatable.dart';

import 'app_user.dart';

class Session extends Equatable {
  const Session({
    required this.username,
    required this.user,
    this.password,
    this.rememberMe = false,
    this.selectedOrganizationId,
    this.serial,
    this.serialTitle,
    this.plcTitle,
    this.token,
    this.tokenIssuedAt,
    this.tokenExpiresAt,
    this.treeJson,
    this.extras = const {},
  });

  final String username;
  final String? password;
  final AppUser user;
  final bool rememberMe;
  final String? selectedOrganizationId;
  final String? serial;
  final String? serialTitle;
  final String? plcTitle;
  final String? token;
  final DateTime? tokenIssuedAt;
  final DateTime? tokenExpiresAt;
  final String? treeJson;
  final Map<String, dynamic> extras;

  bool get hasValidToken {
    if (token == null || token!.isEmpty) {
      return false;
    }
    if (tokenExpiresAt == null) {
      return true;
    }
    return tokenExpiresAt!.isAfter(DateTime.now());
  }

  Session copyWith({
    String? username,
    String? password,
    AppUser? user,
    bool? rememberMe,
    String? selectedOrganizationId,
    String? serial,
    String? serialTitle,
    String? plcTitle,
    String? token,
    DateTime? tokenIssuedAt,
    DateTime? tokenExpiresAt,
    String? treeJson,
    Map<String, dynamic>? extras,
  }) {
    return Session(
      username: username ?? this.username,
      password: password ?? this.password,
      user: user ?? this.user,
      rememberMe: rememberMe ?? this.rememberMe,
      selectedOrganizationId:
          selectedOrganizationId ?? this.selectedOrganizationId,
      serial: serial ?? this.serial,
      serialTitle: serialTitle ?? this.serialTitle,
      plcTitle: plcTitle ?? this.plcTitle,
      token: token ?? this.token,
      tokenIssuedAt: tokenIssuedAt ?? this.tokenIssuedAt,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
      treeJson: treeJson ?? this.treeJson,
      extras: extras ?? this.extras,
    );
  }

  Map<String, Object?> toPersistableMap() {
    return {
      'username': username,
      'password': password,
      'remember_me': rememberMe,
      'serial': serial,
      'serialTitle': serialTitle,
      'plcTitle': plcTitle,
      'selected_organization_id': selectedOrganizationId,
      'token': token,
      'token_issued_at': tokenIssuedAt?.toIso8601String(),
      'token_expires_at': tokenExpiresAt?.toIso8601String(),
      'tree_json': treeJson,
      'name': user.name,
      'lastname': user.lastname,
      'email': user.email,
      'image_url': user.imageUrl,
      'user_id': user.userId,
      'firm_name': user.firmName,
      'firm_id': user.firmId,
      ...extras,
    }..removeWhere((_, value) => value == null);
  }

  @override
  List<Object?> get props => [
        username,
        password,
        user,
        rememberMe,
        selectedOrganizationId,
        serial,
        serialTitle,
        plcTitle,
        token,
        tokenIssuedAt,
        tokenExpiresAt,
        treeJson,
        extras,
      ];
}
