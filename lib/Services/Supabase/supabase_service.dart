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

      // Create tables if they don't exist (run this once in Supabase SQL editor)
      await _createTablesIfNeeded();
    } catch (e) {
      print('❌ Error initializing Supabase: $e');
      rethrow;
    }
  }

  // SQL to create tables in Supabase (run this in Supabase SQL editor)
  static Future<void> _createTablesIfNeeded() async {
    // This SQL should be run in Supabase SQL editor, not from the app
    // Note: This is documentation only - the SQL is not executed from the app
    print(
        '📝 Tables structure defined. Please run the SQL in Supabase SQL editor.');

    /*
    const String createTableSQL = '''
    -- Enable UUID extension
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    
    -- Create chat table
    CREATE TABLE IF NOT EXISTS chats (
      id TEXT PRIMARY KEY,
      sender_id TEXT NOT NULL,
      send_to_id TEXT NOT NULL,
      sender_name TEXT,
      send_to_name TEXT,
      sender_image TEXT,
      send_to_image TEXT,
      message TEXT,
      time TIMESTAMPTZ DEFAULT NOW(),
      send_by TEXT,
      user_device_token TEXT,
      send_to_device_token TEXT,
      is_messaged BOOLEAN DEFAULT false,
      sender_last_read_time TIMESTAMPTZ,
      recipient_last_read_time TIMESTAMPTZ,
      created_at TIMESTAMPTZ DEFAULT NOW(),
      updated_at TIMESTAMPTZ DEFAULT NOW()
    );
    
    -- Create messages table
    CREATE TABLE IF NOT EXISTS messages (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      chat_id TEXT NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
      message TEXT,
      send_by TEXT NOT NULL,
      sender_name TEXT,
      time TIMESTAMPTZ DEFAULT NOW(),
      image TEXT,
      created_at TIMESTAMPTZ DEFAULT NOW()
    );
    
    -- Create users presence table
    CREATE TABLE IF NOT EXISTS user_presence (
      user_id TEXT PRIMARY KEY,
      is_online BOOLEAN DEFAULT false,
      last_active_time TIMESTAMPTZ DEFAULT NOW()
    );
    
    -- Create device tokens table
    CREATE TABLE IF NOT EXISTS device_tokens (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      user_id TEXT,
      device_token TEXT NOT NULL,
      platform TEXT DEFAULT 'android',
      is_active BOOLEAN DEFAULT true,
      created_at TIMESTAMPTZ DEFAULT NOW(),
      updated_at TIMESTAMPTZ DEFAULT NOW(),
      UNIQUE(user_id, device_token)
    );
    
    -- Create indexes for better performance
    CREATE INDEX IF NOT EXISTS idx_chats_sender_id ON chats(sender_id);
    CREATE INDEX IF NOT EXISTS idx_chats_send_to_id ON chats(send_to_id);
    CREATE INDEX IF NOT EXISTS idx_messages_chat_id ON messages(chat_id);
    CREATE INDEX IF NOT EXISTS idx_messages_time ON messages(time);
    CREATE INDEX IF NOT EXISTS idx_device_tokens_user_id ON device_tokens(user_id);
    CREATE INDEX IF NOT EXISTS idx_device_tokens_active ON device_tokens(is_active);
    
    -- Enable Row Level Security
    ALTER TABLE chats ENABLE ROW LEVEL SECURITY;
    ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
    ALTER TABLE user_presence ENABLE ROW LEVEL SECURITY;
    ALTER TABLE device_tokens ENABLE ROW LEVEL SECURITY;
    
    -- Create policies (adjust based on your security needs)
    -- For now, allowing all authenticated users to read/write
    CREATE POLICY "Enable all access for authenticated users" ON chats
      FOR ALL USING (true);
      
    CREATE POLICY "Enable all access for authenticated users" ON messages
      FOR ALL USING (true);
      
    CREATE POLICY "Enable all access for authenticated users" ON user_presence
      FOR ALL USING (true);
      
    CREATE POLICY "Enable all access for authenticated users" ON device_tokens
      FOR ALL USING (true);
    ''';
    */
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
          .select('platform')
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('updated_at', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        final platform = response[0]['platform'] as String;
        print('✅ Retrieved platform for user $userId: $platform');
        return platform;
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
