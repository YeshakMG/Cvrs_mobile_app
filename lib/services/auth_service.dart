import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';

class AuthService extends GetxService {
  static AuthService get to => Get.find();
  
  late final Dio _dio;
  final String baseUrl = 'https://crrsa-auth.risertechservices.com/';
  final String clientId = 'crrsa-mobile-client';
  //final String clientSecret = '6fZk1WfC6PSfeGzNvUYd5plveBhcC45q';
  
  // Token storage
  final accessToken = ''.obs;
  final refreshToken = ''.obs;
  final tokenExpiresIn = 0.obs;
  final errorMessage = ''.obs;
  final currentUser = {}.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initDio();
    _loadStoredTokens();
  }

  Future<void> ensureInitialized() async {
    await _loadStoredTokens();
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
          final refreshed = await refreshAccessToken();
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
    // Bypass authentication for test credentials
    if (username == 'User' && password == 'password1') {
      accessToken.value = 'fake_access_token_for_testing';
      refreshToken.value = 'fake_refresh_token_for_testing';
      tokenExpiresIn.value = 3600; // 1 hour
      currentUser.value = {
        'sub': 'test-user-id',
        'email': 'User',
        'name': 'Test User',
        'preferred_username': 'User',
      };
      await storeTokens();
      return true;
    }

    try {
      final response = await _dio.post(
        '/realms/crrsa-external/protocol/openid-connect/token',
        data: {
          'client_id': clientId,
          //'client_secret': clientSecret,
          'grant_type': 'password',
          'scope': 'openid email profile api',
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
        print('Login response: $data');
        accessToken.value = data['access_token'] ?? '';
        print('this is login token: ${accessToken.value}');
        refreshToken.value = data['refresh_token'] ?? '';
        tokenExpiresIn.value = data['expires_in'] ?? 0;

        // Decode user info from access token
        if (accessToken.value.isNotEmpty) {
          try {
            final parts = accessToken.value.split('.');
            if (parts.length == 3) {
              final payload = json.decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
              currentUser.value = payload;
              print('Current user: $payload');
            }
          } catch (e) {
            print('Error decoding token: $e');
          }
        }

        // Store tokens
        await storeTokens();

        return true;
      }
      return false;
    } on DioException catch (e) {
      print('Login error: ${e.response?.data ?? e.message}');
      errorMessage.value = e.response?.data?.toString() ?? (e.message ?? 'Unknown error');
      return false;
    } catch (e) {
      print('Login error: $e');
      errorMessage.value = e.toString();
      return false;
    }
  }
  
  Future<bool> exchangeCodeForTokens(String code, String redirectUri) async {
    try {
      final response = await _dio.post(
        '/realms/crrsa-external/protocol/openid-connect/token',
        data: {
          'client_id': clientId,
          'scope': 'openid email profile api',
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': redirectUri,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print('Token exchange response: $data');
        accessToken.value = data['access_token'] ?? '';
        print('this is login token: ${accessToken.value}');
        refreshToken.value = data['refresh_token'] ?? '';
        tokenExpiresIn.value = data['expires_in'] ?? 0;

        // Decode user info from access token
        if (accessToken.value.isNotEmpty) {
          try {
            final parts = accessToken.value.split('.');
            if (parts.length == 3) {
              final payload = json.decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
              currentUser.value = payload;
              print('Current user: $payload');
            }
          } catch (e) {
            print('Error decoding token: $e');
          }
        }

        // Store tokens
        await storeTokens();

        return true;
      }
      return false;
    } on DioException catch (e) {
      print('Code exchange error: ${e.response?.data ?? e.message}');
      errorMessage.value = e.response?.data?.toString() ?? (e.message ?? 'Unknown error');
      return false;
    } catch (e) {
      print('Code exchange error: $e');
      errorMessage.value = e.toString();
      return false;
    }
  }

  Future<bool> refreshAccessToken() async {
    try {
      print('DEBUG: Attempting to refresh token');
      print('DEBUG: Refresh token length: ${refreshToken.value.length}');
      print('DEBUG: Refresh token starts with: ${refreshToken.value.substring(0, min(50, refreshToken.value.length))}');

      final response = await _dio.post(
        '/realms/crrsa-external/protocol/openid-connect/token',
        data: {
          'client_id': clientId,
          //'client_secret': clientSecret,
          'grant_type': 'refresh_token',
          'scope': 'openid email profile api',
          'refresh_token': refreshToken.value,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      print('DEBUG: Refresh response status: ${response.statusCode}');
      print('DEBUG: Refresh response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        accessToken.value = data['access_token'] ?? '';
        refreshToken.value = data['refresh_token'] ?? refreshToken.value;
        tokenExpiresIn.value = data['expires_in'] ?? 0;

        print('DEBUG: New access token obtained, length: ${accessToken.value.length}');

        // Update stored tokens
        await storeTokens();
        return true;
      }
      print('DEBUG: Refresh failed with status ${response.statusCode}');
      return false;
    } catch (e) {
      print('Token refresh error: $e');
      if (e is DioException && e.response != null) {
        print('DEBUG: Refresh error response: ${e.response!.data}');
        print('DEBUG: Refresh error status: ${e.response!.statusCode}');
      }
      await logout();
      return false;
    }
  }
  
  Future<void> logout() async {
    try {
      // Perform Keycloak logout if we have a refresh token
      if (refreshToken.value.isNotEmpty) {
        await _dio.post(
          '/realms/crrsa-external/protocol/openid-connect/logout',
          data: {
            'client_id': clientId,
            //'client_secret': clientSecret,
            'refresh_token': refreshToken.value,
          },
          options: Options(
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
            },
          ),
        );
      }
    } catch (e) {
      print('Logout error: $e');
      // Continue with local logout even if server logout fails
    }

    // Clear local tokens
    accessToken.value = '';
    refreshToken.value = '';
    tokenExpiresIn.value = 0;
    currentUser.value = {};

    // Clear stored tokens
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('token_expires_in');
  }
  
  bool get isAuthenticated => accessToken.value.isNotEmpty;
  
  Future<void> storeTokens() async {
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
