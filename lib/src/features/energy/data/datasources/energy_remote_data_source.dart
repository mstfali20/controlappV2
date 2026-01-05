import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../../core/config/api_paths.dart';
import '../../../../core/config/app_config.dart';
import '../models/energy_data_dto.dart';
import '../models/energy_consumption_dto.dart';
import '../models/energy_category_dto.dart';

abstract class EnergyRemoteDataSource {
  Future<EnergyDataDto> fetchCurrentData({
    required String username,
    required String password,
    required String deviceId,
  });

  Future<EnergyConsumptionDto> fetchConsumptionSummary({
    required String username,
    required String password,
    required String deviceId,
    required String periodType,
    required String type,
    required String totalCheckPt,
    required String term,
  });

  Future<EnergyConsumptionDto> fetchConsumptionHistory({
    required String username,
    required String password,
    required String deviceId,
    required String periodType,
    required String type,
    required String totalCheckPt,
    required String term,
    required String startDate,
    required String endDate,
  });

  Future<EnergyCategoryDto> fetchCategoricalConsumptions({
    required String username,
    required String password,
    required String organizationId,
    required String periodType,
    required String term,
  });
}

class EnergyRemoteDataSourceImpl implements EnergyRemoteDataSource {
  EnergyRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<EnergyDataDto> fetchCurrentData({
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
      throw const EnergyDataException('empty_response');
    }
    return EnergyDataDto.fromJson(body);
  }

  @override
  Future<EnergyConsumptionDto> fetchConsumptionSummary({
    required String username,
    required String password,
    required String deviceId,
    required String periodType,
    required String type,
    required String totalCheckPt,
    required String term,
  }) async {
    return _fetchConsumptions(
      username: username,
      password: password,
      deviceId: deviceId,
      periodType: periodType,
      type: type,
      totalCheckPt: totalCheckPt,
      term: term,
    );
  }

  @override
  Future<EnergyConsumptionDto> fetchConsumptionHistory({
    required String username,
    required String password,
    required String deviceId,
    required String periodType,
    required String type,
    required String totalCheckPt,
    required String term,
    required String startDate,
    required String endDate,
  }) {
    return _fetchConsumptions(
      username: username,
      password: password,
      deviceId: deviceId,
      periodType: periodType,
      type: type,
      totalCheckPt: totalCheckPt,
      term: term,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<EnergyCategoryDto> fetchCategoricalConsumptions({
    required String username,
    required String password,
    required String organizationId,
    required String periodType,
    required String term,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiPaths.categoricalConsumptions,
      queryParameters: {
        'username': username,
        'password': password,
        'organization_id': organizationId,
        'period_type': periodType,
        'term': term,
        'l': AppConfig.defaultLocale,
      },
    );

    final body = response.data;
    if (body == null) {
      throw const EnergyDataException('empty_response');
    }
    return EnergyCategoryDto.fromJson(body);
  }

  Future<EnergyConsumptionDto> _fetchConsumptions({
    required String username,
    required String password,
    required String deviceId,
    required String periodType,
    required String type,
    required String totalCheckPt,
    required String term,
    String? startDate,
    String? endDate,
  }) async {
    final queryParameters = <String, dynamic>{
      'username': username,
      'password': password,
      'period_type': periodType,
      'device_id': deviceId,
      'type': type,
      'total_check_pt': totalCheckPt,
      'term': term,
      'l': AppConfig.defaultLocale,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
    };

    final requestUri = Uri.parse(_dio.options.baseUrl).resolveUri(
      Uri(path: ApiPaths.consumptions, queryParameters: queryParameters),
    );
    log(
      'GES consumption request -> $requestUri',
      name: 'EnergyRemoteDataSource',
    );

    final response = await _dio.get<Map<String, dynamic>>(
      ApiPaths.consumptions,
      queryParameters: queryParameters,
    );

    final body = response.data;
    if (body == null) {
      throw const EnergyDataException('empty_response');
    }
    return EnergyConsumptionDto.fromJson(body);
  }
}

class EnergyDataException implements Exception {
  const EnergyDataException(this.message);

  final String message;

  @override
  String toString() => 'EnergyDataException: $message';
}
