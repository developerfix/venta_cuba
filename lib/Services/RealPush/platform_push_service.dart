import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ntfy_push_service.dart';
import '../Supabase/supabase_service.dart';
import '../../Notification/firebase_messaging.dart';

/// Simplified Platform Push Service for Cross-Platform Notifications
class PlatformPushService {
  static String? _currentUserId;
  static bool _isChatScreenOpen = false;
  static String? _currentChatId;

  /// Initialize push service for current platform
  static Future<void> initialize(String userId) async {
    try {
      print('🔔 Initializing Push Service for user: $userId on ${Platform.isAndroid ? "Android" : "iOS"}');
      _currentUserId = userId;

      if (Platform.isIOS) {
        await _initializeIOSPush(userId);
      } else if (Platform.isAndroid) {
        await _initializeAndroidPush(userId);
      }

      print('✅ Push Service initialized successfully');
    } catch (e) {
      print('❌ Error initializing Push Service: $e');
    }
  }

  /// Initialize iOS with FCM
  static Future<void> _initializeIOSPush(String userId) async {
    try {
      String? token;

      // Normal FCM flow with APNS token handling
      final messaging = FirebaseMessaging.instance;
      
      // Request permissions first
      final settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Wait for APNS token to be available (reduced retries to prevent hanging)
        print('🔔 Waiting for APNS token...');
        String? apnsToken;
        int maxRetries = 3; // Reduced from 10 to 3
        int retryCount = 0;
        
        while (apnsToken == null && retryCount < maxRetries) {
          try {
            apnsToken = await messaging.getAPNSToken();
            if (apnsToken != null) {
              print('✅ APNS token available: ${apnsToken.substring(0, 20)}...');
              break;
            }
          } catch (e) {
            print('⚠️ APNS token not ready, attempt ${retryCount + 1}/$maxRetries: $e');
          }
          
          retryCount++;
          await Future.delayed(Duration(milliseconds: 500)); // Reduced from 2s to 500ms
        }
        
        if (apnsToken == null) {
          print('❌ APNS token not available after $maxRetries attempts');
          // Show error dialog with delay to not block login
          Future.delayed(Duration(milliseconds: 1000), () {
            try {
              Get.dialog(
                AlertDialog(
                  title: Text('❌ APNS Token Failed'),
                  content: Text('APNS token not available after $maxRetries attempts.\n\nThis prevents FCM token generation on iOS.\n\nNotifications will not work.\n\nPlease screenshot and send to developer.'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            } catch (e) {
              print('Error showing APNS error dialog: $e');
            }
          });
          return;
        }

        // Now get FCM token with APNS token available
        token = await messaging.getToken();
        
        // Retry if token is still null
        if (token == null) {
          print('🔔 FCM token null, retrying...');
          await Future.delayed(Duration(seconds: 3));
          token = await messaging.getToken();
        }
        
        if (token != null && token.isNotEmpty) {
          // Save token to Supabase with iOS platform
          final supabase = SupabaseService.instance;
          bool success = await supabase.saveDeviceTokenWithPlatform(
            userId: userId,
            token: token,
            platform: 'ios',
          );
          
          if (success) {
            print('✅ iOS FCM token saved: ${token.substring(0, 20)}... for user: $userId');
          } else {
            print('❌ Failed to save FCM token to Supabase for user: $userId');
            // Show error dialog with delay to not block login
            Future.delayed(Duration(milliseconds: 1000), () {
              try {
                Get.dialog(
                  AlertDialog(
                    title: Text('❌ Token Save Failed'),
                    content: Text('FCM token could not be saved to Supabase.\n\nToken: ${token!.substring(0, 30)}...\n\nUser ID: $userId\n\nNotifications may not work.\n\nPlease screenshot and send to developer.'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              } catch (dialogError) {
                print('Error showing Supabase save error dialog: $dialogError');
              }
            });
          }
        } else {
          print('⚠️ Could not get FCM token for iOS user: $userId');
          // Show error dialog with delay to not block login
          Future.delayed(Duration(milliseconds: 1000), () {
            try {
              Get.dialog(
                AlertDialog(
                  title: Text('❌ FCM Token Failed'),
                  content: Text('Could not generate FCM token for iOS.\n\nAPNS token was available but FCM token generation failed.\n\nUser ID: $userId\n\nNotifications will not work.\n\nPlease screenshot and send to developer.'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            } catch (e) {
              print('Error showing FCM token failure dialog: $e');
            }
          });
        }

        // Configure foreground presentation
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      } else {
        // Permissions denied - show error dialog
        print('❌ iOS push notification permissions denied: ${settings.authorizationStatus}');
        Future.delayed(Duration(milliseconds: 1000), () {
          try {
            Get.dialog(
              AlertDialog(
                title: Text('❌ Permissions Denied'),
                content: Text('iOS push notification permissions denied.\n\nStatus: ${settings.authorizationStatus}\n\nNotifications will not work.\n\nPlease enable notifications in iOS Settings > Venta Cuba > Notifications.\n\nPlease screenshot and send to developer.'),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          } catch (e) {
            print('Error showing permissions denied dialog: $e');
          }
        });
      }
    } catch (e) {
      print('❌ Error initializing iOS push: $e');
      // Show error dialog with delay to not block login
      Future.delayed(Duration(milliseconds: 1000), () {
        try {
          Get.dialog(
            AlertDialog(
              title: Text('❌ iOS Push Init Failed'),
              content: Text('Error initializing iOS push notifications:\n\n$e\n\nNotifications will not work.\n\nPlease screenshot and send to developer.'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        } catch (dialogError) {
          print('Error showing iOS init error dialog: $dialogError');
        }
      });
      rethrow; // Re-throw to allow timeout handling in auth controller
    }
  }

  /// Initialize Android with ntfy
  static Future<void> _initializeAndroidPush(String userId) async {
    try {
      // Initialize ntfy service first
      await NtfyPushService.initialize(userId: userId);
      
      // Save Android platform info to Supabase with ntfy topic
      final supabase = SupabaseService.instance;
      final ntfyTopic = 'venta_cuba_user_$userId';
      
      await supabase.saveDeviceTokenWithPlatform(
        userId: userId,
        token: ntfyTopic, // Use actual ntfy topic
        platform: 'android',
      );
      
      print('✅ Android ntfy service initialized with topic: $ntfyTopic for user: $userId');
    } catch (e) {
      print('❌ Error initializing Android push: $e');
      // Show error dialog with delay to not block login
      Future.delayed(Duration(milliseconds: 1000), () {
        try {
          Get.dialog(
            AlertDialog(
              title: Text('❌ Android Push Failed'),
              content: Text('Error initializing Android push notifications:\n\n$e\n\nUser ID: $userId\n\nNotifications may not work.\n\nPlease screenshot and send to developer.'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        } catch (dialogError) {
          print('Error showing Android push error dialog: $dialogError');
        }
      });
    }
  }

  /// Send chat notification to recipient (Cross-platform) - FIXED VERSION
  static Future<void> sendChatNotification({
    required String recipientUserId,
    required String senderName,
    required String message,
    required String messageType,
    required String chatId,
    String? senderId,
  }) async {
    try {
      print('🔔 === CROSS-PLATFORM NOTIFICATION ===');
      print('🔔 From: ${senderId ?? _currentUserId} To: $recipientUserId');
      
      // Don't send notification to yourself
      if (recipientUserId == (senderId ?? _currentUserId)) {
        print('🔔 Skipping self-notification');
        return;
      }
      
      // Get recipient's device info from Supabase
      final supabaseService = SupabaseService.instance;
      
      // First try to get the device token directly
      final recipientToken = await supabaseService.getDeviceToken(recipientUserId);
      print('🔔 Recipient token retrieved: ${recipientToken?.substring(0, 30) ?? "NULL"}...');
      
      // Determine platform based on token pattern
      String? recipientPlatform;
      if (recipientToken != null && recipientToken.isNotEmpty) {
        if (recipientToken.startsWith('venta_cuba_user_') || 
            recipientToken.startsWith('ntfy_user_')) {
          recipientPlatform = 'android';
        } else if (recipientToken.length > 50) {
          // FCM tokens are typically long strings
          recipientPlatform = 'ios';
        }
      }
      
      // If platform detection failed, try to get it explicitly
      if (recipientPlatform == null) {
        recipientPlatform = await supabaseService.getUserPlatform(recipientUserId);
      }
      
      print('🔔 Detected platform: ${recipientPlatform ?? "UNKNOWN"}');
      print('🔔 Token pattern: ${recipientToken?.substring(0, 20) ?? "NO TOKEN"}...');
      
      // Send notification based on platform
      if (recipientPlatform == 'ios' && recipientToken != null && 
          !recipientToken.startsWith('venta_cuba_user_') && 
          !recipientToken.startsWith('ntfy_user_')) {
        
        // iOS: Use FCM
        print('🍎 Sending FCM notification to iOS user');
        
        final fcmService = FCM();
        final success = await fcmService.sendNotificationFCM(
          userId: recipientUserId,
          remoteId: senderId ?? _currentUserId ?? '',
          name: senderName,
          deviceToken: recipientToken,
          title: senderName,
          body: _formatMessageBody(message, messageType),
          type: 'message',
          chatId: chatId,
        );
        
        if (success) {
          print('✅ FCM notification sent successfully to iOS user');
        } else {
          print('❌ FCM notification failed for iOS user');
        }
        
      } else {
        // Android: Use ntfy (default for Android or unknown)
        print('🤖 Sending ntfy notification to Android user');
        
        final success = await NtfyPushService.sendNotification(
          recipientUserId: recipientUserId,
          title: senderName,
          body: _formatMessageBody(message, messageType),
          clickAction: 'myapp://chat/$chatId',
          data: {
            'chatId': chatId,
            'senderId': senderId ?? _currentUserId ?? '',
            'type': 'chat'
          },
        );
        
        if (success) {
          print('✅ ntfy notification sent successfully to Android user');
        } else {
          print('❌ ntfy notification failed for Android user');
        }
      }
      
    } catch (e, stackTrace) {
      print('❌ Error in sendChatNotification: $e');
      print('❌ Stack trace: $stackTrace');
    }
  }

  /// Format message body based on type
  static String _formatMessageBody(String message, String messageType) {
    switch (messageType) {
      case 'image':
        return '📷 Photo';
      case 'video':
        return '📹 Video';
      case 'file':
        return '📎 File';
      case 'audio':
        return '🎵 Audio';
      default:
        return message.length > 100 
          ? '${message.substring(0, 97)}...' 
          : message;
    }
  }

  /// Set chat screen status
  static void setChatScreenStatus({required bool isOpen, String? chatId}) {
    _isChatScreenOpen = isOpen;
    _currentChatId = chatId;
    
    if (Platform.isAndroid) {
      NtfyPushService.setChatScreenStatus(isOpen: isOpen, chatId: chatId);
    }
  }

  /// Get FCM token (iOS only)
  static Future<String?> getFCMToken() async {
    try {
      if (Platform.isIOS) {
        // Get actual FCM token with APNS token check
        final messaging = FirebaseMessaging.instance;
        
        // First ensure APNS token is available (reduced retries)
        print('🔔 Checking APNS token availability...');
        String? apnsToken;
        int maxRetries = 2; // Reduced from 5 to 2
        int retryCount = 0;
        
        while (apnsToken == null && retryCount < maxRetries) {
          try {
            apnsToken = await messaging.getAPNSToken();
            if (apnsToken != null) {
              print('✅ APNS token available for FCM token generation');
              break;
            }
          } catch (e) {
            print('⚠️ APNS token not ready, attempt ${retryCount + 1}/$maxRetries: $e');
          }
          
          retryCount++;
          await Future.delayed(Duration(milliseconds: 500)); // Reduced from 2s to 500ms
        }
        
        if (apnsToken == null) {
          print('❌ APNS token not available, cannot generate FCM token');
          // Show error dialog for APNS token failure in getFCMToken
          Future.delayed(Duration(milliseconds: 1000), () {
            try {
              Get.dialog(
                AlertDialog(
                  title: Text('❌ APNS Token Unavailable'),
                  content: Text('APNS token not available in getFCMToken after $maxRetries attempts.\n\nCannot generate FCM token without APNS token.\n\nNotifications will not work.\n\nPlease screenshot and send to developer.'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            } catch (e) {
              print('Error showing APNS unavailable dialog: $e');
            }
          });
          return null;
        }

        // Now get FCM token
        String? token = await messaging.getToken();
        
        // Retry if token is null
        if (token == null) {
          print('🔔 FCM token null, retrying...');
          await Future.delayed(Duration(seconds: 3));
          token = await messaging.getToken();
        }
        
        if (token != null) {
          print('🔔 Retrieved FCM token: ${token.substring(0, 20)}...');
        } else {
          print('⚠️ Could not retrieve FCM token after APNS token was available');
          // Show error dialog for FCM token failure in getFCMToken
          Future.delayed(Duration(milliseconds: 1000), () {
            try {
              Get.dialog(
                AlertDialog(
                  title: Text('❌ FCM Token Generation Failed'),
                  content: Text('Could not retrieve FCM token in getFCMToken even though APNS token was available.\n\nThis indicates a Firebase configuration or network issue.\n\nNotifications will not work.\n\nPlease screenshot and send to developer.'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            } catch (e) {
              print('Error showing FCM generation failed dialog: $e');
            }
          });
        }
        
        return token;
      }
      return null;
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      // Show error dialog with real error details
      Future.delayed(Duration(milliseconds: 1000), () {
        try {
          Get.dialog(
            AlertDialog(
              title: Text('❌ FCM Token Error'),
              content: Text('Exception occurred while getting FCM token:\n\n$e\n\nNotifications will not work.\n\nPlease screenshot and send to developer.'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        } catch (dialogError) {
          print('Error showing FCM token error dialog: $dialogError');
        }
      });
      return null;
    }
  }

  /// Stop listening
  static Future<void> stopListening() async {
    if (Platform.isAndroid) {
      await NtfyPushService.dispose();
    }
    _currentUserId = null;
    _isChatScreenOpen = false;
    _currentChatId = null;
  }

  /// Re-register device token (for token refresh)
  static Future<void> refreshDeviceToken(String userId) async {
    try {
      print('🔔 Refreshing device token for user: $userId');
      
      if (Platform.isIOS) {
        await _initializeIOSPush(userId);
      } else {
        await _initializeAndroidPush(userId);
      }
      
      print('✅ Device token refreshed');
    } catch (e) {
      print('❌ Error refreshing device token: $e');
    }
  }
}
