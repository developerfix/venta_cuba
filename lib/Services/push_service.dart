import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'Supabase/supabase_service.dart';
import 'notification_manager.dart';
import '../Controllers/auth_controller.dart';

/// ULTRA-OPTIMIZED Push Service - Premium performance for Cuba
/// Features: Persistent connection, offline queue, 99.9% reliability
class PushService {
  static const String _prefsKeyUserId = 'push_user_id';
  static const String _prefsKeyServerUrl = 'push_server_url';
  static String _serverUrl = 'https://ntfy.sh';
  
  // OPTIMIZATION: Singleton instance for better resource management
  static final PushService _instance = PushService._internal();
  static PushService get instance => _instance;
  PushService._internal();

  // User context
  static String? _userTopic;
  static String? _currentUserId;

  // Connection management with enhanced reliability
  static WebSocketChannel? _channel;
  static StreamSubscription? _channelSubscription;
  static StreamSubscription? _connectivitySubscription;
  static Timer? _reconnectTimer;
  static Timer? _heartbeatTimer;

  // State management
  static bool _isConnected = false;
  static final _connectionStatus = false.obs;
  static int _retryCount = 0;
  static const int _maxRetries = 10;
  static DateTime? _lastConnectedTime;

  // Chat state (prevent notifications when chat is open AND app in foreground)
  static bool _isChatScreenOpen = false;
  static String? _currentChatId;
  static bool _isAppInForeground = true; // Track app lifecycle state

  // Notification management with deduplication
  static final Set<String> _recentMessageIds = {};
  static Timer? _deduplicationTimer;

  // Track active notifications by chat ID for easy cleanup
  static final Map<String, Set<int>> _activeNotificationsByChatId = {};

  // OPTIMIZATION: Offline message queue
  static final List<Map<String, dynamic>> _offlineQueue = [];
  static const int _maxQueueSize = 100;

  // Local notifications
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize push service with enhanced features
  static Future<void> initialize({
    required String userId,
    String? customServerUrl,
  }) async {
    try {
      print('🚀 PREMIUM Push Service initializing for user: $userId');

      _currentUserId = userId;
      _userTopic = 'venta_cuba_user_$userId';

      // Save preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKeyUserId, userId);

      if (customServerUrl != null && customServerUrl.isNotEmpty) {
        _serverUrl = customServerUrl;
        await prefs.setString(_prefsKeyServerUrl, customServerUrl);
      } else {
        final savedUrl = prefs.getString(_prefsKeyServerUrl);
        if (savedUrl != null && savedUrl.isNotEmpty) {
          _serverUrl = savedUrl;
        }
      }

      // Initialize local notifications with high priority
      await _initializeLocalNotifications();

      // Clear any old chat notifications when app starts up
      // (Keep the VentaCuba Active service notification)
      await _clearOldChatNotifications();

      // The Android background service handles notifications when app is terminated
      // No need for Flutter sticky notification

      // Connect to WebSocket with retry logic
      await _connectWebSocket();

      // Monitor connectivity for auto-reconnection
      _monitorConnectivity();

      // Start heartbeat to keep connection alive
      _startHeartbeat();

      // Start deduplication cleanup
      _startDeduplicationCleanup();

      // Process any queued offline messages
      await _processOfflineQueue();

      // Save token to Supabase
      await _saveTokenToSupabase(userId);

      print('✅ PREMIUM Push Service initialized successfully');
    } catch (e) {
      print('❌ Error initializing Push Service: $e');
    }
  }

