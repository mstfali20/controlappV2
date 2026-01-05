import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../../core/config/api_paths.dart';
import '../../../../core/config/app_config.dart';
import '../models/user_dto.dart';

class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  Future<UserDto> login(
    String username,
    String password, {
    String locale = AppConfig.defaultLocale,
    String? deviceToken,
  }) async {
    log("device token: ${deviceToken}");

    final response = await _dio.get<Map<String, dynamic>>(
      ApiPaths.login,
      queryParameters: {
        'username': username,
        'password': password,
        'l': locale,
        if (deviceToken != null && deviceToken.isNotEmpty) 'uuid': deviceToken,
      },
    );
    final body = response.data;
    if (body == null) {
      throw AuthApiException('empty_response');
    }

    final errorCode = body['Error_Code'];
    if (errorCode is int && errorCode != 0) {
      throw AuthApiException(
          body['Error_Description']?.toString() ?? 'login_failed');
    }

    final data = body['Data'];
    if (data is! Map<String, dynamic>) {
      throw AuthApiException('invalid_login_payload');
    }

    return UserDto.fromJson(data);
  }
}

class AuthApiException implements Exception {
  AuthApiException(this.message);

  final String message;

  @override
  String toString() => 'AuthApiException: $message';
}
