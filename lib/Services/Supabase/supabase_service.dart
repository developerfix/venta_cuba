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

  /// Save device token to Supabase
  Future<bool> saveDeviceToken(String deviceToken,
      {String platform = 'android'}) async {
    try {
      await client.from('device_tokens').upsert({
        'device_token': deviceToken,
        'platform': platform,
        'is_active': true,
        'updated_at': DateTime.now().toIso8601String(),
      }).select();

      print('✅ Device token saved: $deviceToken');
      return true;
    } catch (e) {
      print('❌ Error saving device token: $e');
      return false;
    }
  }

  /// Associate device token with a user
  Future<bool> associateTokenWithUser(String userId, String deviceToken,
      {String platform = 'android'}) async {
    try {
      // Use upsert with explicit conflict resolution on the unique constraint (user_id, device_token)
      await client.from('device_tokens').upsert({
        'user_id': userId,
        'device_token': deviceToken,
        'platform': platform,
        'is_active': true,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,device_token').select();

      print('✅ Device token associated/updated for user: $userId');
      return true;
    } catch (e) {
      print('❌ Error associating device token with user: $e');
      return false;
    }
  }

  /// Save device token with platform information - SIMPLIFIED
  Future<bool> saveDeviceTokenWithPlatform({
    required String userId,
    required String token,
    required String platform,
  }) async {
    try {
      // First, deactivate any existing tokens for this user on this platform
      await client
          .from('device_tokens')
          .update({'is_active': false})
          .eq('user_id', userId)
          .eq('platform', platform);

      // Insert or update the new token
      await client.from('device_tokens').upsert({
        'user_id': userId,
        'device_token': token,
        'platform': platform,
        'is_active': true,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,device_token');

      print('✅ Device token saved for $platform user: $userId');
      return true;
    } catch (e) {
      print('❌ Error saving device token: $e');
      return false;
    }
  }

  /// Get device tokens for a specific user
  Future<List<String>> getUserDeviceTokens(String userId) async {
    try {
      final response = await client
          .from('device_tokens')
          .select('device_token')
          .eq('user_id', userId)
          .eq('is_active', true);

      final tokens = (response as List)
          .map((item) => item['device_token'] as String)
          .toList();

      print('✅ Retrieved ${tokens.length} device tokens for user: $userId');
      return tokens;
    } catch (e) {
      print('❌ Error getting user device tokens: $e');
      return [];
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

  /// Remove all device tokens for a user
  Future<bool> removeUserDeviceTokens(String userId) async {
    try {
      await client
          .from('device_tokens')
          .update({'is_active': false}).eq('user_id', userId);

      print('✅ All device tokens removed for user: $userId');
      return true;
    } catch (e) {
      print('❌ Error removing user device tokens: $e');
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

  /// Send push notification via Firebase (server-side implementation needed)
  Future<bool> sendPushNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get user's device tokens
      final tokens = await getUserDeviceTokens(userId);

      if (tokens.isEmpty) {
        print('⚠️ No device tokens found for user: $userId');
        return false;
      }

      // In a real implementation, you would call your backend API
      // that uses Firebase Admin SDK to send notifications
      // For now, we'll just log the notification details
      print('🔔 Sending notification to ${tokens.length} devices');
      print('Title: $title');
      print('Body: $body');
      print('Data: $data');
      print('Tokens: $tokens');

      // You would implement server-side Firebase push notification here
      // Example backend endpoint: POST /api/send-notification
      // Body: { tokens, title, body, data }

      return true;
    } catch (e) {
      print('❌ Error sending push notification: $e');
      return false;
    }
  }
}