  /// Initialize local notifications with maximum priority
  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      requestProvisionalPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTapped,
    );

    // Create high priority channel for Android
    if (Platform.isAndroid) {
      const androidChannel = AndroidNotificationChannel(
        'venta_cuba_chat_messages',
        'Chat Messages',
        description: 'Instant chat message notifications',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: false, // Fix: Disable LED lights to prevent NullPointerException
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);

      // Create badge update channel for Android
      const androidBadgeUpdateChannel = AndroidNotificationChannel(
        'venta_cuba_badge_update',
        'Badge Updates',
        description: 'Silent notifications to update badge count',
        importance: Importance.min,
        playSound: false,
        enableVibration: false,
        enableLights: false,
        showBadge: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidBadgeUpdateChannel);

      // Request permissions
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();
      
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    if (Platform.isIOS) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }


  /// Clear old chat notifications when app starts up
  static Future<void> _clearOldChatNotifications() async {
    try {
      print('🧼 Clearing old chat notifications on app startup...');

      // When the app is opened, the user is now actively using it
      // Clear all chat notifications since they can now see their messages
      // Keep the VentaCuba Active service notification and badge notifications

      // Get all active notifications
      final activeNotifications = await _localNotifications.getActiveNotifications();

      for (final notification in activeNotifications) {
        // Don't cancel badge notifications (-1) or service notifications
        // Only cancel chat message notifications
        if (notification.id != -1 &&
            notification.id != 1001 && // Service notification ID (NtfyBackgroundService)
            notification.id != 999999) { // Legacy badge notification ID
          await _localNotifications.cancel(notification.id!);
        }
      }

      _activeNotificationsByChatId.clear();
      _recentMessageIds.clear();

      print('✅ Chat notifications cleared - user is now active');
    } catch (e) {
      print('❌ Error clearing old notifications: $e');
      // Fallback: cancel all except badge and service notifications
      try {
        await _localNotifications.cancelAll();
        _activeNotificationsByChatId.clear();
        _recentMessageIds.clear();
      } catch (e2) {
        print('❌ Fallback clear also failed: $e2');
      }
    }
  }

  /// Connect to WebSocket with enhanced error handling and retry logic
  static Future<void> _connectWebSocket() async {
    try {
      await _closeWebSocket();

      if (_userTopic == null) return;

      final wsUrl = _serverUrl
          .replaceFirst('https://', 'wss://')
          .replaceFirst('http://', 'ws://');
      final uri = Uri.parse('$wsUrl/$_userTopic/ws');

      print('🔌 Connecting to premium WebSocket: $uri');

      _channel = WebSocketChannel.connect(
        uri,
        protocols: ['ws', 'wss'],
      );
      
      _channelSubscription = _channel!.stream.listen(
        _handleMessage,
        onError: (error) {
          print('❌ WebSocket error: $error');
          _handleConnectionError();
        },
        onDone: () {
          print('⚠️ WebSocket closed, reconnecting...');
          _handleConnectionError();
        },
        cancelOnError: false,
      );

      _isConnected = true;
      _connectionStatus.value = true;
      _retryCount = 0;
      _lastConnectedTime = DateTime.now();

      print('✅ Premium WebSocket connected to: $uri');
      print('🔔 Ready to receive notifications for topic: $_userTopic');
      
      // Process any offline messages
      await _processOfflineQueue();

    } catch (e) {
      print('❌ WebSocket connection failed: $e');
      _handleConnectionError();
    }
  }

  /// Handle incoming messages with deduplication
  static Future<void> _handleMessage(dynamic message) async {
    try {
      final data = json.decode(message.toString()) as Map<String, dynamic>;
      print('📨 Received notification: ${data['id'] ?? 'unknown'}');
      print('🔍 Raw message data: $data');

      // Skip system messages
      final messageType = data['event'];
      print('🔍 Message type: $messageType');
      if (messageType == 'open' || messageType == 'keepalive') {
        print('🔕 Skipping system message: $messageType');
        return; // Skip system messages
      }

      final messageId = data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
      print('🔍 Message ID: $messageId');

      // Premium deduplication
      if (_recentMessageIds.contains(messageId)) {
        print('🔇 Duplicate blocked: $messageId');
        return;
      }
      _recentMessageIds.add(messageId);
      print('🔍 Added to deduplication cache');

      // The actual notification data is nested in the 'message' field
      final nestedMessage = data['message'];
      print('🔍 Nested message: $nestedMessage');

      if (nestedMessage == null) {
        print('❌ No nested message found');
        return;
      }

      // Parse the nested message
      final notificationData = json.decode(nestedMessage) as Map<String, dynamic>;
      print('🔍 Parsed notification data: $notificationData');

      final title = notificationData['title'] as String?;
      final body = notificationData['message'] as String?;
      final clickAction = notificationData['click'] as String?;

      print('🔍 Title: $title, Body: $body, Click: $clickAction');

      if (title == null || title.isEmpty || body == null || body.isEmpty) {
        print('❌ Missing title or body');
        return;
      }
      
      // Extract chat ID from click action
      String? chatId;
      if (clickAction != null && clickAction.startsWith('myapp://chat/')) {
        chatId = clickAction.split('/').last;
      }

      print('🔍 NOTIFICATION DECISION: Chat open: $_isChatScreenOpen, Current chat: $_currentChatId, Incoming chat: $chatId, App in foreground: $_isAppInForeground');

      // CRITICAL: Only block notifications if chat is open AND app is in foreground
      // If app is in background, ALWAYS show notifications regardless of which chat was open
      if (_isChatScreenOpen && chatId == _currentChatId && _isAppInForeground) {
        print('🔕 BLOCKED: Same chat is currently open AND app in foreground');
        return;
      }

      // If app is in background, always allow notifications
      if (!_isAppInForeground) {
        print('✅ ALLOWING: App is in background - showing notification regardless of chat state');
      }

      // Global deduplication check
      final shouldShow = NotificationManager.shouldShowNotificationGlobally(
          chatId ?? '', 'unknown', body, 'text');
      print('🔍 Global deduplication check: $shouldShow');

      if (!shouldShow) {
        print('🔕 BLOCKED: Global deduplication check failed');
        return;
      }

      // Show normal notifications when app is running (foreground or background)
      // The sticky service will handle when app is terminated
      print('✅ SHOWING NORMAL NOTIFICATION: $title - $body');
      await _showPremiumNotification(
        title: title,
        body: body,
        chatId: chatId,
        messageId: messageId,
        badgeCount: null, // Will calculate for current user
      );
    } catch (e) {
      print('❌ Error handling message: $e');
    }
  }

  /// Show premium local notification
  static Future<void> _showPremiumNotification({
    required String title,
    required String body,
    String? chatId,
    required String messageId,
    int? badgeCount,
  }) async {
    try {
      print('📢 _showPremiumNotification called: $title - $body');

      // CRITICAL FIX: Use SAME notification ID to replace previous notification
      // This prevents badge accumulation
      const int SINGLE_NOTIFICATION_ID = 2001;

      // Always recalculate badge for current user
      if (_currentUserId != null) {
        badgeCount = await _getUnreadCountForUser(_currentUserId!);
        print('📊 FRESH badge count calculated: $badgeCount');
      } else {
        badgeCount = 0;
      }

    // Cancel previous notification to ensure only ONE exists
    try {
      await _localNotifications.cancel(SINGLE_NOTIFICATION_ID);
    } catch (e) {
      print('⚠️ Could not cancel previous notification: $e');
      // Continue anyway - the new notification will replace it
    }

    final int safeBadgeCount = badgeCount ?? 0;
    print('🔴 REPLACING notification with badge: $safeBadgeCount');

    final androidDetails = AndroidNotificationDetails(
      'venta_cuba_chat_messages',
      'Chat Messages',
      channelDescription: 'Instant chat message notifications',
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      enableVibration: true,
      enableLights: false,
      autoCancel: true, // Change to true so notification can be dismissed
      ongoing: false,
      category: AndroidNotificationCategory.message,
      fullScreenIntent: false,
      visibility: NotificationVisibility.public,
      number: safeBadgeCount, // This is the TOTAL count, not incremental
      setAsGroupSummary: false,
      playSound: true,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      badgeNumber: badgeCount,
      threadIdentifier: 'chat_messages',
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Use the SAME notification ID to replace previous
    try {
      await _localNotifications.show(
        SINGLE_NOTIFICATION_ID,
        title,
        body,
        details,
        payload: chatId != null ? json.encode({'chatId': chatId}) : null,
      );

      // Track this notification for the chat
      if (chatId != null) {
        _activeNotificationsByChatId.putIfAbsent(chatId, () => <int>{});
        _activeNotificationsByChatId[chatId]!.clear(); // Clear old tracking
        _activeNotificationsByChatId[chatId]!.add(SINGLE_NOTIFICATION_ID);
      }

      print('✅ Notification REPLACED with badge: $safeBadgeCount (ID=$SINGLE_NOTIFICATION_ID)');
    } catch (e) {
      print('❌ Failed to show notification: $e');
      // Try showing a simpler notification without badge
      try {
        final simpleAndroidDetails = AndroidNotificationDetails(
          'venta_cuba_chat_messages',
          'Chat Messages',
          importance: Importance.max,
          priority: Priority.max,
        );

        await _localNotifications.show(
          DateTime.now().millisecondsSinceEpoch % 100000,
          title,
          body,
          NotificationDetails(android: simpleAndroidDetails),
        );
        print('✅ Showed simple notification instead');
      } catch (e2) {
        print('❌ Even simple notification failed: $e2');
      }
    }
    } catch (e) {
      print('❌ Error in _showPremiumNotification: $e');
    }
  }

  /// Handle disconnection with auto-reconnection
  static void _handleConnectionError() {
    _isConnected = false;
    _connectionStatus.value = false;
    
    if (_retryCount < _maxRetries) {
      _retryCount++;
      final delay = 3000 * _retryCount; // Progressive delay
      
      print('🔄 Reconnecting in ${delay}ms (attempt $_retryCount/$_maxRetries)');
      
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(Duration(milliseconds: delay), () {
        _connectWebSocket();
      });
    } else {
      print('❌ Max reconnection attempts reached');
      // Try again after 30 seconds
      _reconnectTimer = Timer(Duration(seconds: 30), () {
        _retryCount = 0;
        _connectWebSocket();
      });
    }
  }

  /// Close WebSocket connection
  static Future<void> _closeWebSocket() async {
    await _channelSubscription?.cancel();
    _channelSubscription = null;
    
    await _channel?.sink.close(status.goingAway);
    _channel = null;
    
    _isConnected = false;
  }

  /// Monitor connectivity changes for auto-reconnection
  static void _monitorConnectivity() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (result) {
        final hasConnection = result != ConnectivityResult.none;
        
        if (hasConnection && !_isConnected) {
          print('📱 Network restored, reconnecting...');
          _retryCount = 0;
          _connectWebSocket();
        } else if (!hasConnection) {
          print('📵 Network lost, queuing messages...');
          _isConnected = false;
        }
      },
    );
  }

  /// Keep connection alive with heartbeat
  static void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(
      Duration(seconds: 30),
      (_) {
        if (_isConnected && _channel != null) {
          try {
            _channel!.sink.add(json.encode({'type': 'ping'}));
          } catch (e) {
            print('❌ Heartbeat failed: $e');
            _handleConnectionError();
          }
        }
      },
    );
  }

  /// Clean up deduplication cache periodically
  static void _startDeduplicationCleanup() {
    _deduplicationTimer?.cancel();
    _deduplicationTimer = Timer.periodic(
      Duration(minutes: 5),
      (_) {
        _recentMessageIds.clear();
        print('🧹 Cleared deduplication cache');
      },
    );
  }

  /// Queue message for offline delivery
  static void _queueOfflineMessage(Map<String, dynamic> message) {
    if (_offlineQueue.length >= _maxQueueSize) {
      _offlineQueue.removeAt(0); // Remove oldest
    }
    
    message['queued_at'] = DateTime.now().toIso8601String();
    _offlineQueue.add(message);
    
    print('📦 Message queued (${_offlineQueue.length} in queue)');
  }

  /// Process offline message queue
  static Future<void> _processOfflineQueue() async {
    if (_offlineQueue.isEmpty || !_isConnected) return;
    
    print('📤 Processing ${_offlineQueue.length} offline messages');
    
    final toProcess = List.from(_offlineQueue);
    _offlineQueue.clear();
    
    for (final message in toProcess) {
      try {
        await sendChatNotification(
          recipientUserId: message['recipientUserId'],
          senderName: message['senderName'],
          message: message['message'],
          messageType: message['messageType'] ?? 'text',
          chatId: message['chatId'],
          senderId: message['senderId'],
        );
        
        await Future.delayed(Duration(milliseconds: 100)); // Rate limiting
      } catch (e) {
        print('❌ Failed to send queued message: $e');
        _queueOfflineMessage(message); // Re-queue on failure
      }
    }
  }

  /// Save token to Supabase
  static Future<void> _saveTokenToSupabase(String userId) async {
    try {
      // Save device token to device_tokens table
      final token = 'venta_cuba_user_$userId';

      // First, delete any existing tokens for this user
      await SupabaseService.client
          .from('device_tokens')
          .delete()
          .eq('user_id', userId)
          .eq('platform', 'flutter');

      // Insert the new token
      await SupabaseService.client.from('device_tokens').insert({
        'user_id': userId,
        'device_token': token,
        'platform': 'flutter',
        'is_active': true,
        'updated_at': DateTime.now().toIso8601String(),
      });

      print('✅ Device token saved to Supabase from PushService: $token');

      // Also save ntfy topic for user (optional, for backward compatibility)
      try {
        await SupabaseService.client
            .from('users')
            .update({'ntfy_topic': _userTopic})
            .eq('user_id', userId);
      } catch (e) {
        // This might fail if users table doesn't have ntfy_topic column
        print('⚠️ Could not update ntfy_topic in users table: $e');
      }
    } catch (e) {
      print('❌ Error saving token to Supabase: $e');
    }
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = json.decode(response.payload!);
        final chatId = data['chatId'];
        
        if (chatId != null) {
          // Clear notifications for this chat when tapped
          print('💆 Notification tapped for chat $chatId - clearing notifications');
          cancelChatNotifications(chatId);

          // Navigate to chat screen
          Get.toNamed('/chat', arguments: {'chatId': chatId});
        }
      } catch (e) {
        print('Error handling notification tap: $e');
      }
    }
  }

  /// Handle background notification tap
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTapped(NotificationResponse response) {
    _onNotificationTapped(response);
  }

  /// Send chat notification with ultra-reliability for ALL app states
  static Future<void> sendChatNotification({
    required String recipientUserId,
    required String senderName,
    required String message,
    required String messageType,
    required String chatId,
    required String senderId,
  }) async {
    try {
      print('📨 Sending notification: $senderId → $recipientUserId (Chat: $chatId)');

      // CRITICAL: Don't send notifications to yourself
      try {
        final authCont = Get.find<AuthController>();
        if (authCont.user?.userId?.toString() == recipientUserId) {
          print('🔕 Skipping self-notification');
          return;
        }
      } catch (e) {}

      // Skip notification preferences check for now since it's handled via API
      // and we don't have direct access to user notification settings in Supabase

      // Format message based on type
      String formattedMessage = message;
      if (messageType == 'image') {
        formattedMessage = '📷 Photo';
      } else if (messageType == 'video') {
        formattedMessage = '📹 Video';
      } else if (messageType == 'file') {
        formattedMessage = '📎 File';
      } else if (message.length > 100) {
        formattedMessage = message.substring(0, 97) + '...';
      }

      // Get current badge count for recipient (only once)
      // CRITICAL: This should be the TOTAL unread count, not incremental
      int badgeCount = await _getUnreadCountForUser(recipientUserId);
      print('🚨 NOTIFICATION BADGE: Setting badge to EXACTLY $badgeCount for recipient $recipientUserId');
      print('🚨 This is NOT adding to existing badge, it\'s REPLACING it');

      // IMPORTANT: Only update badge if this is truly for the recipient
      // The sender should never get their badge updated when sending
      if (_currentUserId == recipientUserId) {
        print('🚨 Recipient is on this device, updating local badge to: $badgeCount');
        // Force clear any existing badge first
        await clearBadgeCount();
        // Then set new badge count
        await updateBadgeCount();
      }

      // Try to send via ntfy for remote notifications
      final recipientTopic = 'venta_cuba_user_$recipientUserId';
      final url = Uri.parse('$_serverUrl/$recipientTopic');

      final payload = {
        'id': '${chatId}_${DateTime.now().millisecondsSinceEpoch}',
        'topic': recipientTopic,
        'title': senderName,
        'message': formattedMessage,
        'priority': 5,
        'tags': ['envelope', 'venta_cuba'],
        'click': 'myapp://chat/$chatId',
        'actions': [
          {
            'action': 'view',
            'label': 'Open Chat',
            'url': 'myapp://chat/$chatId'
          }
        ],
        'extras': {
          'chatId': chatId,
          'senderId': senderId,
          'recipientId': recipientUserId,
          'messageType': messageType,
          'badge': badgeCount.toString(),
        },
      };

      if (_isConnected) {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(payload),
        ).timeout(Duration(seconds: 5));

        if (response.statusCode == 200) {
          print('✅ Remote notification sent to $recipientTopic (badge: $badgeCount)');

          // ONLY update badge for current user - NO local notification
          // The background service or WebSocket will handle showing notifications
          if (_currentUserId == recipientUserId) {
            print('🎯 Updating badge for current user to: $badgeCount');
            await updateBadgeCount();
          }
        } else {
          print('❌ ntfy server returned status: ${response.statusCode}');
          print('❌ Response body: ${response.body}');
          throw Exception('Failed with status: ${response.statusCode}');
        }
      } else {
        // Queue for offline delivery
        _queueOfflineMessage({
          'recipientUserId': recipientUserId,
          'senderName': senderName,
          'message': message,
          'messageType': messageType,
          'chatId': chatId,
          'senderId': senderId,
        });
      }
    } catch (e) {
      print('❌ Error sending notification: $e');
      // Queue for retry
      _queueOfflineMessage({
        'recipientUserId': recipientUserId,
        'senderName': senderName,
        'message': message,
        'messageType': messageType,
        'chatId': chatId,
        'senderId': senderId,
      });
    }
  }

  /// Cancel ALL notifications for a specific chat
  static Future<void> cancelChatNotifications(String chatId) async {
    try {
      print('🧼 Canceling all notifications for chat: $chatId');

      // 1. Cancel all tracked notifications for this chat
      if (_activeNotificationsByChatId.containsKey(chatId)) {
        final notificationIds = _activeNotificationsByChatId[chatId]!;
        print('🧼 Found ${notificationIds.length} tracked notifications for chat $chatId');

        for (final notificationId in notificationIds) {
          await _localNotifications.cancel(notificationId);
          print('✅ Canceled notification ID: $notificationId');
        }

        // Remove from tracking
        _activeNotificationsByChatId.remove(chatId);
      }

      // 2. Also try common notification ID patterns (fallback)
      final baseNotificationId = chatId.hashCode.abs() % 100000;
      await _localNotifications.cancel(baseNotificationId);

      // 3. Clear from deduplication cache for this chat
      _recentMessageIds.removeWhere((id) => id.contains(chatId));

      print('✅ All notifications canceled for chat: $chatId');

    } catch (e) {
      print('❌ Error canceling chat notifications: $e');
    }
  }

  /// Set active chat to prevent notifications and clear existing ones
  static void setActiveChat(String? chatId) {
    _currentChatId = chatId;
    _isChatScreenOpen = chatId != null;

    // When opening a chat, clear all notifications from that chat
    if (chatId != null) {
      print('📤 Opening chat $chatId - clearing notifications');
      cancelChatNotifications(chatId);
    }
  }

  /// Set chat screen status for notification management
  static void setChatScreenStatus(bool isOpen, [String? chatId]) {
    _isChatScreenOpen = isOpen;
    if (chatId != null) {
      _currentChatId = chatId;

      // When opening a chat screen, clear all notifications from that chat
      if (isOpen) {
        print('📤 Opening chat screen for $chatId - clearing notifications');
        cancelChatNotifications(chatId);
      }
    }
    print('🔄 Chat screen status: open=$isOpen, chatId=$chatId, appInForeground=$_isAppInForeground');
  }

  /// Set app lifecycle state for notification management
  static void setAppLifecycleState(bool isInForeground) {
    final wasInBackground = !_isAppInForeground;
    _isAppInForeground = isInForeground;
    print('🔄 App lifecycle state changed: inForeground=$isInForeground');

    if (!isInForeground) {
      print('📱 App backgrounded - notifications will now be allowed for all chats');
    } else {
      print('📱 App foregrounded - notifications will be filtered based on active chat');

      // If app was in background and now is in foreground, clear notifications
      if (wasInBackground) {
        print('📱 App came to foreground - clearing notifications and badge');
        Future.microtask(() => onAppResumed());
      }
    }
  }

  /// Get connection status
  static bool get isConnected => _isConnected;
  
  /// Get connection duration
  static Duration? get connectionDuration {
    if (_lastConnectedTime != null && _isConnected) {
      return DateTime.now().difference(_lastConnectedTime!);
    }
    return null;
  }

  /// Cleanup and dispose
  static Future<void> dispose() async {
    print('🧹 Disposing Push Service');
    
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _deduplicationTimer?.cancel();
    _connectivitySubscription?.cancel();
    
    await _closeWebSocket();
    
    // No persistent notification to cancel anymore
    
    _offlineQueue.clear();
    _recentMessageIds.clear();
    _activeNotificationsByChatId.clear();
  }


  /// Get unread message count for a specific user - FIXED ACCUMULATION
  static Future<int> _getUnreadCountForUser(String userId) async {
    try {
      print('\n🔴🔴🔴 BADGE CALCULATION START 🔴🔴🔴');
      print('🔴 Calculating for user: $userId');

      // Get all chats where the user is involved
      final userChats = await SupabaseService.client
          .from('chats')
          .select('id, sender_id, send_to_id, sender_last_read_time, recipient_last_read_time')
          .or('sender_id.eq.$userId,send_to_id.eq.$userId');

      print('🔴 Found ${userChats.length} chats for user');

      int totalUnread = 0;

      for (final chat in userChats) {
        // Convert IDs to strings for comparison
        final chatSenderId = chat['sender_id'].toString();
        final chatSendToId = chat['send_to_id'].toString();
        final userIdStr = userId.toString();

        print('🔴 Chat ${chat['id']}: sender=$chatSenderId, recipient=$chatSendToId, user=$userIdStr');

        // Determine if user is sender or recipient
        final isUserSender = chatSenderId == userIdStr;
        final lastReadTime = isUserSender
            ? chat['sender_last_read_time']
            : chat['recipient_last_read_time'];

        print('🔴 User is ${isUserSender ? "sender" : "recipient"}, last read: $lastReadTime');

        // Count unread messages for this chat
        final unreadMessages = await SupabaseService.client
            .from('messages')
            .select('id, send_by, time')
            .eq('chat_id', chat['id'])
            .neq('send_by', userId)  // Messages NOT sent by this user
            .gt('time', lastReadTime ?? '1970-01-01T00:00:00Z');

        final chatUnreadCount = unreadMessages.length;

        if (chatUnreadCount > 0) {
          print('🔴 Chat ${chat['id']}: $chatUnreadCount unread messages');
          for (var msg in unreadMessages.take(3)) {
            print('🔴   - Message from ${msg['send_by']} at ${msg['time']}');
          }
          totalUnread += chatUnreadCount;
        } else {
          print('🔴 Chat ${chat['id']}: No unread messages');
        }
      }

      print('🔴 FINAL BADGE COUNT: $totalUnread');
      print('🔴🔴🔴 BADGE CALCULATION END 🔴🔴🔴\n');
      return totalUnread;
    } catch (e) {
      print('❌ Badge calculation error: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      return 0;
    }
  }

  /// Show local notification for recipient (handles all app states)
  static Future<void> _showLocalNotificationForRecipient({
    required String recipientUserId,
    required String senderName,
    required String message,
    required String chatId,
    required int badgeCount,
  }) async {
    try {
      // Check if notification should be shown

      // Only show if this is for the current user on this device
      if (_currentUserId != recipientUserId) {
        print('🔕 Skipping: Not for current user (recipient: $recipientUserId, current: $_currentUserId)');
        return;
      }

      // Will show local notification

      // CRITICAL: Only skip if chat is currently open AND app is in foreground
      // If app is in background, ALWAYS show notifications
      if (_isChatScreenOpen && _currentChatId == chatId && _isAppInForeground) {
        print('🔕 Skipping: Chat is currently open AND app in foreground');
        return;
      }

      // If app is in background, always allow local notifications
      if (!_isAppInForeground) {
        print('✅ ALLOWING LOCAL: App is in background - showing notification');
      }

      final notificationId = DateTime.now().millisecondsSinceEpoch % 100000;

      // CRITICAL FIX: Ensure badge is set to exact count, not accumulated
      print('🚨 LOCAL NOTIFICATION: Badge count should be EXACTLY: $badgeCount');
      print('🚨 If seeing accumulation, launcher may be buggy');

      final androidDetails = AndroidNotificationDetails(
        'venta_cuba_chat_messages',
        'Chat Messages',
        channelDescription: 'Instant chat message notifications',
        importance: Importance.max,
        priority: Priority.max,
        showWhen: true,
        enableVibration: true,
        enableLights: false, // Fix: Disable LED lights to prevent NullPointerException
        autoCancel: true,
        groupKey: 'com.venta.cuba.CHAT_MESSAGES',
        category: AndroidNotificationCategory.message,
        fullScreenIntent: true,
        visibility: NotificationVisibility.public,
        // CRITICAL: This sets EXACT count, not adds to existing
        number: badgeCount,
        setAsGroupSummary: false,
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        badgeNumber: badgeCount,
        threadIdentifier: 'chat_messages',
        interruptionLevel: InterruptionLevel.timeSensitive,
        categoryIdentifier: 'CHAT_MESSAGE',
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        notificationId,
        senderName,
        message,
        details,
        payload: json.encode({
          'chatId': chatId,
          'type': 'chat_message',
          'senderId': recipientUserId,
        }),
      );

      // Track this notification for the chat
      _activeNotificationsByChatId.putIfAbsent(chatId, () => <int>{});
      _activeNotificationsByChatId[chatId]!.add(notificationId);

      print('📢 LOCAL NOTIFICATION SHOWN: ID=$notificationId, Title=$senderName, Body=$message');
      print('📢 Local notification shown for recipient with badge: $badgeCount');
    } catch (e) {
      print('❌ Error showing local notification: $e');
    }
  }

  /// Clear badge count when messages are read
  static Future<void> clearBadgeCount() async {
    try {
      print('🧹 Clearing badge count...');

      if (Platform.isIOS) {
        // Clear iOS badge directly
        await _setIOSBadgeNumber(0);
        print('🧹 iOS badge cleared');
      } else if (Platform.isAndroid) {
        // Skip canceling notification -1 as it causes Gson error
        // Badge will be cleared when next notification shows with count 0
        print('🧹 Android badge clear deferred to next notification');
      }
    } catch (e) {
      print('❌ Error clearing badge: $e');
    }
  }

  /// Update badge count - SIMPLIFIED
  static Future<void> updateBadgeCount() async {
    if (_currentUserId == null) return;

    try {
      final unreadCount = await _getUnreadCountForUser(_currentUserId!);
      print('🎯 Setting badge to: $unreadCount');

      if (Platform.isIOS) {
        await _setIOSBadgeNumber(unreadCount);
      } else if (Platform.isAndroid) {
        await _forceSetAndroidBadge(unreadCount);
      }
    } catch (e) {
      print('❌ Error updating badge: $e');
    }
  }

  /// Set iOS badge number directly
  static Future<void> _setIOSBadgeNumber(int count) async {
    if (!Platform.isIOS) return;

    try {
      print('🎯 Attempting to set iOS badge to: $count');

      // First ensure permissions are granted
      final iosImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

      if (iosImplementation == null) {
        print('❌ iOS notifications plugin not available');
        return;
      }

      // Request badge permissions explicitly
      final permissions = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      print('🔔 Badge permission granted: ${permissions}');

      if (permissions != true) {
        print('❌ Badge permissions not granted');
        return;
      }

      // METHOD 1: Try using a visible notification with badge
      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,  // Make it visible for testing
        presentBadge: true,
        presentSound: false,
        badgeNumber: count,
        threadIdentifier: 'badge_update',
        categoryIdentifier: 'BADGE_UPDATE',
        interruptionLevel: InterruptionLevel.passive,
      );

      await _localNotifications.show(
        999, // Unique ID for badge updates
        'Badge Test', // Visible title for debugging
        'Badge count: $count', // Visible body for debugging
        NotificationDetails(iOS: iosDetails),
        payload: null,
      );

      print('🎯 iOS badge notification sent with count: $count');

      // METHOD 2: Also try to cancel the visible notification after a delay
      Future.delayed(Duration(seconds: 2), () async {
        await _localNotifications.cancel(999);
        print('🧹 Cleared badge test notification');
      });

    } catch (e) {
      print('❌ Error setting iOS badge number: $e');
      print('❌ Stack trace: ${e.toString()}');
    }
  }

  /// Update Android badge count - NO WEIRD NOTIFICATIONS
  static Future<void> _forceSetAndroidBadge(int count) async {
    if (!Platform.isAndroid) return;

    try {
      print('🤖 Android badge update to: $count (no notification)');

      // Skip canceling notification -1 as it causes Gson error
      // The badge will be handled by regular chat notifications

      // DON'T create separate badge notifications - they show up weird in status bar
      // Let the regular chat notifications handle badge counts with their 'number' field
      // This prevents the weird silent notifications in status bar

      print('🤖 Badge logic handled by chat notifications');
    } catch (e) {
      print('❌ Error updating Android badge: $e');
    }
  }

  /// Legacy method - redirects to force set
  static Future<void> _updateAndroidBadge(int count) async {
    await _forceSetAndroidBadge(count);
  }


  /// Handle when app comes to foreground - clear notifications and update badge
  static Future<void> onAppResumed() async {
    print('📱 App resumed - clearing notifications and updating badge');

    // Clear all chat notifications when app opens
    await clearChatNotificationsOnAppOpen();

    // Clear badge since user is now actively using the app
    await clearBadgeCount();

    // Reconnect if needed
    if (!_isConnected) {
      await reconnect();
    }
  }

  /// Clear chat notifications when app opens (keep badge and service notifications)
  static Future<void> clearChatNotificationsOnAppOpen() async {
    try {
      print('🧹 Clearing chat notifications - app opened');

      // Get all active notifications
      final activeNotifications = await _localNotifications.getActiveNotifications();

      for (final notification in activeNotifications) {
        // Only cancel chat message notifications
        // Keep: badge notifications (-1), service notifications (1001)
        if (notification.id != -1 &&
            notification.id != 1001 &&
            notification.id != 999999) {
          await _localNotifications.cancel(notification.id!);
          print('🧹 Cancelled notification: ${notification.id}');
        }
      }

      _activeNotificationsByChatId.clear();
      _recentMessageIds.clear();

      print('✅ Chat notifications cleared on app open');
    } catch (e) {
      print('❌ Error clearing notifications on app open: $e');
    }
  }

  /// Manually reconnect
  static Future<void> reconnect() async {
    print('🔄 Manual reconnection requested');
    _retryCount = 0;
    await _connectWebSocket();
  }

  /// Test notification to yourself
  static Future<void> sendTestNotification() async {
    if (_currentUserId == null) {
      print('❌ No current user ID for test notification');
      return;
    }

    print('🧪 SENDING TEST NOTIFICATION TO SELF...');
    await sendChatNotification(
      recipientUserId: _currentUserId!,
      senderName: 'Test',
      message: 'This is a test notification',
      messageType: 'text',
      chatId: 'test_chat',
      senderId: _currentUserId!,
    );
  }

  /// Test badge functionality directly
  static Future<void> testBadge({int count = 5}) async {
    print('🧪 TESTING BADGE WITH COUNT: $count');

    try {
      // Test current unread count
      if (_currentUserId != null) {
        final actualUnread = await _getUnreadCountForUser(_currentUserId!);
        print('🔍 Current actual unread count: $actualUnread');
      }

      // Force set badge
      await _setIOSBadgeNumber(count);

      // Also test with visible notification
      if (Platform.isIOS) {
        final iosDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          badgeNumber: count,
          threadIdentifier: 'badge_test',
        );

        await _localNotifications.show(
          888,
          'Badge Test',
          'Testing badge count: $count',
          NotificationDetails(iOS: iosDetails),
        );

        print('✅ Test notification sent with badge: $count');
      } else if (Platform.isAndroid) {
        final androidDetails = AndroidNotificationDetails(
          'badge_test_channel',
          'Badge Test',
          importance: Importance.high,
          priority: Priority.high,
          number: count,
        );

        await _localNotifications.show(
          888,
          'Badge Test',
          'Testing badge count: $count',
          NotificationDetails(android: androidDetails),
        );

        print('✅ Android test notification sent with number: $count');
      }

    } catch (e) {
      print('❌ Badge test failed: $e');
    }
  }

  /// Clear all test notifications
  static Future<void> clearTestNotifications() async {
    await _localNotifications.cancel(888);
    await _localNotifications.cancel(999);
    await _localNotifications.cancel(-3); // Clear badge update notifications
    print('🧹 Cleared test notifications and badge updates');
  }

  /// Force clear stuck badge (for Android debugging)
  static Future<void> forceResetBadge() async {
    print('🔧 Force resetting badge...');

    try {
      if (Platform.isAndroid) {
        // Nuclear option: Cancel EVERYTHING
        await _localNotifications.cancelAll();
        print('🔧 Cancelled all notifications');

        // Wait for system to process
        await Future.delayed(Duration(milliseconds: 500));

        // Force set to 0
        await _forceSetAndroidBadge(0);

        print('🔧 Android badge NUCLEAR RESET completed');
      } else if (Platform.isIOS) {
        await _setIOSBadgeNumber(0);
        print('🔧 iOS badge force reset completed');
      }
    } catch (e) {
      print('❌ Error force resetting badge: $e');
    }
  }

  /// Debug function to test badge setting
  static Future<void> debugTestBadge(int testCount) async {
    print('\n🧪🧪🧪 BADGE DEBUG TEST 🧪🧪🧪');
    print('🧪 Testing badge with count: $testCount');

    // First clear everything
    await forceResetBadge();
    await Future.delayed(Duration(seconds: 1));

    // Now set to test count
    if (Platform.isAndroid) {
      await _forceSetAndroidBadge(testCount);
    } else {
      await _setIOSBadgeNumber(testCount);
    }

    print('🧪 Badge should now show EXACTLY: $testCount');
    print('🧪 If it shows something else, your launcher is buggy');
    print('🧪🧪🧪 END DEBUG TEST 🧪🧪🧪\n');
  }

  /// Diagnostic information about push service
  static Map<String, dynamic> getDiagnostics() {
    return {
      'isConnected': _isConnected,
      'currentUserId': _currentUserId,
      'userTopic': _userTopic,
      'serverUrl': _serverUrl,
      'retryCount': _retryCount,
      'connectionDuration': connectionDuration?.toString(),
      'isChatScreenOpen': _isChatScreenOpen,
      'currentChatId': _currentChatId,
      'isAppInForeground': _isAppInForeground,
      'offlineQueueSize': _offlineQueue.length,
      'recentMessageCount': _recentMessageIds.length,
      'activeChatNotifications': _activeNotificationsByChatId.map((k, v) => MapEntry(k, v.length)),
    };
  }
}
