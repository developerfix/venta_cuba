import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Ntfy Push Service - Works in Cuba without Firebase
/// 
/// This service provides push notifications using ntfy.sh, which is a
/// simple HTTP-based pub/sub notification service that works without
/// Google services, making it perfect for Cuba and other restricted regions.
class NtfyPushService {
  static const String _prefsKeyUserId = 'ntfy_user_id';
  static const String _prefsKeyNtfyUrl = 'ntfy_server_url';
  
  // Default to public ntfy server, but can be changed to self-hosted
  static String _ntfyServerUrl = 'https://ntfy.sh';
  
  // User-specific topic for receiving notifications
  static String? _userTopic;
  static String? _currentUserId;
  
  // WebSocket channel for real-time notifications
  static WebSocketChannel? _channel;
  static StreamSubscription? _channelSubscription;
  static StreamSubscription? _connectivitySubscription;
  
  // Flutter local notifications plugin
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  
  // Retry configuration
  static int _retryCount = 0;
  static const int _maxRetries = 5;
  static Timer? _reconnectTimer;
  
  // Connection status
  static bool _isConnected = false;
  static final _connectionStatus = false.obs;
  
  // Chat screen status (to prevent notifications when chat is open)
  static bool _isChatScreenOpen = false;
  static String? _currentChatId;
  
