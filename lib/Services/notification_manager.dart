import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';

/// Premium Notification Manager - Prevents ALL duplicate notifications
/// MASTER COORDINATOR: Only this class should show notifications
class NotificationManager {
  static NotificationManager? _instance;
  static NotificationManager get instance => _instance ??= NotificationManager._();

  NotificationManager._();

  // GLOBAL notification deduplication across ALL systems
  static final Map<String, DateTime> _globalNotificationHistory = {};
  static final Map<String, Timer> _globalCleanupTimers = {};

  // Local instance variables
  final Map<String, int> _chatNotificationIds = {};

  // Notification suppression when chat is active
  String? _activeChatId;
  bool _isInChatScreen = false;

  // Local notifications instance
  late FlutterLocalNotificationsPlugin _localNotifications;

  // Constants
  static const Duration _deduplicationWindow = Duration(minutes: 2); // Increased from 30s
  static const int _maxNotificationsPerChat = 5; // Prevent notification spam

  /// Initialize notification manager
  Future<void> initialize() async {
    _localNotifications = FlutterLocalNotificationsPlugin();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

  }

  /// Show notification with advanced deduplication
  Future<void> showChatNotification({
    required String chatId,
    required String senderId,
    required String senderName,
    required String message,
    required String messageType,
    String? clickAction,
  }) async {
    try {
      // 0. CRITICAL: Don't send notifications for your own messages
      try {
        final authCont = Get.find<AuthController>();
        if (authCont.user?.userId != null &&
            authCont.user!.userId.toString() == senderId) {
          return; // Don't notify yourself
        }
      } catch (e) {
        // AuthController not found, continue with notification
      }

      // 1. Check if chat is currently active
      if (_isInChatScreen && _activeChatId == chatId) {
        return;
      }

      // 2. Advanced deduplication
      if (!_shouldShowNotification(chatId, senderId, message, messageType)) {
        return;
      }

      // 3. Rate limiting per chat
      if (_isRateLimited(chatId)) {
        return;
      }

      // 4. Format message
      final formattedMessage = _formatMessage(message, messageType);

      // 5. Show notification
      await _showLocalNotification(
        chatId: chatId,
        title: senderName,
        body: formattedMessage,
        clickAction: clickAction ?? 'myapp://chat/$chatId',
      );

      // 6. Record notification
      _recordNotification(chatId, senderId, message, messageType);


    } catch (e) {
    }
  }

  /// GLOBAL deduplication logic across ALL notification systems
  static bool shouldShowNotificationGlobally(String chatId, String senderId, String message, String messageType) {
    // Create unique key for this specific notification
    final contentHash = '${message}_${messageType}'.hashCode;
    final key = '${chatId}_${senderId}_$contentHash';

    // Check if ANY system has shown this notification recently
    final now = DateTime.now();
    final lastShown = _globalNotificationHistory[key];

    if (lastShown != null) {
      final timeDiff = now.difference(lastShown);
      if (timeDiff < _deduplicationWindow) {
        return false; // Too recent, suppress
      }
    }

    // Record that we're about to show this notification
    _globalNotificationHistory[key] = now;

    // Schedule cleanup
    _globalCleanupTimers[key]?.cancel();
    _globalCleanupTimers[key] = Timer(_deduplicationWindow, () {
      _globalNotificationHistory.remove(key);
      _globalCleanupTimers.remove(key);
    });

    return true;
  }

  /// Instance method for backwards compatibility
  bool _shouldShowNotification(String chatId, String senderId, String message, String messageType) {
    return shouldShowNotificationGlobally(chatId, senderId, message, messageType);
  }

  /// Check if chat is being rate limited
  bool _isRateLimited(String chatId) {
    final now = DateTime.now();
    final recentCount = _globalNotificationHistory.entries
        .where((entry) =>
            entry.key.startsWith('${chatId}_') &&
            now.difference(entry.value).inMinutes < 5)
        .length;

    return recentCount >= _maxNotificationsPerChat;
  }

  /// Record notification in history (already done in shouldShowNotificationGlobally)
  void _recordNotification(String chatId, String senderId, String message, String messageType) {
    // No need to record again - already done in shouldShowNotificationGlobally
  }

  /// Show the actual local notification
  Future<void> _showLocalNotification({
    required String chatId,
    required String title,
    required String body,
    required String clickAction,
  }) async {
    final notificationId = _getNotificationId(chatId);

    const androidDetails = AndroidNotificationDetails(
      'venta_cuba_chat_messages', // DIFFERENT channel from sticky notification
      'Chat Messages',
      channelDescription: 'Temporary chat message notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      enableLights: true,
      ledColor: Color.fromARGB(255, 255, 0, 0), // Red LED color
      ledOnMs: 300,
      ledOffMs: 700,
      // Make it dismissible (not sticky)
      autoCancel: true,
      ongoing: false,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.active,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final payload = json.encode({
      'action': clickAction,
      'chatId': chatId,
      'type': 'chat',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    await _localNotifications.show(
      notificationId,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Get consistent notification ID per chat
  int _getNotificationId(String chatId) {
    if (!_chatNotificationIds.containsKey(chatId)) {
      _chatNotificationIds[chatId] = chatId.hashCode.abs() % 2147483647;
    }
    return _chatNotificationIds[chatId]!;
  }

  /// Format message based on type
  String _formatMessage(String message, String messageType) {
    switch (messageType.toLowerCase()) {
      case 'image':
        return '📷 Photo';
      case 'video':
        return '📹 Video';
      case 'file':
        return '📎 File';
      case 'audio':
        return '🎵 Audio message';
      default:
        // Truncate long messages
        if (message.length > 80) {
          return '${message.substring(0, 77)}...';
        }
        return message;
    }
  }

  /// Set active chat (suppress notifications for this chat)
  void setActiveChatId(String? chatId) {
    _activeChatId = chatId;
    _isInChatScreen = chatId != null;

    if (chatId != null) {
      // Cancel existing notifications for this chat
      cancelChatNotifications(chatId);
    }

  }

  /// Cancel notifications for specific chat
  Future<void> cancelChatNotifications(String chatId) async {
    try {
      final notificationId = _getNotificationId(chatId);
      await _localNotifications.cancel(notificationId);

      // Clear history for this chat
      _globalNotificationHistory.removeWhere((key, _) => key.startsWith('${chatId}_'));

    } catch (e) {
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
      _globalNotificationHistory.clear();

      for (final timer in _globalCleanupTimers.values) {
        timer.cancel();
      }
      _globalCleanupTimers.clear();

    } catch (e) {
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final payload = json.decode(response.payload!);
        final action = payload['action']?.toString();
        final chatId = payload['chatId']?.toString();

        if (action != null && chatId != null) {
          // This should trigger navigation in your app
        }
      } catch (e) {
      }
    }
  }

  /// Get notification statistics
  Map<String, dynamic> getStats() {
    final now = DateTime.now();
    final recentCount = _globalNotificationHistory.values
        .where((time) => now.difference(time).inMinutes < 60)
        .length;

    return {
      'totalTracked': _globalNotificationHistory.length,
      'recentHour': recentCount,
      'activeChats': _chatNotificationIds.length,
      'activeChatId': _activeChatId,
      'isInChatScreen': _isInChatScreen,
    };
  }

  /// Cleanup resources
  void dispose() {
    for (final timer in _globalCleanupTimers.values) {
      timer.cancel();
    }
    _globalCleanupTimers.clear();
    _globalNotificationHistory.clear();
    _chatNotificationIds.clear();

  }
}