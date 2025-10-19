/// Debug configuration for controlling console output
class DebugConfig {
  // Global debug flag - set to false to disable all debug prints
  static const bool enableDebugPrints = false;

  // Specific category flags
  static const bool enablePerformanceLogs = false;
  static const bool enableBadgeLogs = false;
  static const bool enableChatLogs = false;
  static const bool enableNavigationLogs = false;
  static const bool enablePushNotificationLogs = false;
  static const bool enableImageLogs = false;
  static const bool enableSupabaseLogs = false;
  static const bool enableBackgroundServiceLogs = false;

  /// Safe debug print that respects global debug flag
  static void debugPrint(String message) {
    if (enableDebugPrints) {
print(message);
    }
  }

  /// Category-specific debug prints
  static void performanceLog(String message) {
    if (enableDebugPrints && enablePerformanceLogs) {
print(message);
    }
  }

  static void badgeLog(String message) {
    if (enableDebugPrints && enableBadgeLogs) {
print(message);
    }
  }

  static void chatLog(String message) {
    if (enableDebugPrints && enableChatLogs) {
print(message);
    }
  }

  static void navigationLog(String message) {
    if (enableDebugPrints && enableNavigationLogs) {
print(message);
    }
  }

  static void pushLog(String message) {
    if (enableDebugPrints && enablePushNotificationLogs) {
print(message);
    }
  }

  static void imageLog(String message) {
    if (enableDebugPrints && enableImageLogs) {
print(message);
    }
  }

  static void supabaseLog(String message) {
    if (enableDebugPrints && enableSupabaseLogs) {
print(message);
    }
  }

  static void backgroundServiceLog(String message) {
    if (enableDebugPrints && enableBackgroundServiceLogs) {
print(message);
    }
  }
}