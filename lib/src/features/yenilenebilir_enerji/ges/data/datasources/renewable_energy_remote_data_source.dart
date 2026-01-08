import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../../../core/config/api_paths.dart';
import '../../../../../core/config/app_config.dart';
import '../models/renewable_energy_consumption_dto.dart';

abstract class RenewableEnergyRemoteDataSource {
  Future<RenewableEnergyConsumptionDto> fetchConsumptionHistory({
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
}

class RenewableEnergyRemoteDataSourceImpl
    implements RenewableEnergyRemoteDataSource {
  RenewableEnergyRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<RenewableEnergyConsumptionDto> fetchConsumptionHistory({
    required String username,
    required String password,
    required String deviceId,
    required String periodType,
    required String type,
    required String totalCheckPt,
    required String term,
    required String startDate,
    required String endDate,
  }) async {
    final queryParameters = <String, dynamic>{
      'username': username,
      'password': password,
      'period_type': periodType,
      'device_id': deviceId,
      'type': type,
      'total_check_pt': totalCheckPt,
      'term': term,
      'start_date': startDate,
      'end_date': endDate,
      'l': AppConfig.defaultLocale,
    };

    final requestUri = Uri.parse(_dio.options.baseUrl).resolveUri(
      Uri(path: ApiPaths.consumptions, queryParameters: queryParameters),
    );
    log(
      'Renewable GES consumption request -> $requestUri',
      name: 'RenewableEnergyRemoteDataSource',
    );

    final response = await _dio.get<Map<String, dynamic>>(
      ApiPaths.consumptions,
      queryParameters: queryParameters,
    );

    final body = response.data;
    if (body == null) {
      throw const RenewableEnergyDataException('empty_response');
    }
    return RenewableEnergyConsumptionDto.fromJson(body);
  }
}

class RenewableEnergyDataException implements Exception {
  const RenewableEnergyDataException(this.message);

  final String message;

  @override
  String toString() => 'RenewableEnergyDataException: $message';
}
