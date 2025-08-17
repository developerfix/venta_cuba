import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:venta_cuba/Services/Supabase/supabase_service.dart';

/// Debug helper for RLS issues
class RLSDebug {
  static final SupabaseClient _client = SupabaseService.client;
  
  /// Test if RLS context is working
  static Future<void> testRLSContext(String userId) async {
    try {
      print('🔍 Testing RLS context for user: $userId');
      
      // Test 1: Try to set the context
      try {
        await _client.rpc('set_config', params: {
          'setting_name': 'app.current_user_id',
          'new_value': userId,
          'is_local': true,
        });
        print('✅ set_config function called successfully');
      } catch (e) {
        print('❌ Error calling set_config: $e');
        print('💡 The set_config function may not exist or have wrong permissions');
      }
      
      // Test 2: Try to get the current setting
      try {
        final result = await _client.rpc('current_setting', params: {
          'setting_name': 'app.current_user_id',
          'missing_ok': true,
        });
        print('🔍 Current user context: $result');
      } catch (e) {
        print('❌ Error reading current_setting: $e');
      }
      
      // Test 3: Try a simple query that should work with RLS
      try {
        final testQuery = await _client
            .from('chats')
            .select('id')
            .limit(1);
        print('✅ Simple chats query successful: ${testQuery.length} results');
      } catch (e) {
        print('❌ Simple chats query failed: $e');
        print('💡 This suggests RLS is blocking all access');
      }
      
      // Test 4: Check if we can insert a test record
      try {
        await _client
            .from('chats')
            .insert({
              'id': 'test_${DateTime.now().millisecondsSinceEpoch}',
              'sender_id': userId,
              'send_to_id': 'test_user',
              'sender_name': 'Test',
              'send_to_name': 'Test User',
              'message': 'Test message',
              'send_by': userId,
            });
        print('✅ Test insert successful');
      } catch (e) {
        print('❌ Test insert failed: $e');
        print('💡 RLS policies are preventing insert operations');
      }
      
    } catch (e) {
      print('❌ RLS Debug test failed: $e');
    }
  }
  
  /// Check RLS status
  static Future<void> checkRLSStatus() async {
    try {
      // This query should work even with RLS because it's a system query
      final result = await _client.rpc('rls_status_check');
      print('🔍 RLS Status: $result');
    } catch (e) {
      print('⚠️ Could not check RLS status: $e');
    }
  }
}