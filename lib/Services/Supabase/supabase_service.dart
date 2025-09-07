import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient? _client;
  static SupabaseService? _instance;

  static SupabaseService get instance {
    _instance ??= SupabaseService._internal();
    return _instance!;
  }

  SupabaseService._internal();

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception(
          'Supabase not initialized. Call SupabaseService.initialize() first.');
    }
    return _client!;
  }

  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.implicit,
          autoRefreshToken: true,
        ),
        realtimeClientOptions: const RealtimeClientOptions(
          logLevel: RealtimeLogLevel.info,
          eventsPerSecond: 2,
        ),
        storageOptions: const StorageClientOptions(
          retryAttempts: 3,
        ),
      );

      _client = Supabase.instance.client;
      print('✅ Supabase initialized successfully');
    } catch (e) {
      print('❌ Error initializing Supabase: $e');
      rethrow;
    }
  }

  // Helper method to handle Supabase errors
  static String getErrorMessage(dynamic error) {
    if (error is PostgrestException) {
      return error.message;
    } else if (error is StorageException) {
      return error.message;
    } else if (error is AuthException) {
      return error.message;
    } else {
      return error.toString();
    }
  }

  // Device Token Management Methods

  /// Save device token with platform information - SIMPLIFIED
  Future<bool> saveDeviceTokenWithPlatform({
    required String userId,
    required String token,
    required String platform,
  }) async {
    try {
      // First, delete any existing tokens for this user on this platform
      await client
          .from('device_tokens')
          .delete()
          .eq('user_id', userId)
          .eq('platform', platform);

      // Insert the new token (single token per user per platform)
      await client.from('device_tokens').insert({
        'user_id': userId,
        'device_token': token,
        'platform': platform,
        'is_active': true,
        'updated_at': DateTime.now().toIso8601String(),
      });

      print('✅ Device token saved for $platform user: $userId');
      return true;
    } catch (e) {
      //
      return false;
    }
  }

  /// Get the most recent device token for a specific user (single token)
  Future<String?> getDeviceToken(String userId) async {
    try {
      final response = await client
          .from('device_tokens')
          .select('device_token')
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('updated_at', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        final token = response[0]['device_token'] as String;
        print(
            '✅ Retrieved device token for user $userId: ${token.substring(0, 20)}...');
        return token;
      }

      print('⚠️ No device token found for user: $userId');
      return null;
    } catch (e) {
      print('❌ Error getting device token for user $userId: $e');
      return null;
    }
  }

  /// Remove device token
  Future<bool> removeDeviceToken(String deviceToken) async {
    try {
      await client
          .from('device_tokens')
          .update({'is_active': false}).eq('device_token', deviceToken);

      print('✅ Device token removed: $deviceToken');
      return true;
    } catch (e) {
      print('❌ Error removing device token: $e');
      return false;
    }
  }

  /// Get user's platform based on their device tokens
  Future<String?> getUserPlatform(String userId) async {
    try {
      final response = await client
          .from('device_tokens')
          .select('platform, device_token')
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('updated_at', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        final platform = response[0]['platform'] as String?;
        final token = response[0]['device_token'] as String?;

        // If platform is explicitly set, use it
        if (platform != null && platform.isNotEmpty) {
          print('✅ Retrieved platform for user $userId: $platform');
          return platform;
        }

        // Fallback: detect platform from token pattern
        if (token != null) {
          if (token.startsWith('ntfy_user_') ||
              token == 'cuba-friendly-token') {
            print(
                '✅ Detected Android platform for user $userId from token pattern');
            return 'android';
          } else if (token.length > 100) {
            print('✅ Detected iOS platform for user $userId from token length');
            return 'ios';
          }
        }
      }

      print('⚠️ No platform found for user: $userId');
      return null;
    } catch (e) {
      print('❌ Error getting platform for user $userId: $e');
      return null;
    }
  }
}
