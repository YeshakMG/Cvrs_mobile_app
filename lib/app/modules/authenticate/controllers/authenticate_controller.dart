import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:jose/jose.dart';
import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import '../../../../services/auth_service.dart';
import '../views/qr_scanner_view.dart' as qr_scanner;

class AuthenticatedUser {
  final String certificateNo;
  final String fullName;
  final String dateOfBirth;
  final String address;
  final String phoneNo;
  final String nationality;

  AuthenticatedUser({
    required this.certificateNo,
    required this.fullName,
    required this.dateOfBirth,
    required this.address,
    required this.phoneNo,
    required this.nationality,
  });
}

class DocumentVerificationResponse {
  final bool isValid;
  final String? documentType;
  final String? issuedDate;
  final String? expiryDate;
  final String? error;
  final Map<String, dynamic>? credentialSubject;

  DocumentVerificationResponse({
    required this.isValid,
    this.documentType,
    this.issuedDate,
    this.expiryDate,
    this.error,
    this.credentialSubject,
  });
}

// Cache JWKS (24 hours)
class JWKSCache {
  static Map<String, dynamic>? _cachedJWKS;
  static DateTime? _cacheExpiry;

  static Future<Map<String, dynamic>> getJWKS() async {
    if (_cachedJWKS != null &&
        _cacheExpiry != null &&
        DateTime.now().isBefore(_cacheExpiry!)) {
      return _cachedJWKS!;
    }

    final response = await http.get(
      Uri.parse('https://crrsa-test.aacrrsa.gov.et/api/v1/credential-service/keys/.well-known/jwks.json'),
    );

    _cachedJWKS = jsonDecode(response.body);
    _cacheExpiry = DateTime.now().add(Duration(hours: 24));

    return _cachedJWKS!;
  }
}

String decodeAndDecompress(String qrString) {
  try {
    // Base64URL decode
    String base64 = qrString.replaceAll('-', '+').replaceAll('_', '/');
    while (base64.length % 4 != 0) {
      base64 += '=';
    }
    Uint8List decodedBytes = base64Decode(base64);

    // Decompress using zlib
    List<int> decompressedBytes = ZLibDecoder().decodeBytes(decodedBytes);

    // Convert to JWT string
    return utf8.decode(decompressedBytes);
  } catch (e) {
    // If decoding fails, assume qrString is already the JWT
    return qrString;
  }
}

String? getKidFromJWT(String jwt) {
  List<String> parts = jwt.split('.');
  if (parts.length != 3) return null;

  // Decode header
  String headerJson = utf8.decode(base64Url.decode(parts[0]));
  Map<String, dynamic> header = jsonDecode(headerJson);

  return header['kid'] as String?;
}

Map<String, dynamic>? findJWKByKid(Map<String, dynamic> jwks, String kid) {
  List<dynamic> keys = jwks['keys'] ?? [];
  for (var key in keys) {
    if (key['kid'] == kid) {
      return Map<String, dynamic>.from(key);
    }
  }
  return null;
}

Future<Map<String, dynamic>?> verifyJWT(String jwt, Map<String, dynamic> jwk) async {
  try {
    // Create JsonWebKey from JWK
    JsonWebKey jsonWebKey = JsonWebKey.fromJson(jwk);
    JsonWebKeyStore keyStore = JsonWebKeyStore()..addKey(jsonWebKey);

    // Parse and verify JWT
    JsonWebToken jsonWebToken = JsonWebToken.unverified(jwt);
    bool verified = await jsonWebToken.verify(keyStore);

    if (!verified) return null;

    // Get verified payload
    Map<String, dynamic> claims = jsonWebToken.claims.toJson();

    // Check expiration
    if (claims['exp'] != null) {
      int exp = claims['exp'] as int;
      int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (now > exp) throw Exception('JWT expired');
    }

    return claims;
  } catch (e) {
    return null;
  }
}

DocumentVerificationResponse transformPayload(Map<String, dynamic> jwtPayload) {
  Map<String, dynamic>? vc = jwtPayload['vc'] as Map<String, dynamic>?;

  if (vc == null) {
    return DocumentVerificationResponse(
      isValid: false,
      error: 'Missing vc claim',
    );
  }

  // Extract document type
  String documentType = 'Unknown';
  dynamic vcType = vc['type'];
  if (vcType is List && vcType.length > 1) {
    String typeString = vcType[1].toString();
    documentType = typeString.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    ).trim();
  }

  // Convert timestamps
  String? issuedDate;
  if (jwtPayload['iat'] != null) {
    int iat = jwtPayload['iat'] as int;
    issuedDate = DateTime.fromMillisecondsSinceEpoch(iat * 1000).toIso8601String();
  }

  String? expiryDate;
  if (jwtPayload['exp'] != null) {
    int exp = jwtPayload['exp'] as int;
    expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000).toIso8601String();
  }

  // Extract credentialSubject (ONLY this, not jti, iss, sub, etc.)
  Map<String, dynamic>? credentialSubject = vc['credentialSubject'] as Map<String, dynamic>?;

  return DocumentVerificationResponse(
    isValid: true,
    documentType: documentType,
    issuedDate: issuedDate,
    expiryDate: expiryDate,
    credentialSubject: credentialSubject ?? {},
  );
}

