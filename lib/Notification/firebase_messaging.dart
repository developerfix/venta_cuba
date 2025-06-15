import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as meth;
import 'dart:typed_data';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app_badge_control/flutter_app_badge_control.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:venta_cuba/Services/Notfication/notficationservice.dart';
import 'package:venta_cuba/Utils/global_variabel.dart';

import '../Controllers/auth_controller.dart';
import 'fcm_model.dart';

bool isOpenFile = false;
String filePathD = "";

class FCM {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final streamCtrl = StreamController<String>.broadcast();
  final authCont = Get.put(AuthController());

  // Badge count management
  static int _badgeCount = 0;

  // static SharedPreference sharedPreference = SharedPreference();
  // final NavigationService _navigationService = locator<NavigationService>();
  //
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings androidInitializationSettings =
      const AndroidInitializationSettings('@drawable/profits');
  late DarwinInitializationSettings iosInitializationSettings;
  late InitializationSettings initializationSettings;

  void initializing() async {
    await FirebaseMessaging.instance
        .setAutoInitEnabled(true); // later added for manifest.xml permission
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    )
        .catchError((onError) {
      print("this is firebase error::: ${onError.toString()}");
    });

    androidInitializationSettings =
        const AndroidInitializationSettings('@drawable/profits');
    iosInitializationSettings = const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );
    initializationSettings = InitializationSettings(
        iOS: iosInitializationSettings, android: androidInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveLocalNotification,
    );
  }

  void firebaseCloudMessagingListeners(BuildContext context) {
    if (Platform.isIOS) ios_permission();
    print('🔥 Starting Firebase messaging listeners...');

    // Listen for messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔥 Received foreground message: ${message.messageId}');
      print('🔥 Message data: ${message.data}');
      print(
          '🔥 Message notification: ${message.notification?.title} - ${message.notification?.body}');

      Map<String, dynamic> messageData = message.data;

      // Set the unread messages flag to true when a new message arrives
      authCont.hasUnreadMessages.value = true;
      authCont.update();

      // Always show notifications in foreground (removed conditional check)
      String title =
          messageData["title"] ?? message.notification?.title ?? "New Message";
      String body = messageData["body"] ??
          message.notification?.body ??
          "You have a new message";

      print('🔥 Showing foreground notification: $title - $body');

      _showNotifications(
          body,
          title,
          'message_channel',
          'message',
          jsonEncode({
            'image': messageData["image"]?.toString() ?? "",
            'name': messageData["name"] ?? "",
            'userId': messageData["userId"] ?? "",
            'remoteId': messageData["remoteId"] ?? "",
            'type': messageData["type"] ?? "message",
          }),
          false,
          false,
          AndroidNotificationCategory.message);
    });

    // Listen for messages when app is in background but opened
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🔥 App opened from background message: ${message.messageId}');
      print('🔥 Message data: ${message.data}');
      // Handle navigation to chat if needed
      _handleNotificationTap(message);
    });

    // Handle initial message when app is opened from terminated state
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        print('🔥 App opened from terminated state: ${message.messageId}');
        print('🔥 Message data: ${message.data}');
        // Handle navigation to chat if needed
        _handleNotificationTap(message);
      }
    });
  }

  static void _showNotifications(
      String body,
      String title,
      String channelDescription,
      String ticker,
      String payLoad,
      bool wakeUpScreen,
      bool autoCancel,
      AndroidNotificationCategory category) async {
    print("PayLoad>>>>>>>>>>>>>>>>>$payLoad");
    await notification(body, title, channelDescription, ticker, payLoad,
        wakeUpScreen, autoCancel, category);
    // }
  }

  static Future<void> notification(
      String body,
      String title,
      String channelDescription,
      String ticker,
      String payLoad,
      bool wakeUpScreen,
      bool autoCancel,
      AndroidNotificationCategory category,
      {int? badgeCount}) async {
    var vibrationPattern = Int64List(8);

    vibrationPattern[0] = 0;
    vibrationPattern[1] = 250;
    vibrationPattern[2] = 500;
    vibrationPattern[3] = 250;
    vibrationPattern[4] = 500;
    vibrationPattern[5] = 250;
    vibrationPattern[4] = 500;
    vibrationPattern[5] = 250;
    vibrationPattern[6] = 0;

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            meth.Random().nextInt(1000).toString(), title,
            priority: Priority.high,
            largeIcon: const DrawableResourceAndroidBitmap('@drawable/profits'),
            vibrationPattern: vibrationPattern,
            channelDescription: channelDescription,
            fullScreenIntent: wakeUpScreen,
            category: category,
            autoCancel: autoCancel,
            importance: Importance.high,
            channelShowBadge: true,
            styleInformation:
                BigTextStyleInformation(body, htmlFormatSummaryText: true),
            ticker: ticker);

    // Use provided badge count or increment current count
    int currentBadgeCount = badgeCount ?? (getBadgeCount() + 1);
    if (badgeCount == null) {
      await incrementBadgeCount();
    }

    DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default', // Explicitly set default sound
      badgeNumber: currentBadgeCount,
      interruptionLevel: InterruptionLevel.active,
    );

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
        meth.Random().nextInt(1000), title, body, notificationDetails,
        payload: payLoad);
  }

  Future<void> ios_permission() async {
    if (Platform.isIOS) {
      // Request local notification permissions first
      final bool? result = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      print('🔥 iOS Local Notification Permissions Result: $result');

      // Also request Firebase messaging permissions
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        announcement: false,
      );

      print('🔥 Firebase iOS Permissions - Sound: ${settings.sound}');
      print('🔥 Firebase iOS Permissions - Alert: ${settings.alert}');
      print('🔥 Firebase iOS Permissions - Badge: ${settings.badge}');
    } else if (Platform.isAndroid) {
      // Android notification permissions are handled automatically
      print('🔥 Android platform detected - permissions handled automatically');
      await _firebaseMessaging.requestPermission(
          sound: true, badge: true, alert: true);
    }
  }

  setNotifications(BuildContext context) async {
    initializing();
    firebaseCloudMessagingListeners(context);

    // Load badge count from storage
    await loadBadgeCount();

    // Request notification permissions
    await requestNotificationPermissions();

    // Check and log current permission status for debugging
    await checkNotificationPermissions();

    if (Platform.isIOS) {
      try {
        String? apnsToken = await _firebaseMessaging.getAPNSToken();
        print('APNS Token: $apnsToken');
        await Future.delayed(Duration(seconds: 2));
      } catch (e) {
        print('error:$e');
      }
    }

    // Get initial token
    await getAndUpdateToken();

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      deviceToken = newToken;
      debugPrint('🔥 Token refreshed: $newToken');
      // Update token locally if user is logged in
      updateTokenOnServer(newToken);
    });
  }

  Future<void> getAndUpdateToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        deviceToken = token;
        debugPrint('🔥 Initial device token: $token');
        // Update token locally if user is logged in
        updateTokenOnServer(token);
      } else {
        print('🔥 Failed to get FCM token');
      }
    } catch (e) {
      print('🔥 Error getting FCM token: $e');
    }
  }

  Future<void> requestNotificationPermissions() async {
    try {
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('🔥 === NOTIFICATION PERMISSIONS ===');
      print('🔥 Authorization Status: ${settings.authorizationStatus}');
      print('🔥 Alert Setting: ${settings.alert}');
      print('🔥 Badge Setting: ${settings.badge}');
      print('🔥 Sound Setting: ${settings.sound}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('🔥 ✅ User granted full notification permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('🔥 ⚠️ User granted provisional notification permission');
      } else {
        print('🔥 ❌ User declined or has not accepted notification permission');
        print('🔥 ❌ Push notifications will NOT work!');
      }
    } catch (e) {
      print('🔥 ❌ Error requesting notification permissions: $e');
    }
  }

  // Badge management methods
  static Future<void> incrementBadgeCount() async {
    _badgeCount++;
    print('🔥 Badge count incremented to: $_badgeCount');
    await _updateAppIconBadge(_badgeCount);
  }

  static Future<void> resetBadgeCount() async {
    _badgeCount = 0;
    print('🔥 Badge count reset to: $_badgeCount');
    await _updateAppIconBadge(0);
  }

  static int getBadgeCount() {
    return _badgeCount;
  }

  static Future<void> setBadgeCount(int count) async {
    _badgeCount = count;
    print('🔥 Badge count set to: $_badgeCount');
    await _updateAppIconBadge(count);
  }

  // Update app icon badge using flutter_app_badge_control
  static Future<void> _updateAppIconBadge(int count) async {
    try {
      if (count > 0) {
        await FlutterAppBadgeControl.updateBadgeCount(count);
        print('🔥 App icon badge updated to: $count');
      } else {
        await FlutterAppBadgeControl.removeBadge();
        print('🔥 App icon badge removed');
      }
      // Save badge count to persistent storage
      await _saveBadgeCount(count);
    } catch (e) {
      print('🔥 Error updating app icon badge: $e');
    }
  }

  // Save badge count to SharedPreferences
  static Future<void> _saveBadgeCount(int count) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('badge_count', count);
      print('🔥 Badge count saved to storage: $count');
    } catch (e) {
      print('🔥 Error saving badge count: $e');
    }
  }

  // Load badge count from SharedPreferences
  static Future<void> loadBadgeCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _badgeCount = prefs.getInt('badge_count') ?? 0;
      print('🔥 Badge count loaded from storage: $_badgeCount');

      // Update app icon badge on app start
      await _updateAppIconBadge(_badgeCount);
    } catch (e) {
      print('🔥 Error loading badge count: $e');
      _badgeCount = 0;
    }
  }

  // Public method to check if badge control is supported
  static Future<bool> isBadgeSupported() async {
    try {
      return await FlutterAppBadgeControl.isAppBadgeSupported();
    } catch (e) {
      print('🔥 Error checking badge support: $e');
      return false;
    }
  }

  // Public method to manually update badge (useful for chat read status)
  static Future<void> updateBadgeForReadMessages(int unreadCount) async {
    await setBadgeCount(unreadCount);
  }

  // Check and log notification permissions status (useful for debugging)
  static Future<void> checkNotificationPermissions() async {
    try {
      final FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.getNotificationSettings();

      print('🔥 === CURRENT NOTIFICATION PERMISSIONS STATUS ===');
      print('🔥 Authorization Status: ${settings.authorizationStatus}');
      print('🔥 Alert Setting: ${settings.alert}');
      print('🔥 Badge Setting: ${settings.badge}');
      print('🔥 Sound Setting: ${settings.sound}');
      print('🔥 Critical Alert: ${settings.criticalAlert}');
      print('🔥 Announcement: ${settings.announcement}');

      if (Platform.isIOS) {
        print(
            '🔥 iOS Sound Permission: ${settings.sound == AppleNotificationSetting.enabled ? "ENABLED" : "DISABLED"}');
        if (settings.sound != AppleNotificationSetting.enabled) {
          print(
              '🔥 ⚠️ WARNING: Sound permission is not enabled! User needs to enable it in Settings.');
        }
      }
    } catch (e) {
      print('🔥 Error checking notification permissions: $e');
    }
  }

  // Test notification with sound (useful for debugging)
  static Future<void> sendTestNotificationWithSound() async {
    try {
      print('🔥 Sending test notification with sound...');

      await notification(
        'This is a test notification to verify sound is working',
        'Test Notification Sound',
        'test_channel',
        'test',
        '{"type": "test"}',
        false,
        true,
        AndroidNotificationCategory.message,
        badgeCount: 1,
      );

      print('🔥 Test notification sent successfully');
    } catch (e) {
      print('🔥 Error sending test notification: $e');
    }
  }

  // Clear badge count and update app icon
  static Future<void> clearBadgeCount() async {
    await resetBadgeCount();

    // Additional iOS notification badge clearing for compatibility
    if (Platform.isIOS) {
      try {
        // Show a notification with badge count 0 to clear the notification badge
        DarwinNotificationDetails iosNotificationDetails =
            const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          badgeNumber: 0,
        );

        NotificationDetails notificationDetails = NotificationDetails(
          iOS: iosNotificationDetails,
        );

        await flutterLocalNotificationsPlugin.show(
          999999, // Use a unique ID for badge clearing
          '',
          '',
          notificationDetails,
        );

        // Cancel the notification immediately so it doesn't show
        await flutterLocalNotificationsPlugin.cancel(999999);

        print('🔥 iOS notification badge cleared');
      } catch (e) {
        print('🔥 Error clearing iOS notification badge: $e');
      }
    }

    print('🔥 Badge count cleared successfully');
  }

  Future<void> updateTokenOnServer(String token) async {
    try {
      // Only update if user is logged in
      if (authCont.user?.accessToken != null &&
          authCont.user?.accessToken != "") {
        print('🔥 Updating device token locally: $token');
        // Update device token locally (no server API call)
        await authCont.updateDeviceToken(token);
        print('🔥 Device token updated successfully');
      } else {
        print('🔥 User not logged in, skipping token update');
      }
    } catch (e) {
      print('🔥 Error updating token: $e');
    }
  }

  Future<bool> sendNotificationFCM({
    String? userId,
    String? remoteId,
    String? name,
    String? profileImage,
    String? deviceToken,
    String? title,
    String? body,
    String? type,
    int? badgeCount,
  }) async {
    // Ensure a fresh token
    NotificationService notificationService = NotificationService();
    await notificationService.obtainCredentials();

    if (notificationAccessToken.isEmpty) {
      print('🔥 Error: No valid access token available');
      return false;
    }

    // Increment badge count if not provided
    if (badgeCount == null) {
      await incrementBadgeCount();
      badgeCount = getBadgeCount();
    }

    Data data = Data(
      userId: userId,
      remoteId: remoteId,
      name: name,
      profileImage: profileImage,
      title: title,
      body: body,
      type: type,
    );
    NotificationData notification = NotificationData(title: title, body: body);

    // Create APNS configuration with badge count
    ApnsConfig apnsConfig = ApnsConfig(
      payload: ApnsPayload(
        aps: Aps(
          badge: badgeCount,
          sound: 'default',
        ),
      ),
    );

    FCMModel fcmModel = FCMModel(
      data: data,
      token: deviceToken,
      notification: notification,
      apns: apnsConfig,
    );

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $notificationAccessToken',
    };
    var request = http.Request(
      'POST',
      Uri.parse(
          'https://fcm.googleapis.com/v1/projects/ventacuba-acf38/messages:send'),
    );
    request.body = jsonEncode({"message": fcmModel.toJson()});
    print('Request body: ${request.body}');
    print('notificationAccessToken: ${notificationAccessToken}');
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      print('🔥 FCM StatusCode: ${response.statusCode}');
      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        print('🔥 FCM Success: $responseBody');
        return true; // Success
      } else {
        String errorResponse = await response.stream.bytesToString();
        print('🔥 FCM Error response: $errorResponse');
        print('🔥 FCM Reason: ${response.reasonPhrase}');

        // Check if it's an UNREGISTERED token error
        if (errorResponse.contains('UNREGISTERED')) {
          print('🔥 Device token is invalid/expired. Token: $deviceToken');
          print('🔥 Consider refreshing the device token for this user');
        }
        return false; // Failed
      }
    } catch (e) {
      print('🔥 Error sending FCM request: $e');
      return false; // Failed
    }
  }

  void onDidReceiveLocalNotification(
      NotificationResponse notificationResponse) async {
    try {
      print('🔥 Local notification tapped: ${notificationResponse.payload}');
      if (notificationResponse.payload != null) {
        Map<String, dynamic> data = jsonDecode(notificationResponse.payload!);
        print('🔥 Notification payload data: $data');
        // Handle navigation based on notification data
      }
    } catch (e) {
      print('🔥 Error handling local notification tap: $e');
    }
  }

  // Handle notification tap to navigate to chat
  void _handleNotificationTap(RemoteMessage message) {
    try {
      print('🔥 Handling notification tap...');
      Map<String, dynamic> data = message.data;

      if (data['type'] == 'message' && data['remoteId'] != null) {
        print('🔥 Navigating to chat with user: ${data['remoteId']}');
        // You can add navigation logic here if needed
        // For example: Get.to(() => ChatPage(...));
      }
    } catch (e) {
      print('🔥 Error handling notification tap: $e');
    }
  }

  // Static method for background notifications
  static Future<void> showBackgroundNotification(RemoteMessage message) async {
    try {
      print('🔥 Showing background notification...');

      // Initialize local notifications if not already done
      await flutterLocalNotificationsPlugin.initialize(
        InitializationSettings(
          android: AndroidInitializationSettings('@drawable/profits'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
            defaultPresentAlert: true,
            defaultPresentBadge: true,
            defaultPresentSound: true,
          ),
        ),
      );

      String title =
          message.notification?.title ?? message.data['title'] ?? 'New Message';
      String body = message.notification?.body ??
          message.data['body'] ??
          'You have a new message';

      // Increment badge count for background notifications
      await incrementBadgeCount();

      await notification(
        body,
        title,
        'message_channel',
        'message',
        jsonEncode(message.data),
        false,
        false,
        AndroidNotificationCategory.message,
        badgeCount: getBadgeCount(),
      );

      print('🔥 Background notification shown successfully');
    } catch (e) {
      print('🔥 Error showing background notification: $e');
    }
  }
}
