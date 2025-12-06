import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'auth_service.dart';

class ApiService extends GetxService {
  static ApiService get to => Get.find();

  late final dio.Dio _dio;
  final String baseUrl = 'https://crrsa-api.risertechservices.com/';

  @override
  void onInit() {
    super.onInit();
    _initDio();
  }

  void _initDio() {
    _dio = dio.Dio(dio.BaseOptions(
      baseUrl: baseUrl,
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
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // If we get 401, try to refresh token
        if (error.response?.statusCode == 401) {
          final authService = AuthService.to;
          if (authService.refreshToken.value.isNotEmpty) {
            final refreshed = await authService.refreshAccessToken();
            if (refreshed) {
              // Retry the original request
              error.requestOptions.headers['Authorization'] = 'Bearer ${authService.accessToken.value}';
              return handler.resolve(await _dio.fetch(error.requestOptions));
            }
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