  /// Initialize the ntfy push service with a user ID
  static Future<void> initialize({
    required String userId,
    String? customServerUrl,
  }) async {
    try {
      print('🔔 Initializing ntfy push service for user: $userId');
      
      // Save user ID
      _currentUserId = userId;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKeyUserId, userId);
      
      // Use custom server URL if provided
      if (customServerUrl != null && customServerUrl.isNotEmpty) {
        _ntfyServerUrl = customServerUrl;
        await prefs.setString(_prefsKeyNtfyUrl, customServerUrl);
      } else {
        // Check if we have a saved server URL
        final savedUrl = prefs.getString(_prefsKeyNtfyUrl);
        if (savedUrl != null && savedUrl.isNotEmpty) {
          _ntfyServerUrl = savedUrl;
        }
      }
      
      // Create a unique topic for this user
      // Format: venta_cuba_user_{userId}
      _userTopic = 'venta_cuba_user_$userId';
      
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Start WebSocket connection
      await _connectWebSocket();
      
      // Monitor connectivity changes
      _monitorConnectivity();
      
      print('✅ Ntfy push service initialized successfully');
      print('📍 Server: $_ntfyServerUrl');
      print('📍 User topic: $_userTopic');
    } catch (e) {
      print('❌ Error initializing ntfy push service: $e');
    }
  }
  
  /// Initialize local notifications for displaying push notifications
  static Future<void> _initializeLocalNotifications() async {
    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    // Combined initialization settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    // Initialize the plugin
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Request permissions on iOS
    if (Platform.isIOS) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
    
    // Request permissions on Android 13+
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
    
    print('✅ Local notifications initialized');
  }
  
  /// Connect to ntfy WebSocket for real-time notifications
  static Future<void> _connectWebSocket() async {
    try {
      // Close existing connection if any
      await _closeWebSocket();
      
      if (_userTopic == null) {
        print('❌ Cannot connect WebSocket: No user topic');
        return;
      }
      
      // Convert HTTP URL to WebSocket URL
      final wsUrl = _ntfyServerUrl
          .replaceFirst('https://', 'wss://')
          .replaceFirst('http://', 'ws://');
      
      final uri = Uri.parse('$wsUrl/$_userTopic/ws');
      print('🔌 Connecting to WebSocket: $uri');
      
      // Create WebSocket connection
      _channel = WebSocketChannel.connect(uri);
      
      // Listen for messages
      _channelSubscription = _channel!.stream.listen(
        (message) {
          _handleWebSocketMessage(message);
          _retryCount = 0; // Reset retry count on successful message
        },
        onError: (error) {
          print('❌ WebSocket error: $error');
          _handleConnectionError();
        },
        onDone: () {
          print('⚠️ WebSocket connection closed');
          _handleConnectionError();
        },
      );
      
      _isConnected = true;
      _connectionStatus.value = true;
      print('✅ WebSocket connected successfully');
    } catch (e) {
      print('❌ Error connecting WebSocket: $e');
      _handleConnectionError();
    }
  }
  
  /// Handle incoming WebSocket messages
  static void _handleWebSocketMessage(dynamic message) {
    try {
      print('📨 Received WebSocket message: $message');
      
      // Parse the message
      final Map<String, dynamic> data = json.decode(message.toString());
      
      // Filter out system messages and connection confirmations
      final String? messageType = data['event'];
      if (messageType == 'open' || messageType == 'keepalive') {
        print('🔇 Skipping system message: $messageType');
        return;
      }
      
      // Only process messages that have actual content
      final String? title = data['title'];
      final String? body = data['message'];
      
      // Skip if no title or body (system messages)
      if (title == null || title.isEmpty || body == null || body.isEmpty) {
        print('🔇 Skipping message without content');
        return;
      }
      
      // Skip if this is not a chat message (check for chat ID in click action)
      final String? clickAction = data['click'];
      if (clickAction == null || !clickAction.startsWith('myapp://chat/')) {
        print('🔇 Skipping non-chat message');
        return;
      }
      
      final Map<String, dynamic>? payload = {
        'action': clickAction,
        'type': data['type'] ?? 'chat',
      };
      
      // Check if chat screen is open
      if (_isChatScreenOpen) {
        print('testing 🔇 BLOCKING ALL notifications - chat screen is open');
        return;
      }
      
      // Show local notification only for valid chat messages
      print('testing 🔴 NTFY: Showing notification - title: "$title", body: "$body"');
      _showLocalNotification(
        title: title,
        body: body,
        payload: payload,
      );
    } catch (e) {
      print('❌ Error handling WebSocket message: $e');
    }
  }
  
  /// Handle connection errors with retry logic
  static void _handleConnectionError() {
    _isConnected = false;
    _connectionStatus.value = false;
    
    if (_retryCount < _maxRetries) {
      _retryCount++;
      final delay = Duration(seconds: _retryCount * 2);
      print('🔄 Retrying connection in ${delay.inSeconds} seconds (attempt $_retryCount/$_maxRetries)');
      
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(delay, () {
        _connectWebSocket();
      });
    } else {
      print('❌ Max retries reached. Falling back to polling.');
      _startPolling();
    }
  }
  
  /// Start polling for notifications (fallback when WebSocket fails)
  static void _startPolling() {
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (_isConnected) {
        timer.cancel();
        return;
      }
      
      try {
        await _pollForNotifications();
      } catch (e) {
        print('❌ Polling error: $e');
      }
    });
  }
  
  /// Poll for notifications via HTTP
  static Future<void> _pollForNotifications() async {
    if (_userTopic == null) return;
    
    try {
      final response = await http.get(
        Uri.parse('$_ntfyServerUrl/$_userTopic/json?since=1m'),
      );
      
      if (response.statusCode == 200) {
        // Process any new messages if needed
        // (Implementation depends on your needs)
      }
    } catch (e) {
      print('❌ Error polling notifications: $e');
    }
  }
  
  /// Monitor network connectivity
  static void _monitorConnectivity() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) {
        final hasConnection = result != ConnectivityResult.none;
        
        if (hasConnection && !_isConnected) {
          print('📶 Network restored, reconnecting...');
          _retryCount = 0;
          _connectWebSocket();
        }
      },
    );
  }
  
  /// Close WebSocket connection
  static Future<void> _closeWebSocket() async {
    await _channelSubscription?.cancel();
    await _channel?.sink.close();
    _channel = null;
    _channelSubscription = null;
    _isConnected = false;
    _connectionStatus.value = false;
  }
  
  /// Show a local notification
  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'venta_cuba_chat',
      'Chat Notifications',
      channelDescription: 'Notifications for chat messages',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload != null ? json.encode(payload) : null,
    );
  }
  
  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final payload = json.decode(response.payload!);
        // Handle navigation based on payload
        // For example, navigate to chat screen
        if (payload['action'] != null) {
          final action = payload['action'].toString();
          if (action.startsWith('myapp://chat/')) {
            // Navigate to chat screen with chatId
            // Get.toNamed('/chat', arguments: {'chatId': chatId});
          }
        }
      } catch (e) {
        print('❌ Error handling notification tap: $e');
      }
    }
  }
  
  /// Send a notification to another user
  static Future<bool> sendNotification({
    required String recipientUserId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? clickAction,
  }) async {
    try {
      print('🔴 NTFY: sendNotification called with:');
      print('🔴 NTFY: recipientUserId: "$recipientUserId"');
      print('🔴 NTFY: clickAction: "$clickAction"');
      print('🔴 NTFY: data: $data');
      
      final recipientTopic = 'venta_cuba_user_$recipientUserId';
      
      final payload = {
        'topic': recipientTopic,
        'title': title,
        'message': body,
        'priority': 4,
        if (clickAction != null) 'click': clickAction,
        if (data != null) ...data,
      };
      
      print('🔴 NTFY: Final payload: $payload');
      
      final response = await http.post(
        Uri.parse('$_ntfyServerUrl/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );
      
      if (response.statusCode == 200) {
        print('✅ Notification sent to user $recipientUserId');
        return true;
      } else {
        print('❌ Failed to send notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending notification: $e');
      return false;
    }
  }
  
  /// Update server URL (for self-hosted instances)
  static Future<void> updateServerUrl(String newUrl) async {
    _ntfyServerUrl = newUrl;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyNtfyUrl, newUrl);
    
    // Reconnect with new server
    await _connectWebSocket();
  }
  
  /// Set chat screen status to prevent notifications when chat is open
  static void setChatScreenStatus({required bool isOpen, String? chatId}) {
    print('testing 🔴 NTFY SERVICE: setChatScreenStatus called - isOpen: $isOpen, chatId: $chatId');
    _isChatScreenOpen = isOpen;
    _currentChatId = chatId;
    print('testing 🔴 NTFY SERVICE: Updated - _isChatScreenOpen = $_isChatScreenOpen, _currentChatId = $_currentChatId');
  }
  
  /// Get connection status
  static bool get isConnected => _isConnected;
  static RxBool get connectionStatus => _connectionStatus;
  
  /// Clean up resources
  static Future<void> dispose() async {
    _reconnectTimer?.cancel();
    await _connectivitySubscription?.cancel();
    await _closeWebSocket();
  }
}
