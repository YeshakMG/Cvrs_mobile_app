import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../routes/app_pages.dart';
import '../../../../services/auth_service.dart';

class WebviewController extends GetxController {
  late final WebViewController webViewController;
  final isLoading = true.obs;
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();

    // Construct the OpenID Connect authorization URL using implicit flow
    final authUrl = Uri.parse('https://crrsa-auth.risertechservices.com/realms/crrsa-external/protocol/openid-connect/auth').replace(
      queryParameters: {
        'client_id': 'crrsa-mobile-client',
        'redirect_uri': 'https://oauth.pstmn.io/v1/callback',
        'response_type': 'code',
        'scope': 'openid profile email',
        'state': 'mobile_app_login',
        'nonce': 'mobile_app_nonce_${DateTime.now().millisecondsSinceEpoch}',
      },
    );

    print('Loading auth URL: $authUrl');

    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
            print('WebView page started: $url');
            isLoading.value = true;
          },
          onPageFinished: (String url) {
            print('WebView page finished: $url');
            isLoading.value = false;
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView resource error: ${error.description} (${error.errorType}) for URL: ${error.url}');
            Get.snackbar('Connection Error', 'Failed to load authentication page: ${error.description}', snackPosition: SnackPosition.BOTTOM);
          },
          onNavigationRequest: (NavigationRequest request) async {
            final urlString = request.url;
            print('Navigation request to: $urlString');

            final url = Uri.parse(urlString);

            // Check if this is our callback URL
            if (url.scheme == 'https' && url.host == 'oauth.pstmn.io' && url.path == '/v1/callback') {
              print('Callback URL detected: $urlString');

              // For authorization code flow, code is in query parameters
              final code = url.queryParameters['code'];
              final error = url.queryParameters['error'];
              final errorDescription = url.queryParameters['error_description'];

              print('Authorization code: $code');
              print('Error: $error');

              if (error != null) {
                print('OAuth error: $error - $errorDescription');
                Get.snackbar('Authentication Error', errorDescription ?? error, snackPosition: SnackPosition.BOTTOM);
                Get.back(); // Go back to login screen
                return NavigationDecision.prevent;
              }

              if (code != null && code.isNotEmpty) {
                print('Authorization code received, exchanging for tokens...');

                // Exchange authorization code for tokens
                final success = await _authService.exchangeCodeForTokens(code, 'https://oauth.pstmn.io/v1/callback');
                if (success) {
                  print('Tokens exchanged and stored successfully');
                  print('Navigating to home screen');
                  Get.offNamed(Routes.HOME);
                } else {
                  print('Failed to exchange code for tokens');
                  Get.snackbar('Authentication Error', 'Failed to complete authentication', snackPosition: SnackPosition.BOTTOM);
                  Get.back();
                }
                return NavigationDecision.prevent;
              } else {
                print('No authorization code found in callback');
              }
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(authUrl);
  }
}