Future<DocumentVerificationResponse> verifyQRCode(String qrString) async {
  try {
    // Step 1: Decode and decompress
    String jwt = decodeAndDecompress(qrString);

    // Step 2: Get kid from header
    String? kid = getKidFromJWT(jwt);
    if (kid == null) {
      return DocumentVerificationResponse(
        isValid: false,
        error: 'Missing key ID',
      );
    }

    // Step 3: Fetch JWKS and find key
    Map<String, dynamic> jwks = await JWKSCache.getJWKS();
    Map<String, dynamic>? jwk = findJWKByKid(jwks, kid);

    if (jwk == null) {
      return DocumentVerificationResponse(
        isValid: false,
        error: 'Key not found: $kid',
      );
    }

    // Step 4: Verify JWT
    Map<String, dynamic>? verifiedPayload = await verifyJWT(jwt, jwk);

    if (verifiedPayload == null) {
      return DocumentVerificationResponse(
        isValid: false,
        error: 'JWT verification failed',
      );
    }

    // Step 5: Transform payload
    return transformPayload(verifiedPayload);

  } catch (e) {
    return DocumentVerificationResponse(
      isValid: false,
      error: 'Verification failed: ${e.toString()}',
    );
  }
}

class AuthenticateController extends GetxController {
  final certificateId = ''.obs;
  final residentId = 'RES-123456'.obs;
  final isAuthenticated = false.obs;
  final isLoading = false.obs;
  final authenticatedUser = Rx<AuthenticatedUser?>(null);

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void scanQRCode() async {
    try {
      print('Reading: Starting QR code scan...');
      final result = await Get.to(() => const qr_scanner.QRScannerPage());
      print('Reading: QR scan result received: $result');
      if (result != null && result is String) {
        print('Reading: Scanned data is valid, proceeding to verify...');
        await verifyCredential(result);
      } else {
        print('Reading: QR scan result is invalid');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to scan QR code',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> verifyCredential(String scannedData) async {
    print('Extracted QR data: $scannedData');
    print('Step 4: Starting credential verification');
    isLoading.value = true;
    try {
      print('Step 5: Decoding and decompressing QR data...');
      String credential = decodeAndDecompress(scannedData);
      print('Step 6: Decoded credential: $credential');
      print('Step 7: Sending QR data to verifier API...');
      print('Request body: {"qrData": "$scannedData", "inputType": "qr_string"}');
      
      final dioInstance = dio.Dio();
      final authService = AuthService.to;
      final response = await dioInstance.post(
        'https://crrsa-test.aacrrsa.gov.et/api/v1/credential-service/credentials/verify',
        data: {
          'qrData': scannedData,
          'inputType': 'qr_string'
        },
        // options: dio.Options(
        //   headers: {
        //     'Content-Type': 'application/json',
        //     if (authService.accessToken.value.isNotEmpty)
        //       'Authorization': 'Bearer ${authService.accessToken.value}',
        //   },
        // ),
      );

      if (response.statusCode == 200) {
        final apiResponse = response.data;
        print('Step 6: API response received:');
        print('Full response body: $apiResponse');
        print('Response data details:');
        print('- success: ${apiResponse['success']}');
        print('- message: ${apiResponse['message']}');
        print('- data: ${apiResponse['data']}');
        print('- timestamp: ${apiResponse['timestamp']}');

        if (apiResponse['success'] == true) {
          final data = apiResponse['data'];

          // Check if the credential is valid
          if (data['valid'] == true) {
            // Extract credential data for valid credentials
            final credentialData = data['credential']['credentialSubject'];
            print('API Response Body - status: ${data['status']}');
            print('credentialSubject:');
            print(credentialData);

            authenticatedUser.value = AuthenticatedUser(
              certificateNo: credentialData['registrationNo'] ?? credentialData['residentId'] ?? scannedData,
              fullName: credentialData['fullNameEn'] ?? 'Unknown',
              dateOfBirth: credentialData['dob'] ?? 'Unknown',
              address: credentialData['address'] ?? 'Unknown',
              phoneNo: credentialData['phoneNo'] ?? 'N/A',
              nationality: credentialData['nationality'] ?? 'Ethiopian',
            );
            certificateId.value = credentialData['registrationNo'] ?? credentialData['residentId'] ?? scannedData;
            isAuthenticated.value = true;
            print('Step 8: Authentication successful');
            Get.snackbar(
              'Success',
              apiResponse['message'] ?? 'Credential verified successfully',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          } else {
            // Handle invalid credentials
            final errorMessage = data['error'] ?? 'Credential verification failed';
            final status = data['status'] ?? 'UNKNOWN_ERROR';
            print('Step 7: Verification failed - Status: $status, Error: $errorMessage');

            Get.snackbar(
              'Verification Failed',
              errorMessage,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        } else {
          print('Step 7: API request failed: ${apiResponse['message']}');
          Get.snackbar(
            'Error',
            apiResponse['message'] ?? 'Verification failed',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        throw Exception('API request failed with status ${response.statusCode}');
      }
    } catch (e) {
      print('Verification Error: $e');
      Get.snackbar(
        'Error',
        'Failed to verify credential.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      print('Step 8: Verification process completed');
    }
  }

  void authenticateCertificate() async {
    if (certificateId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a certificate ID',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    // Simulate authentication process
    await Future.delayed(const Duration(seconds: 2));

    // For demo purposes, authenticate if certificate ID is not empty
    isAuthenticated.value = true;

    // Create dummy authenticated user data
    authenticatedUser.value = AuthenticatedUser(
      certificateNo: certificateId.value,
      fullName: 'Isaac Mesfin',
      dateOfBirth: '1990-01-15',
      address: 'Addis Ababa, Ethiopia',
      phoneNo: '+251 912 345 678',
      nationality: 'Ethiopian',
    );

    isLoading.value = false;

    Get.snackbar(
      'Success',
      'Certificate authenticated successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
