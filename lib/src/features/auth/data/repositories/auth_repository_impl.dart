import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/logging/logger.dart';
import '../../../../core/storage/prefs.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/auth_failure.dart';
import '../../domain/entities/session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_api.dart';
import '../models/user_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthApi authApi,
    required Prefs prefs,
    required AppLogger logger,
  })  : _api = authApi,
        _prefs = prefs,
        _logger = logger;

  final AuthApi _api;
  final Prefs _prefs;
  final AppLogger _logger;

  @override
  Future<Session> login(
    String username,
    String password, {
    String? deviceToken,
  }) async {
    try {
      final dto = await _api.login(
        username,
        password,
        deviceToken: deviceToken,
      );
      return _sessionFromDto(dto, username, password);
    } on AuthApiException catch (error) {
      throw AuthFailure(error.message);
    } on DioException catch (error) {
      _logger.error('auth_login_dio_exception', error: error);
      throw const AuthFailure('network_error');
    } catch (error, stackTrace) {
      _logger.error(
        'auth_login_unknown_error',
        error: error,
        stackTrace: stackTrace,
      );
      throw const AuthFailure('unknown_error');
    }
  }

  @override
  Future<void> saveSession(Session session) async {
    await _prefs.setBool('remember_me', session.rememberMe);
    await _prefs.setString('username', session.username);
    if (session.rememberMe && (session.password?.isNotEmpty ?? false)) {
      await _prefs.setString('password', session.password!);
    } else {
      await _prefs.remove('password');
    }

    if (session.serial != null) {
      await _prefs.setString('serial', session.serial!);
    }
    if (session.serialTitle != null) {
      await _prefs.setString('serialTitle', session.serialTitle!);
    }
    if (session.plcTitle != null) {
      await _prefs.setString('plcTitle', session.plcTitle!);
    }
    if (session.selectedOrganizationId != null) {
      await _prefs.setString(
        'selected_organization_id',
        session.selectedOrganizationId!,
      );
    }

    if (session.token != null && session.token!.isNotEmpty) {
      await _prefs.setString('token', session.token!);
    } else {
      await _prefs.remove('token');
    }

    if (session.tokenIssuedAt != null) {
      await _prefs.setString(
        'token_issued_at',
        session.tokenIssuedAt!.toIso8601String(),
      );
    } else {
      await _prefs.remove('token_issued_at');
    }

    if (session.tokenExpiresAt != null) {
      await _prefs.setString(
        'token_expires_at',
        session.tokenExpiresAt!.toIso8601String(),
      );
    } else {
      await _prefs.remove('token_expires_at');
    }

    if (session.treeXml != null && session.treeXml!.isNotEmpty) {
      await _prefs.setString('tree_xml', session.treeXml!);
    } else {
      await _prefs.remove('tree_xml');
    }

    await _prefs.setString('name', session.user.name);
    await _prefs.setString('lastname', session.user.lastname);
    await _prefs.setString('email', session.user.email);
    if (session.user.imageUrl != null) {
      await _prefs.setString('image_url', session.user.imageUrl!);
    }
    await _prefs.setInt('user_id', session.user.userId);
    await _prefs.setString('firm_name', session.user.firmName);
    if (session.user.firmId != null) {
      await _prefs.setInt('firm_id', session.user.firmId!);
    }

    await _prefs.setString(
      'unit_prices',
      jsonEncode(session.user.unitPrices),
    );
    await _prefs.setString(
      'pages_json',
      jsonEncode(session.user.pages),
    );

    for (final entry in session.extras.entries) {
      final value = entry.value;
      if (value == null) {
        continue;
      }
      if (value is String) {
        await _prefs.setString(entry.key, value);
      } else if (value is int) {
        await _prefs.setInt(entry.key, value);
      } else if (value is double) {
        await _prefs.setDouble(entry.key, value);
      } else if (value is bool) {
        await _prefs.setBool(entry.key, value);
      } else {
        await _prefs.setString(entry.key, jsonEncode(value));
      }
    }
  }

  @override
  Future<Session?> getSession() async {
    final username = _prefs.getString('username');
    if (username == null || username.isEmpty) {
      return null;
    }

    final password = _prefs.getString('password');
    if (password == null || password.isEmpty) {
      final token = _prefs.getString('token');
      if (token == null || token.isEmpty) {
        return null;
      }
    }
    final rememberMe = _prefs.getBool('remember_me') ?? false;

    final unitPricesRaw = _prefs.getString('unit_prices');
    final pagesRaw = _prefs.getString('pages_json');

    final user = AppUser(
      username: username,
      name: _prefs.getString('name') ?? '',
      lastname: _prefs.getString('lastname') ?? '',
      email: _prefs.getString('email') ?? '',
      userId: _prefs.getInt('user_id') ?? 0,
      firmName: _prefs.getString('firm_name') ?? '',
      firmId: _prefs.getInt('firm_id'),
      imageUrl: _prefs.getString('image_url'),
      unitPrices: _decodeMap(unitPricesRaw),
      pages: _decodeList(pagesRaw),
    );

    final extras = <String, dynamic>{
      'unit_prices': user.unitPrices,
    };
    final selectedModule = _prefs.getString('selected_module');
    if (selectedModule != null && selectedModule.isNotEmpty) {
      extras['selected_module'] = selectedModule;
    }

    return Session(
      username: username,
      password: password,
      rememberMe: rememberMe,
      user: user,
      selectedOrganizationId: _prefs.getString('selected_organization_id'),
      serial: _prefs.getString('serial'),
      serialTitle: _prefs.getString('serialTitle'),
      plcTitle: _prefs.getString('plcTitle'),
      token: _prefs.getString('token'),
      tokenIssuedAt: _parseDateTime(_prefs.getString('token_issued_at')),
      tokenExpiresAt: _parseDateTime(_prefs.getString('token_expires_at')),
      treeXml: _prefs.getString('tree_xml'),
      extras: extras,
    );
  }

  @override
  Future<void> clearSession() async {
    await _prefs.clearKeys([
      'remember_me',
      'username',
      'password',
      'serial',
      'serialTitle',
      'plcTitle',
      'selected_organization_id',
      'name',
      'lastname',
      'email',
      'image_url',
      'user_id',
      'firm_name',
      'firm_id',
      'unit_prices',
      'pages_json',
      'selected_module',
      'token',
      'token_issued_at',
      'token_expires_at',
      'tree_xml',
    ]);
  }

  Session _sessionFromDto(
    UserDto dto,
    String username,
    String fallbackPassword,
  ) {
    final user = dto.toDomain();
    final password = dto.password ?? fallbackPassword;
    final raw = dto.raw ?? const <String, dynamic>{};
    final token = raw['token']?.toString();
    final tokenIssuedAt = _parseDateTime(raw['token_issued_at']?.toString());
    final tokenExpiresAt = _parseDateTime(raw['token_expires_at']?.toString());
    return Session(
      username: username,
      password: password,
      rememberMe: false,
      user: user,
      token: token?.isNotEmpty == true ? token : null,
      tokenIssuedAt: tokenIssuedAt,
      tokenExpiresAt: tokenExpiresAt,
      extras: dto.toLegacyExtras(),
    );
  }

  Map<String, dynamic> _decodeMap(String? raw) {
    if (raw == null || raw.isEmpty) {
      return const {};
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return decoded is Map
          ? decoded.map((key, value) => MapEntry(key.toString(), value))
          : const {};
    } catch (_) {
      return const {};
    }
  }

  List<String> _decodeList(String? raw) {
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
      return const [];
    } catch (_) {
      return const [];
    }
  }

  DateTime? _parseDateTime(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return DateTime.parse(raw).toLocal();
    } catch (_) {
      return null;
    }
  }
}
