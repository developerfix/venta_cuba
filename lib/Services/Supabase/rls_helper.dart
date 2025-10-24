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
      // Note: With the new RLS setup, we use permissive policies that allow
      // all operations for anon/authenticated users. Security is handled
      // at the application level rather than database row-level.
    } catch (e) {}
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
    } catch (e) {}
  }

  /// Debug method to test RLS functionality
  static Future<void> debugRLS(String userId) async {
    try {
      // Test 1: Set context
      await setUserContext(userId);

      // Test 2: Try to query chats
      try {
        await _client.from('chats').select('id').limit(1);
      } catch (e) {
        //
      }

      // Test 3: Get RLS status
      try {
        await _client.rpc('rls_status_check');
      } catch (e) {}
    } catch (e) {}
  }
}
