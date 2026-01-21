import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'auth_service.dart';

class ApiService extends GetxService {
  static ApiService get to => Get.find();

  late final dio.Dio _dio;
  final String baseUrl = 'https://crrsa-api.risertechservices.com/api/v1/citizen-app-service/';
  //final String baseUrl = 'https://api.aacrrsa.gov.et/api/v1/citizen-app/';
  
 


  @override
  void onInit() {
    super.onInit();
    _initDio();
  }

  void _initDio() {
    _dio = dio.Dio(dio.BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptor for token management
    _dio.interceptors.add(dio.InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add access token to requests if available
        final authService = AuthService.to;
        if (authService.accessToken.value.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer ${authService.accessToken.value}';
          // Decode token for debugging
          try {
            final parts = authService.accessToken.value.split('.');
            if (parts.length == 3) {
              final payload = json.decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
              final exp = payload['exp'];
              final iat = payload['iat'];
              final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
              print('Token exp: $exp, iat: $iat, current: $currentTime, isExpired: ${currentTime > exp}');
              print('Token aud: ${payload['aud']}, scope: ${payload['scope']}');
            }
          } catch (e) {
            print('Error decoding token: $e');
          }
        }
        print('API Request: ${options.method} ${options.baseUrl}${options.path}');
        print('Headers: ${options.headers}');
        handler.next(options);
      },
      onError: (error, handler) async {
        print('API Error: ${error.response?.statusCode} ${error.response?.data}');
        print('DEBUG: API Error URL: ${error.requestOptions.baseUrl}${error.requestOptions.path}');
        // If we get 401, try to refresh token
        if (error.response?.statusCode == 401) {
          print('DEBUG: Received 401, attempting token refresh');
          final authService = AuthService.to;
          if (authService.refreshToken.value.isNotEmpty) {
            print('DEBUG: Refresh token available, calling refresh');
            final refreshed = await authService.refreshAccessToken();
            if (refreshed) {
              print('DEBUG: Token refreshed successfully, retrying request');
              // Retry the original request
              error.requestOptions.headers['Authorization'] = 'Bearer ${authService.accessToken.value}';
              return handler.resolve(await _dio.fetch(error.requestOptions));
            } else {
              print('DEBUG: Token refresh failed');
            }
          } else {
            print('DEBUG: No refresh token available');
          }
        }
        handler.next(error);
      },
    ));
  }

  Future<dio.Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<dio.Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await _dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<dio.Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await _dio.put(path, data: data, queryParameters: queryParameters);
  }

  Future<dio.Response> delete(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.delete(path, queryParameters: queryParameters);
  }
}