import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dio/dio.dart';
import '../storage/session_storage.dart';
import 'auth_interceptor.dart';

class ApiClient {
  static ApiClient? _instance;
  late final Dio dio;

  static ApiClient get instance {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: SessionStorage.instance.getBaseUrl(),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
      ),
    );

    // Add interceptors: Auth, Chucker official interceptor, and Logger
    dio.interceptors.addAll([
      AuthInterceptor(),
      ChuckerDioInterceptor(),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
      ),
    ]);
  }

  void updateBaseUrl(String newUrl) {
    dio.options.baseUrl = newUrl;
  }
}
