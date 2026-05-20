import 'package:dio/dio.dart';

import '../config/app_config.dart';

class ApiClient {
  ApiClient(AppConfig config)
      : dio = Dio(
          BaseOptions(
            baseUrl: config.apiBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 20),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'X-Tenant-Id': config.tenantId,
            },
          ),
        );

  final Dio dio;

  void setBearerToken(String? token) {
    if (token == null || token.isEmpty) {
      dio.options.headers.remove('Authorization');
      return;
    }
    dio.options.headers['Authorization'] = 'Bearer $token';
  }
}
