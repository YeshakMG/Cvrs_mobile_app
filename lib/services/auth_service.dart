import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();
  
  late final Dio _dio;
  final String baseUrl = 'https://crrsa-auth.risertechservices.com';
  final String clientId = 'crrsa-portal-client';
  final String clientSecret = '6fZk1WfC6PSfeGzNvUYd5plveBhcC45q';
  
  // Token storage
  final accessToken = ''.obs;
  final refreshToken = ''.obs;
  final tokenExpiresIn = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initDio();
    _loadStoredTokens();
  }
  
  void _initDio() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      },
    ));
    
    // Add interceptor for token management
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add access token to requests if available
        if (accessToken.value.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer ${accessToken.value}';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // If we get 401, try to refresh token
        if (error.response?.statusCode == 401 && refreshToken.value.isNotEmpty) {
          final refreshed = await _refreshAccessToken();
          if (refreshed) {
            // Retry the original request
            error.requestOptions.headers['Authorization'] = 'Bearer ${accessToken.value}';
            return handler.resolve(await _dio.fetch(error.requestOptions));
          }
        }
        handler.next(error);
      },
    ));
  }
  
  Future<bool> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/realms/crrsa-external/protocol/openid-connect/token',
        data: {
          'client_id': clientId,
          'client_secret': clientSecret,
          'grant_type': 'password',
          'username': username,
          'password': password,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        accessToken.value = data['access_token'] ?? '';
        refreshToken.value = data['refresh_token'] ?? '';
        tokenExpiresIn.value = data['expires_in'] ?? 0;
        
        // Store tokens
        await _storeTokens();
        
        return true;
      }
      return false;
    } on DioException catch (e) {
      print('Login error: ${e.response?.data ?? e.message}');
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }
  
  Future<bool> _refreshAccessToken() async {
    try {
      final response = await _dio.post(
        '/realms/crrsa-external/protocol/openid-connect/token',
        data: {
          'client_id': clientId,
          'client_secret': clientSecret,
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken.value,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        accessToken.value = data['access_token'] ?? '';
        refreshToken.value = data['refresh_token'] ?? refreshToken.value;
        tokenExpiresIn.value = data['expires_in'] ?? 0;
        
        // Update stored tokens
        await _storeTokens();
        return true;
      }
      return false;
    } catch (e) {
      print('Token refresh error: $e');
      await logout();
      return false;
    }
  }
  
  Future<void> logout() async {
    accessToken.value = '';
    refreshToken.value = '';
    tokenExpiresIn.value = 0;
    
    // Clear stored tokens
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('token_expires_in');
  }
  
  bool get isAuthenticated => accessToken.value.isNotEmpty;
  
  Future<void> _storeTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken.value);
    await prefs.setString('refresh_token', refreshToken.value);
    await prefs.setInt('token_expires_in', tokenExpiresIn.value);
  }
  
  Future<void> _loadStoredTokens() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken.value = prefs.getString('access_token') ?? '';
    refreshToken.value = prefs.getString('refresh_token') ?? '';
    tokenExpiresIn.value = prefs.getInt('token_expires_in') ?? 0;
  }
}