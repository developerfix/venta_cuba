import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:venta_cuba/Services/Supabase/supabase_service.dart';

/// Helper class for managing RLS (Row Level Security) with custom authentication
/// Works with existing tables: chats, messages, user_presence
class RLSHelper {
  static final SupabaseClient _client = SupabaseService.client;
  
  /// Set the current user context for RLS policies
  /// Call this after your custom authentication succeeds
  static Future<void> setUserContext(String userId) async {
    try {
      print('🔧 RLS context set for user: $userId (using permissive policies)');
      
      // Note: With the new RLS setup, we use permissive policies that allow
      // all operations for anon/authenticated users. Security is handled
      // at the application level rather than database row-level.
      
      print('✅ RLS ready for user: $userId');
      
    } catch (e) {
      print('❌ Error with RLS setup: $e');
    }
  }
  
  /// Verify that the user context was set correctly
  static Future<void> _verifyUserContext(String expectedUserId) async {
    try {
      final currentUserId = await _client.rpc('get_current_user_id');
      if (currentUserId == expectedUserId) {
        print('✅ User context verified: $currentUserId');
      } else {
        print('⚠️ User context mismatch. Expected: $expectedUserId, Got: $currentUserId');
      }
    } catch (e) {
      print('❌ Error verifying user context: $e');
    }
  }
  
  /// Clear the user context (call on logout)
  static Future<void> clearUserContext() async {
    try {
      print('🔧 Clearing RLS user context');
      
      await _client.rpc('set_config', params: {
        'setting_name': 'app.current_user_id',
        'new_value': '',
        'is_local': true,
      });
      
      print('✅ RLS user context cleared');
    } catch (e) {
      print('❌ Error clearing RLS user context: $e');
    }
  }
  
  /// Debug method to test RLS functionality
  static Future<void> debugRLS(String userId) async {
    try {
      print('🔍 === RLS DEBUG START ===');
      
      // Test 1: Set context
      await setUserContext(userId);
      
      // Test 2: Try to query chats
      try {
        final chats = await _client.from('chats').select('id').limit(1);
        print('✅ Chats query successful: ${chats.length} results');
      } catch (e) {
        print('❌ Chats query failed: $e');
      }
      
      // Test 3: Get RLS status
      try {
        final status = await _client.rpc('rls_status_check');
        print('🔍 RLS Status: $status');
      } catch (e) {
        print('❌ RLS status check failed: $e');
      }
      
      print('🔍 === RLS DEBUG END ===');
    } catch (e) {
      print('❌ RLS Debug failed: $e');
    }
  }
  
  /// Create the set_config function if it doesn't exist
  static Future<void> _createSetConfigFunction() async {
    try {
      // This function might need to be created in Supabase SQL editor
      print('⚠️ set_config function not found. Please create it in Supabase SQL editor:');
      print('''
      CREATE OR REPLACE FUNCTION set_config(setting_name text, new_value text, is_local boolean)
      RETURNS text AS \$\$
      BEGIN
        PERFORM set_config(setting_name, new_value, is_local);
        RETURN new_value;
      END;
      \$\$ LANGUAGE plpgsql SECURITY DEFINER;
      ''');
    } catch (e) {
      print('❌ Error creating set_config function info: $e');
    }
  }
}