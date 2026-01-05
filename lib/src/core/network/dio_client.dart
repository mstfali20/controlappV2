import 'package:dio/dio.dart';

import '../config/app_config.dart';

class DioClient {
  DioClient()
      : dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 10),
          ),
        ) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
      ),
    );
  }

  final Dio dio;

  Map<String, dynamic> withLocale(
    Map<String, dynamic>? queryParameters, {
    bool overrideLocale = false,
  }) {
    final params = <String, dynamic>{...(queryParameters ?? {})};
    if (overrideLocale || !params.containsKey('l')) {
      params['l'] = AppConfig.defaultLocale;
    }
    return params;
  }
}
