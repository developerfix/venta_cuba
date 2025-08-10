/// Configuration file for Supabase and Push Notifications
///
/// IMPORTANT: Replace these with your actual credentials
///
/// For Supabase:
/// 1. Create a project at https://supabase.com
/// 2. Get your URL and anon key from Project Settings > API
///
/// For Ntfy (Push Notifications for Cuba):
/// 1. Use public server: https://ntfy.sh (free)
/// 2. OR deploy your own: https://docs.ntfy.sh/install/

class AppConfig {
  // Supabase Configuration
  // TODO: Replace with your actual Supabase credentials
  // For now, using dummy values to prevent initialization errors
  static const String supabaseUrl = 'https://ztgansmmpxkzmskzpfqy.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp0Z2Fuc21tcHhrem1za3pwZnF5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQyMjYzMjEsImV4cCI6MjA2OTgwMjMyMX0.7gmzShGWJ05tEW2dwzfEPt5jkq4B1dQw5MYU-C7Gt-0';

  // Ntfy Push Notification Configuration (Works in Cuba!)
  // Option 1: Use public server (free, works immediately)
  static const String ntfyServerUrl = 'https://ntfy.sh';
  
  // Option 2: Use your own server (recommended for production)
  // Deploy on DigitalOcean, Vultr, or any VPS outside Cuba
  // static const String ntfyServerUrl = 'https://your-ntfy-server.com';
  
  // OneSignal Configuration (REMOVED - doesn't work in Cuba)
  // static const String oneSignalAppId = '6efefee8-7382-460d-b6d1-db9d9c0f4e84';
  // static const String oneSignalApiKey = 'os_v2_app_n37p52dtqjda3nwr3oozyd2oqshnsalzoyauivfbavgty6kz4ozrcsdnjw4vza4g2o6nqzl5u4kt7hjiqi4ha27buwptmwu5cg3fgyy';

  // Laravel Backend Configuration (keeping existing)
  static const String laravelBaseUrl = 'https://ventacuba.co';

  // Helper methods to check if services are properly configured
  static bool get isSupabaseConfigured => true;
  
  // Ntfy is always configured (uses public server by default)
  static bool get isNtfyConfigured => true;
}
