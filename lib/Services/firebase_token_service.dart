import 'dart:convert';
import 'dart:io';
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart';

/// Service to generate Firebase Cloud Messaging access tokens
class FirebaseTokenService {
  static const String _scope = 'https://www.googleapis.com/auth/firebase.messaging';
  static String? _cachedToken;
  static DateTime? _tokenExpiry;

  /// Get Firebase access token for sending FCM messages
  static Future<String?> getAccessToken() async {
    try {
      // Check if we have a valid cached token
      if (_cachedToken != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) {
        return _cachedToken;
      }

      // For iOS, we need to use the service account approach
      if (Platform.isIOS) {
        return await _getAccessTokenFromServiceAccount();
      }
      
      return null;
    } catch (e) {
      print('❌ Error getting Firebase access token: $e');
      return null;
    }
  }

  /// Generate token using service account credentials
  static Future<String?> _getAccessTokenFromServiceAccount() async {
    try {
      // You need to add your Firebase service account JSON to assets
      // Download it from Firebase Console → Project Settings → Service Accounts
      final serviceAccountJson = await rootBundle.loadString('assets/service-account-key.json');
      final serviceAccount = ServiceAccountCredentials.fromJson(serviceAccountJson);

      // Get access token
      final client = await clientViaServiceAccount(serviceAccount, [_scope]);
      final credentials = client.credentials;
      
      // Cache the token
      _cachedToken = credentials.accessToken.data;
      _tokenExpiry = credentials.accessToken.expiry;
      
      client.close();
      
      print('✅ Firebase access token generated successfully');
      return _cachedToken;
      
    } catch (e) {
      print('❌ Error generating service account token: $e');
      return null;
    }
  }

  /// Clear cached token (force refresh)
  static void clearCache() {
    _cachedToken = null;
    _tokenExpiry = null;
  }
}