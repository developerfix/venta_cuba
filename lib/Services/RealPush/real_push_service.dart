import 'package:venta_cuba/Services/RealPush/ntfy_push_service.dart';

/// Real Push Service - Main coordinator for push notifications in Cuba
/// 
/// This service acts as the main entry point for all push notification
/// operations, using ntfy.sh as the underlying technology.
class RealPushService {
  static bool _isInitialized = false;
  
  /// Initialize push notifications for a user
  static Future<void> initialize({
    required String userId,
    String? customServerUrl,
  }) async {
    if (_isInitialized && NtfyPushService.isConnected) {
      print('✅ Push service already initialized');
      return;
    }
    
    print('🚀 Initializing Real Push Service for Cuba...');
    
    // Initialize ntfy service
    await NtfyPushService.initialize(
      userId: userId,
      customServerUrl: customServerUrl,
    );
    
    _isInitialized = true;
    print('✅ Real Push Service initialized successfully');
  }
  
  /// Update the server URL (for self-hosted ntfy instances)
  static Future<void> updateServerUrl(String newUrl) async {
    await NtfyPushService.updateServerUrl(newUrl);
  }
  
  /// Get connection status
  static bool get isConnected => NtfyPushService.isConnected;
  
  /// Clean up resources
  static Future<void> dispose() async {
    await NtfyPushService.dispose();
    _isInitialized = false;
  }
}
