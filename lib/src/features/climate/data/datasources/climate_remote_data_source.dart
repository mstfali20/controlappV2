import 'package:dio/dio.dart';

import '../../../../core/config/api_paths.dart';
import '../../../../core/config/app_config.dart';
import '../models/climate_history_entry_dto.dart';
import '../models/climate_snapshot_dto.dart';

abstract class ClimateRemoteDataSource {
  Future<ClimateSnapshotDto> fetchSnapshot({
    required String username,
    required String password,
    required String deviceId,
  });

  Future<List<ClimateHistoryEntryDto>> fetchHistory({
    required String username,
    required String password,
    required String deviceId,
    required String labelCode,
    required String period,
  });
}

class ClimateRemoteDataSourceImpl implements ClimateRemoteDataSource {
  ClimateRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<ClimateSnapshotDto> fetchSnapshot({
    required String username,
    required String password,
    required String deviceId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiPaths.currentData,
      queryParameters: {
        'username': username,
        'password': password,
        'l': AppConfig.defaultLocale,
        'device_id': deviceId,
      },
    );

    final body = response.data;
    if (body == null) {
      throw const ClimateRemoteException('empty_response');
    }

    return ClimateSnapshotDto.fromJson(body);
  }

  @override
  Future<List<ClimateHistoryEntryDto>> fetchHistory({
    required String username,
    required String password,
    required String deviceId,
    required String labelCode,
    required String period,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiPaths.deviceMonitor,
      queryParameters: {
        'username': username,
        'password': password,
        'device_id': deviceId,
        'label_code': labelCode,
        'period': period,
        'l': AppConfig.defaultLocale,
      },
    );

    final body = response.data;
    if (body == null) {
      throw const ClimateRemoteException('empty_response');
    }

    final data = body['Data'];
    if (data is List) {
      return data
          .map((dynamic item) =>
              ClimateHistoryEntryDto.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return const <ClimateHistoryEntryDto>[];
  }
}

class ClimateRemoteException implements Exception {
  const ClimateRemoteException(this.message);

  final String message;

  @override
  String toString() => 'ClimateRemoteException: $message';
}
