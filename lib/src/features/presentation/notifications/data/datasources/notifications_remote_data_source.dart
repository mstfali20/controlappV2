import 'package:dio/dio.dart';

import '../../../../../core/config/api_paths.dart';
import '../../../../../core/config/app_config.dart';
import '../models/alarm_notification_dto.dart';

abstract class NotificationsRemoteDataSource {
  Future<NotificationsResponseDto> fetchAlarms({
    required String username,
    required String password,
    String? deviceModelTypeId,
  });
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  NotificationsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<NotificationsResponseDto> fetchAlarms({
    required String username,
    required String password,
    String? deviceModelTypeId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiPaths.mobileAlarms,
      queryParameters: {
        'username': username,
        'password': password,
        'l': AppConfig.defaultLocale,
        if (deviceModelTypeId != null && deviceModelTypeId.isNotEmpty)
          'device_model_type_id': deviceModelTypeId,
      },
    );

    final body = response.data;
    if (body == null) {
      throw const NotificationsException('empty_response');
    }

    return NotificationsResponseDto.fromJson(body);
  }
}

class NotificationsException implements Exception {
  const NotificationsException(this.message);

  final String message;

  @override
  String toString() => 'NotificationsException($message)';
}
