import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:venta_cuba/Services/push_service.dart';
import 'package:venta_cuba/Services/notification_manager.dart';
import 'package:venta_cuba/Services/Supabase/supabase_service.dart';
import 'package:venta_cuba/Services/Supabase/rls_helper.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';

class SupabaseChatController extends GetxController {
  String? path;
  bool isLast = false;
  bool isTyping = false;
  bool isImageSend = false;

  Stream<List<Map<String, dynamic>>>? chats;
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();
  bool isShow = false;

  final SupabaseClient _supabase = SupabaseService.client;

  // Connection pre-warming for instant messaging
  Timer? _connectionKeepAliveTimer;
  DateTime? _lastConnectionCheck;

  // Getter for Supabase client
  SupabaseClient get supabaseClient => _supabase;

  // PERFORMANCE OPTIMIZATION: Message cache for faster loading
  final Map<String, List<Map<String, dynamic>>> _messageCache = {};

  // PERFORMANCE OPTIMIZATION: Debouncing for message loading
  Timer? _loadDebounceTimer;

  // Badge update debouncer to prevent multiple updates
  Timer? _badgeUpdateDebouncer;
  bool _isBadgeUpdatePending = false;

  // PERFORMANCE OPTIMIZATION: Batch message sending queue
  final List<Map<String, dynamic>> _messageQueue = [];
  Timer? _messageQueueTimer;
  bool _isProcessingQueue = false;

  // Connection pool for better performance
  static const int _maxRetries = 2;
  static const Duration _retryDelay = Duration(milliseconds: 500);

  // Message streams cache
  final Map<String, StreamController<List<Map<String, dynamic>>>>
      _messageStreams = {};

  // Global chat refresh callbacks for manual triggering
  final List<Function()> _globalChatRefreshCallbacks = [];

  // Realtime subscriptions
  RealtimeChannel? _chatChannel;
  RealtimeChannel? _messagesChannel;
  final Map<String, RealtimeChannel> _messageChannels = {};

  @override
  void onInit() {
    super.onInit();
    // Start connection keep-alive
    _startConnectionKeepAlive();
  }

  @override
  void onClose() {
    _loadDebounceTimer?.cancel();
    _badgeUpdateDebouncer?.cancel();
    _messageQueueTimer?.cancel();
    _connectionKeepAliveTimer?.cancel();
    _processMessageQueue(); // Process any remaining messages

    // Clean up subscriptions
    _chatChannel?.unsubscribe();
    _messagesChannel?.unsubscribe();
    for (var channel in _messageChannels.values) {
      channel.unsubscribe();
    }

    // Clean up stream controllers
    for (var entry in _messageStreams.entries) {
      if (!entry.value.isClosed) {
        entry.value.close();
      }
    }
    _messageStreams.clear();
    _globalChatRefreshCallbacks.clear();
    _messageCache.clear();

    super.onClose();
  }

  // Method to clear specific chat stream (for testing/debugging)
  void clearChatStream(String chatId) {
    if (_messageStreams.containsKey(chatId)) {
      if (!_messageStreams[chatId]!.isClosed) {
        _messageStreams[chatId]!.close();
      }
      _messageStreams.remove(chatId);
    }

    if (_messageChannels.containsKey(chatId)) {
      _messageChannels[chatId]?.unsubscribe();
      _messageChannels.remove(chatId);
    }

    // Clear cache
    _messageCache.remove(chatId);
  }

  // OPTIMIZED: Get all chats with unread calculation
  Stream<List<Map<String, dynamic>>> getAllChats(String userId) {
    // Create a fresh stream controller each time to avoid caching issues
    final StreamController<List<Map<String, dynamic>>> controller =
        StreamController<List<Map<String, dynamic>>>.broadcast();

    // PERFORMANCE: Use single query with OR condition and retry logic
    Future<void> loadChats() async {
      int retryCount = 0;

      while (retryCount < _maxRetries) {
        try {
          // Single optimized query to get all chats
          final allChats = await _supabase
              .from('chats')
              .select()
              .or('sender_id.eq.$userId,send_to_id.eq.$userId')
              .order('time', ascending: false)
              .limit(50); // Limit to recent chats for better performance

          final result = List<Map<String, dynamic>>.from(allChats);

          // Calculate unread count for each chat
          for (var chat in result) {
            final isUserSender = chat['sender_id'] == userId;
            final lastReadTime = isUserSender
                ? chat['sender_last_read_time']
                : chat['recipient_last_read_time'];
            final lastMessageTime = chat['time'];
            final lastMessageSender = chat['send_by'];

            // Calculate unread count for this chat
            int unreadCount = 0;
            if (lastMessageSender != userId) {
              if (lastReadTime == null ||
                  (lastMessageTime != null &&
                      DateTime.parse(lastMessageTime)
                          .isAfter(DateTime.parse(lastReadTime)))) {
                // Count unread messages for this specific chat
                final unreadMessages = await _supabase
                    .from('messages')
                    .select('id')
                    .eq('chat_id', chat['id'])
                    .neq('send_by', userId)
                    .gt('time', lastReadTime ?? '1970-01-01T00:00:00Z');

                unreadCount = unreadMessages.length;
              }
            }

            // Add unread count to chat data
            chat['unread_count'] = unreadCount;
          }

          // Emit data to stream
          if (!controller.isClosed) {
            controller.add(result);
          }

          // Update overall unread count (debounced)
          // This happens when loading all chats, so it's safe to update
          debouncedUpdateUnreadIndicators();

          break; // Success, exit retry loop
        } catch (e) {
          retryCount++;
          if (retryCount >= _maxRetries) {
            print('Failed to load chats after retries: $e');
            if (!controller.isClosed) {
              controller.add(<Map<String, dynamic>>[]);
            }
            break;
          }
          await Future.delayed(_retryDelay);
        }
      }
    }

    // Register this stream's refresh function globally for manual triggers
    _globalChatRefreshCallbacks.add(loadChats);

    // Initial load
    loadChats();

    // OPTIMIZED: Single channel for all chat updates
    try {
      _chatChannel?.unsubscribe();
      _chatChannel = _supabase
          .channel('all_chats_$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'chats',
            callback: (payload) {
              print('🔄 Chat table change detected: ${payload.eventType}');
              // Debounce the refresh to avoid too many updates
              _loadDebounceTimer?.cancel();
              _loadDebounceTimer = Timer(Duration(milliseconds: 300), () {
                print('🔄 Refreshing chat list due to realtime update');
                loadChats();
              });
            },
          )
          .subscribe();
    } catch (e) {
      print('Error setting up chat subscription: $e');
    }

    // Clean up when stream is canceled
    controller.onCancel = () {
      _globalChatRefreshCallbacks.remove(loadChats);
    };

    return controller.stream;
  }

  // Method to manually refresh all active chat list streams
  void refreshAllChatLists() {
    print(
        '🔄 Manually refreshing ${_globalChatRefreshCallbacks.length} chat list streams');
    for (final callback in _globalChatRefreshCallbacks) {
      try {
        callback();
      } catch (e) {
        print('Error in chat refresh callback: $e');
      }
    }
  }

  // OPTIMIZED: Get messages with instant loading and caching
  Stream<List<Map<String, dynamic>>> getChatMessages(String chatId) {
    // Validate chat ID
    if (chatId.isEmpty || chatId == 'null') {
      return Stream.value(<Map<String, dynamic>>[]);
    }

    // Create or get existing stream controller for this chat
    if (!_messageStreams.containsKey(chatId) ||
        _messageStreams[chatId]!.isClosed) {
      _messageStreams[chatId] =
          StreamController<List<Map<String, dynamic>>>.broadcast();

      // Check cache first and emit immediately
      if (_messageCache.containsKey(chatId) &&
          _messageCache[chatId]!.isNotEmpty) {
        // Emit cached data immediately for instant display
        _messageStreams[chatId]!.add(List.from(_messageCache[chatId]!));

        // Load fresh data in background to update cache
        Future.microtask(() => _loadMessagesForChat(chatId, useCache: false));
      } else {
        // No cache, emit empty list first for instant UI update
        _messageStreams[chatId]!.add(<Map<String, dynamic>>[]);

        // Load data immediately
        _loadMessagesForChat(chatId).catchError((error) {
          if (_messageStreams.containsKey(chatId) &&
              !_messageStreams[chatId]!.isClosed) {
            _messageStreams[chatId]!.add(<Map<String, dynamic>>[]);
          }
        });
      }

      // Set up real-time subscription
      _setupRealtimeSubscription(chatId);
    } else {
      // Stream already exists, ensure subscription is active
      if (!_messageChannels.containsKey(chatId)) {
        _setupRealtimeSubscription(chatId);
      }

      // Always emit current cache state
      if (_messageCache.containsKey(chatId)) {
        _messageStreams[chatId]!.add(List.from(_messageCache[chatId]!));
      } else {
        _messageStreams[chatId]!.add(<Map<String, dynamic>>[]);
      }
    }

    return _messageStreams[chatId]!.stream;
  }

  // OPTIMIZED: Load messages with pagination for better performance
  Future<void> _loadMessagesForChat(String chatId,
      {int limit = 100, bool useCache = true}) async {
    try {
      // Return early if we have fresh cache and useCache is true
      if (useCache &&
          _messageCache.containsKey(chatId) &&
          _messageCache[chatId]!.isNotEmpty) {
        final lastMessage = _messageCache[chatId]!.last;
        if (lastMessage['time'] != null) {
          final messageTime = DateTime.tryParse(lastMessage['time']);
          if (messageTime != null) {
            final timeDiff = DateTime.now().difference(messageTime);
            // If cache is less than 30 seconds old, skip refresh
            if (timeDiff.inSeconds < 30) {
              return;
            }
          }
        }
      }

      // Load messages with retry logic for better reliability
      List<Map<String, dynamic>> messages = [];
      int retryCount = 0;

      while (retryCount < _maxRetries) {
        try {
          final response = await _supabase
              .from('messages')
              .select('*')
              .eq('chat_id', chatId)
              .order('time', ascending: false)
              .limit(limit);

          messages = List<Map<String, dynamic>>.from(response);
          break; // Success, exit retry loop
        } catch (e) {
          retryCount++;
          if (retryCount >= _maxRetries) {
            throw e;
          }
          await Future.delayed(_retryDelay);
        }
      }

      // Reverse to get chronological order
      messages = messages.reversed.toList();

      // Update cache
      _messageCache[chatId] = messages;

      // Always add data to stream
      if (_messageStreams.containsKey(chatId) &&
          !_messageStreams[chatId]!.isClosed) {
        _messageStreams[chatId]!.add(List.from(messages));
      }
    } catch (e) {
      print('Error loading messages after retries: $e');
      // Use cached data if available on error
      if (_messageCache.containsKey(chatId)) {
        if (_messageStreams.containsKey(chatId) &&
            !_messageStreams[chatId]!.isClosed) {
          _messageStreams[chatId]!.add(List.from(_messageCache[chatId]!));
        }
      } else {
        // Add empty data to prevent infinite loading
        if (_messageStreams.containsKey(chatId) &&
            !_messageStreams[chatId]!.isClosed) {
          _messageStreams[chatId]!.add(<Map<String, dynamic>>[]);
        }
      }
    }
  }

  // OPTIMIZED: Real-time subscription with better error handling
  void _setupRealtimeSubscription(String chatId) {
    if (!_messageChannels.containsKey(chatId)) {
      try {
        _messageChannels[chatId] = _supabase
            .channel('msg_$chatId')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'messages',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'chat_id',
                value: chatId,
              ),
              callback: (payload) {
                // Handle real-time updates
                if (payload.eventType == PostgresChangeEvent.insert) {
                  // Check if this is not a duplicate of a message we already have
                  if (_messageCache.containsKey(chatId)) {
                    final newMessage = payload.newRecord;

                    // More robust duplicate detection
                    bool isDuplicate = _messageCache[chatId]!.any((msg) =>
                        // Check by actual database ID first
                        msg['id'] == newMessage['id'] ||
                        // Then check by content, sender and time (for real messages)
                        (msg['_optimistic'] !=
                                true && // Only check against real messages
                            msg['message'] == newMessage['message'] &&
                            msg['send_by'] == newMessage['send_by'] &&
                            msg['time'] == newMessage['time']));

                    // Also check if we have a pending optimistic message that matches
                    bool hasOptimistic = _messageCache[chatId]!.any((msg) =>
                        msg['_optimistic'] == true &&
                        msg['message'] == newMessage['message'] &&
                        msg['send_by'] == newMessage['send_by']);

                    if (!isDuplicate && !hasOptimistic) {
                      // Safe to add new message from real-time update
                      _messageCache[chatId]!.add(newMessage);
                      final messagePreview = newMessage['message'] != null &&
                              newMessage['message'].length > 0
                          ? newMessage['message'].substring(
                              0,
                              newMessage['message'].length > 20
                                  ? 20
                                  : newMessage['message'].length)
                          : '';
                      print('📡 Added real-time message: $messagePreview...');

                      // Emit updated cache
                      if (_messageStreams.containsKey(chatId) &&
                          !_messageStreams[chatId]!.isClosed) {
                        _messageStreams[chatId]!
                            .add(List.from(_messageCache[chatId]!));
                      }

                      // CRITICAL: Send notification for incoming messages
                      final currentUserId = _supabase.auth.currentUser?.id;
                      final senderId = newMessage['send_by'];

                      // Only send notification if this is NOT from current user
                      if (senderId != currentUserId && currentUserId != null) {
                        print(
                            '🔔 Triggering notification for incoming message from $senderId');

                        // Get sender info from chat
                        _getChatDetails(chatId).then((chat) {
                          if (chat != null) {
                            final senderName = chat['sender_id'] == senderId
                                ? chat['sender_name'] ?? 'User'
                                : chat['recipient_name'] ?? 'User';

                            // Send notification and update badge
                            Future.microtask(() async {
                              // Send push notification
                              await PushService.sendChatNotification(
                                recipientUserId: currentUserId,
                                senderName: senderName,
                                message: newMessage['message'] ?? 'New message',
                                messageType:
                                    newMessage['message_type'] ?? 'text',
                                chatId: chatId,
                                senderId: senderId,
                              );

                              // Update badge count
                              await PushService.updateBadgeCount();
                            });
                          }
                        });
                      }
                    } else {
                      final messagePreview = newMessage['message'] != null &&
                              newMessage['message'].length > 0
                          ? newMessage['message'].substring(
                              0,
                              newMessage['message'].length > 20
                                  ? 20
                                  : newMessage['message'].length)
                          : '';
                      print(
                          '📡 Skipped duplicate real-time message: $messagePreview...');
                    }
                  }
                } else if (payload.eventType == PostgresChangeEvent.update) {
                  // Update existing message in cache
                  if (_messageCache.containsKey(chatId)) {
                    int index = _messageCache[chatId]!.indexWhere(
                        (msg) => msg['id'] == payload.newRecord['id']);
                    if (index != -1) {
                      _messageCache[chatId]![index] = payload.newRecord;
                      // Emit updated cache
                      if (_messageStreams.containsKey(chatId) &&
                          !_messageStreams[chatId]!.isClosed) {
                        _messageStreams[chatId]!
                            .add(List.from(_messageCache[chatId]!));
                      }
                    }
                  }
                } else if (payload.eventType == PostgresChangeEvent.delete) {
                  // Remove deleted message from cache
                  if (_messageCache.containsKey(chatId)) {
                    _messageCache[chatId]!.removeWhere(
                        (msg) => msg['id'] == payload.oldRecord['id']);
                    // Emit updated cache
                    if (_messageStreams.containsKey(chatId) &&
                        !_messageStreams[chatId]!.isClosed) {
                      _messageStreams[chatId]!
                          .add(List.from(_messageCache[chatId]!));
                    }
                  }
                }

                // Only update unread indicators if we're not the sender of this message
                // This prevents the sender's badge from increasing when they send messages
                if (payload.eventType == PostgresChangeEvent.insert) {
                  final senderId = payload.newRecord['send_by'];
                  final currentUserId = _supabase.auth.currentUser?.id;

                  // Only update badge if we're not the sender
                  if (senderId != currentUserId) {
                    Future.microtask(() => debouncedUpdateUnreadIndicators());
                  } else {
                    print(
                        '🔴 BADGE: Skipping update for sender\'s own message');
                  }
                } else {
                  // For updates and deletes, always update
                  Future.microtask(() => debouncedUpdateUnreadIndicators());
                }
              },
            )
            .subscribe();
      } catch (e) {
        print('Error setting up real-time subscription: $e');
      }
    }
  }

  // OPTIMIZED: Send message with better performance
  Future<void> sendMessage(
    String chatId,
    Map<String, dynamic> chatMessageData,
  ) async {
    try {
      // Create optimistic message with all required fields
      final timestamp = DateTime.now().toUtc();
      final optimisticId =
          'temp_${timestamp.millisecondsSinceEpoch}_${chatMessageData['message'].hashCode.abs()}';
      final optimisticMessage = {
        'id': optimisticId,
        'chat_id': chatId,
        'message': chatMessageData['message'],
        'send_by': chatMessageData['sendBy'],
        'sender_name': chatMessageData['senderName'],
        'image': chatMessageData['image'],
        'message_type': chatMessageData['messageType'] ?? 'text',
        'time': timestamp.toIso8601String(),
        '_optimistic': true, // Mark as optimistic
        '_optimistic_id': optimisticId, // Unique ID for this optimistic message
        '_timestamp':
            timestamp.millisecondsSinceEpoch, // For duplicate detection
      };

      print(
          '🚀 Adding optimistic message: ${optimisticId.substring(0, 20)}...');

      // Initialize cache if doesn't exist
      if (!_messageCache.containsKey(chatId)) {
        _messageCache[chatId] = [];
        // Also initialize stream if needed
        if (!_messageStreams.containsKey(chatId) ||
            _messageStreams[chatId]!.isClosed) {
          _messageStreams[chatId] =
              StreamController<List<Map<String, dynamic>>>.broadcast();
        }
      }

      // Add to cache immediately for instant display
      _messageCache[chatId]!.add(optimisticMessage);

      // Emit updated cache immediately for instant UI update
      if (_messageStreams.containsKey(chatId) &&
          !_messageStreams[chatId]!.isClosed) {
        _messageStreams[chatId]!.add(List.from(_messageCache[chatId]!));
      }

      // Ensure RLS context is set for the current user
      final senderId = chatMessageData['sendBy'];
      if (senderId != null) {
        // Set context asynchronously to avoid blocking
        RLSHelper.setUserContext(senderId.toString());
      }

      // Quick chat existence check - use cache first to avoid DB call
      bool chatExists = _messageCache.containsKey(chatId) &&
          _messageCache[chatId]!
              .where((msg) => msg['_optimistic'] != true)
              .isNotEmpty;

      // Only check DB if we don't have cached messages
      if (!chatExists) {
        final chatCheck = await _supabase
            .from('chats')
            .select('id')
            .eq('id', chatId)
            .maybeSingle();
        chatExists = chatCheck != null;
      }

      // Prepare data for parallel execution
      final messageTime = DateTime.now().toUtc().toIso8601String();
      final chatUpdateData = {
        'message': chatMessageData['message'],
        'time': messageTime,
        'send_by': chatMessageData['sendBy'],
        'is_messaged': true,
        'message_type': chatMessageData['messageType'] ?? 'text',
      };

      final messageData = {
        'chat_id': chatId,
        'message': chatMessageData['message'],
        'send_by': chatMessageData['sendBy'],
        'sender_name': chatMessageData['senderName'],
        'image': chatMessageData['image'],
        'message_type': chatMessageData['messageType'] ?? 'text',
        'time': messageTime,
      };

      // Execute database operations in parallel for better performance
      late final Map<String, dynamic> insertedMessage;

      if (!chatExists) {
        // Create new chat and insert message in parallel
        final newChatData = {
          'id': chatId,
          'sender_id': chatMessageData['senderId'],
          'send_to_id': chatMessageData['sendToId'],
          'sender_name': chatMessageData['senderName'],
          'send_to_name': chatMessageData['sendToName'],
          'sender_image': chatMessageData['senderImage'],
          'send_to_image': chatMessageData['sendToImage'],
          'user_device_token': chatMessageData['userDeviceToken'],
          'send_to_device_token': chatMessageData['sendToDeviceToken'],
          'listing_id': chatMessageData['listingId'],
          'listing_name': chatMessageData['listingName'],
          'listing_image': chatMessageData['listingImage'],
          'listing_price': chatMessageData['listingPrice'],
          'listing_location': chatMessageData['listingLocation'],
          ...chatUpdateData,
        };

        // Execute both operations in parallel
        final results = await Future.wait<dynamic>([
          _supabase.from('chats').insert(newChatData),
          _supabase.from('messages').insert(messageData).select().single(),
        ]);
        insertedMessage = results[1] as Map<String, dynamic>;
      } else {
        // Update chat and insert message in parallel
        final results = await Future.wait<dynamic>([
          _supabase.from('chats').update(chatUpdateData).eq('id', chatId),
          _supabase.from('messages').insert(messageData).select().single(),
        ]);
        insertedMessage = results[1] as Map<String, dynamic>;
      }

      // Replace optimistic message with real one
      if (_messageCache.containsKey(chatId)) {
        // Find the most recent optimistic message with matching content and sender
        int optimisticIndex = -1;
        for (int i = _messageCache[chatId]!.length - 1; i >= 0; i--) {
          final msg = _messageCache[chatId]![i];
          if (msg['_optimistic'] == true &&
              msg['message'] == chatMessageData['message'] &&
              msg['send_by'] == chatMessageData['sendBy']) {
            optimisticIndex = i;
            print(
                '🔄 Found optimistic message to replace: ${msg['_optimistic_id']}');
            break;
          }
        }

        if (optimisticIndex != -1) {
          // Replace the specific optimistic message with the real one
          _messageCache[chatId]![optimisticIndex] = insertedMessage;
          print(
              '🔄 Replaced optimistic message at index $optimisticIndex with real message');
        } else {
          // If not found, remove all matching optimistic messages and add real message
          _messageCache[chatId]!.removeWhere((msg) =>
              msg['_optimistic'] == true &&
              msg['message'] == chatMessageData['message'] &&
              msg['send_by'] == chatMessageData['sendBy']);
          _messageCache[chatId]!.add(insertedMessage);
          print('🔄 Removed optimistic messages and added real message');
        }

        // Emit updated cache immediately
        if (_messageStreams.containsKey(chatId) &&
            !_messageStreams[chatId]!.isClosed) {
          _messageStreams[chatId]!.add(List.from(_messageCache[chatId]!));
        }
      }

      // Queue operations for background processing
      _queueBackgroundOperations(chatMessageData, chatId);

      // Don't update badge for the sender - they shouldn't see increased badge
      // when they send their own messages
      print('🔴 BADGE: Not updating badge for sender after sending message');

      // Clean up any remaining optimistic messages after a short delay
      Future.delayed(Duration(seconds: 2), () {
        if (_messageCache.containsKey(chatId)) {
          final beforeCount = _messageCache[chatId]!.length;
          _messageCache[chatId]!
              .removeWhere((msg) => msg['_optimistic'] == true);
          final afterCount = _messageCache[chatId]!.length;

          if (beforeCount != afterCount) {
            print(
                '🧩 Cleaned up ${beforeCount - afterCount} lingering optimistic messages');
            // Update stream with cleaned cache
            if (_messageStreams.containsKey(chatId) &&
                !_messageStreams[chatId]!.isClosed) {
              _messageStreams[chatId]!.add(List.from(_messageCache[chatId]!));
            }
          }
        }
      });
    } catch (e) {
      // Remove optimistic message on error
      if (_messageCache.containsKey(chatId)) {
        _messageCache[chatId]!.removeWhere((msg) => msg['_optimistic'] == true);

        // Update UI
        if (_messageStreams.containsKey(chatId) &&
            !_messageStreams[chatId]!.isClosed) {
          _messageStreams[chatId]!.add(List.from(_messageCache[chatId]!));
        }
      }
      rethrow;
    }
  }

  // OPTIMIZED: Send notifications asynchronously
  Future<void> _sendChatNotificationAsync(
      Map<String, dynamic> chatMessageData, String chatId) async {
    try {
      final senderId = chatMessageData['senderId'];
      final sendToId = chatMessageData['sendToId'];

      // Send notification to recipient

      // Don't send notification to yourself
      if (senderId == sendToId) {
        print('🔕 Skipping self-notification');
        return;
      }

      // Send notifications without blocking
      Future.microtask(() async {
        try {
          await Future.wait([
            NotificationManager.instance.showChatNotification(
              chatId: chatId,
              senderId: senderId,
              senderName: chatMessageData['senderName'] ?? 'New Message'.tr,
              message: chatMessageData['message'] ?? 'New message'.tr,
              messageType: chatMessageData['messageType'] ?? 'text',
            ),
            PushService.sendChatNotification(
              recipientUserId: sendToId,
              senderName: chatMessageData['senderName'] ?? 'New Message'.tr,
              message: chatMessageData['message'] ?? 'New message'.tr,
              messageType: chatMessageData['messageType'] ?? 'text',
              chatId: chatId,
              senderId: senderId,
            ),
          ]);
        } catch (e) {
          print('Error sending notifications: $e');
        }
      });
    } catch (e) {
      print('Error sending chat notification: $e');
    }
  }

  // OPTIMIZED: Delete chat with better performance
  Future<void> deleteChat(String chatId) async {
    try {
      // Remove from cache immediately
      _messageCache.remove(chatId);

      // Update UI immediately
      if (_messageStreams.containsKey(chatId)) {
        if (!_messageStreams[chatId]!.isClosed) {
          _messageStreams[chatId]!.add([]);
        }
      }

      // Delete from database
      await _supabase.from('chats').delete().eq('id', chatId);

      // Cancel notifications
      await PushService.cancelChatNotifications(chatId);

      // Cleanup subscriptions
      if (_messageChannels.containsKey(chatId)) {
        await _messageChannels[chatId]?.unsubscribe();
        _messageChannels.remove(chatId);
      }

      if (_messageStreams.containsKey(chatId)) {
        if (!_messageStreams[chatId]!.isClosed) {
          _messageStreams[chatId]!.close();
        }
        _messageStreams.remove(chatId);
      }

      // Refresh chat lists
      refreshAllChatLists();

      // Update badge counts
      await updateBadgeCountFromChats();
      await updateUnreadMessageIndicators();
    } catch (e) {
      print('Error deleting chat: $e');
      rethrow;
    }
  }

  // Get chat details for notifications
  Future<Map<String, dynamic>?> _getChatDetails(String chatId) async {
    try {
      final response =
          await _supabase.from('chats').select('*').eq('id', chatId).single();
      return response;
    } catch (e) {
      print('Error getting chat details: $e');
      return null;
    }
  }

  // OPTIMIZED: Mark chat as read using proper schema
  Future<void> markChatAsRead(String chatId, String userId) async {
    try {
      // Update cache immediately
      if (_messageCache.containsKey(chatId)) {
        for (var msg in _messageCache[chatId]!) {
          if (msg['send_by'] != userId) {
            // Mark as read in cache
            msg['_read_by_user'] = true;
          }
        }
      }

      // Get chat info to determine which read time field to update
      final chat = await _supabase
          .from('chats')
          .select('sender_id, send_to_id')
          .eq('id', chatId)
          .single();

      final now = DateTime.now().toUtc().toIso8601String();
      Map<String, dynamic> updateData = {};

      // Update the appropriate read time field based on user role
      if (chat['sender_id'] == userId) {
        updateData['sender_last_read_time'] = now;
      } else if (chat['send_to_id'] == userId) {
        updateData['recipient_last_read_time'] = now;
      }

      if (updateData.isNotEmpty) {
        await _supabase.from('chats').update(updateData).eq('id', chatId);
      }

      // Update badge count and unread indicators IMMEDIATELY
      await updateBadgeCountFromChats();
      await updateUnreadMessageIndicators();

      // Update PushService badge count for system-level badges
      await PushService.updateBadgeCount();

      // Clear notifications for this chat when marked as read
      await PushService.cancelChatNotifications(chatId);
      print('🧼 Chat marked as read - cleared notifications for: $chatId');

      // Force immediate UI update
      try {
        final authController = Get.find<AuthController>();
        authController.update();
        print('🔴 MARK READ: Forced AuthController update after marking read');
      } catch (e) {
        print('🔴 MARK READ ERROR: Could not force update: $e');
      }
    } catch (e) {
      print('Error marking chat as read: $e');
    }
  }

  // Add method for loading more messages (pagination)
  Future<void> loadMoreMessages(String chatId, {int offset = 0}) async {
    try {
      final response = await _supabase
          .from('messages')
          .select('*')
          .eq('chat_id', chatId)
          .order('time', ascending: false)
          .range(offset, offset + 50);

      var newMessages = List<Map<String, dynamic>>.from(response);
      newMessages = newMessages.reversed.toList();

      // Prepend to cache
      if (_messageCache.containsKey(chatId)) {
        _messageCache[chatId]!.insertAll(0, newMessages);

        // Update stream
        if (_messageStreams.containsKey(chatId) &&
            !_messageStreams[chatId]!.isClosed) {
          _messageStreams[chatId]!.add(List.from(_messageCache[chatId]!));
        }
      }
    } catch (e) {
      print('Error loading more messages: $e');
    }
  }

  // Debounced version of updateUnreadMessageIndicators to prevent multiple calls
  void debouncedUpdateUnreadIndicators() {
    // Cancel any pending update
    _badgeUpdateDebouncer?.cancel();

    // Don't schedule another if one is already pending
    if (_isBadgeUpdatePending) {
      print('🔴 BADGE: Update already pending, skipping duplicate request');
      return;
    }

    _isBadgeUpdatePending = true;

    // Schedule the update with a delay to batch multiple calls
    _badgeUpdateDebouncer = Timer(Duration(milliseconds: 500), () {
      _isBadgeUpdatePending = false;
      updateUnreadMessageIndicators();
    });
  }

  // Update unread message indicators using proper schema
  Future<void> updateUnreadMessageIndicators() async {
    try {
      // Get current user from Supabase auth OR AuthController
      String? userId;
      final user = _supabase.auth.currentUser;
      if (user != null) {
        userId = user.id;
      } else {
        // Try to get user ID from AuthController
        try {
          final authController = Get.find<AuthController>();
          userId = authController.user?.userId?.toString();
        } catch (e) {
          print(
              '🔴 BADGE ERROR: No authenticated user and no AuthController: $e');
        }
      }

      if (userId == null) {
        print('🔴 BADGE ERROR: No user ID found');
        // Set count to 0 when no user
        try {
          final authController = Get.find<AuthController>();
          authController.unreadMessageCount.value = 0;
          authController.hasUnreadMessages.value = false;
          authController.update();
        } catch (e) {}
        return;
      }

      print('🔴 BADGE: Starting unread count calculation for user $userId');

      // Count unread messages by comparing message times with read times
      final chatsQuery = await _supabase
          .from('chats')
          .select(
              'id, sender_id, send_to_id, sender_last_read_time, recipient_last_read_time, time, send_by')
          .or('sender_id.eq.$userId,send_to_id.eq.$userId')
          .order('time', ascending: false);

      int totalUnread = 0;

      for (var chat in chatsQuery) {
        final currentUserId = userId;
        final isUserSender = chat['sender_id'] == currentUserId;
        final lastReadTime = isUserSender
            ? chat['sender_last_read_time']
            : chat['recipient_last_read_time'];
        final lastMessageTime = chat['time'];
        final lastMessageSender = chat['send_by'];

        // Only count as unread if the last message was not sent by current user
        if (lastMessageSender != currentUserId) {
          // If no read time or message is newer than read time, count as unread
          if (lastReadTime == null ||
              (lastMessageTime != null &&
                  DateTime.parse(lastMessageTime)
                      .isAfter(DateTime.parse(lastReadTime)))) {
            // Count actual unread messages for this chat
            final unreadMessages = await _supabase
                .from('messages')
                .select('id')
                .eq('chat_id', chat['id'])
                .neq('send_by', currentUserId)
                .gt('time', lastReadTime ?? '1970-01-01T00:00:00Z');

            totalUnread += unreadMessages.length;
            print(
                '🔴 CHAT ${chat['id']}: Found ${unreadMessages.length} unread messages');
          }
        }
      }

      print('Unread messages count: $totalUnread');

      // Update AuthController with the count - FORCE UPDATE
      try {
        // Use Get.find first, but fallback to Get.put to ensure we get the right instance
        AuthController authController;
        try {
          authController = Get.find<AuthController>();
        } catch (e) {
          authController = Get.put(AuthController());
        }

        // Force update with logging
        print(
            '🔴 BEFORE UPDATE: AuthController unread = ${authController.unreadMessageCount.value}');
        authController.unreadMessageCount.value = totalUnread;
        authController.hasUnreadMessages.value = totalUnread > 0;
        authController.update(); // Force UI update
        print('🔴 AFTER UPDATE: Set unread count to $totalUnread');
        print(
            '🔴 AFTER UPDATE: AuthController unread = ${authController.unreadMessageCount.value}');
        print(
            '🔴 AFTER UPDATE: hasUnread = ${authController.hasUnreadMessages.value}');

        // Also update the app icon badge count via PushService
        await PushService.updateBadgeCount();
        print('📱 Updated app icon badge count to $totalUnread');
      } catch (e) {
        print('🔴 BADGE FATAL ERROR: Could not update AuthController: $e');
      }
    } catch (e) {
      print('Error updating unread indicators: $e');
    }
  }

  Future<void> updateBadgeCountFromChats() async {
    try {
      await updateUnreadMessageIndicators();
    } catch (e) {
      print('Error updating badge count: $e');
    }
  }

  // Test Supabase connection
  Future<bool> testSupabaseConnection() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        print('Supabase connected with session');
      }

      await _supabase.from('chats').select('count').limit(1);
      print('Connection test successful');

      return true;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  // Set user online status using proper schema
  Future<void> setUserOnline(String userId) async {
    try {
      await _supabase.from('user_presence').upsert({
        'user_id': userId,
        'is_online': true,
        'last_active_time': DateTime.now().toUtc().toIso8601String(),
      }).eq('user_id', userId);
    } catch (e) {
      print('Error setting user online: $e');
    }
  }

  // Set user offline status using proper schema
  Future<void> setUserOffline(String userId) async {
    try {
      await _supabase.from('user_presence').upsert({
        'user_id': userId,
        'is_online': false,
        'last_active_time': DateTime.now().toUtc().toIso8601String(),
      }).eq('user_id', userId);
    } catch (e) {
      print('Error setting user offline: $e');
    }
  }

  // Start listening for chat updates
  void startListeningForChatUpdates() {
    // Already handled in getAllChats and message subscriptions
    print(
        '✅ Chat update listeners already active (${_globalChatRefreshCallbacks.length} streams)');
  }

  // Force reconnect all realtime subscriptions
  void reconnectRealtimeSubscriptions() {
    print('🔄 Reconnecting all realtime subscriptions...');

    // Unsubscribe from existing subscriptions
    _chatChannel?.unsubscribe();
    _messagesChannel?.unsubscribe();
    for (var channel in _messageChannels.values) {
      channel.unsubscribe();
    }
    _messageChannels.clear();

    // Force refresh all chat lists which will recreate subscriptions
    refreshAllChatLists();

    // Also refresh all active message streams
    refreshAllMessageStreams();

    print('✅ Realtime subscriptions reconnected');
  }

  // Method to refresh all active message streams (for individual chats)
  void refreshAllMessageStreams() {
    print('🔄 Refreshing ${_messageStreams.length} active message streams');

    for (final chatId in _messageStreams.keys.toList()) {
      if (!_messageStreams[chatId]!.isClosed) {
        print('🔄 Refreshing messages for chat: $chatId');

        // Force reload messages from database
        _loadMessagesForChat(chatId, useCache: false);

        // Recreate realtime subscription
        if (_messageChannels.containsKey(chatId)) {
          _messageChannels[chatId]?.unsubscribe();
          _messageChannels.remove(chatId);
        }
        _setupRealtimeSubscription(chatId);
      }
    }
  }

  // Method to refresh a specific chat's messages (for when you're inside a chat)
  void refreshChatMessages(String chatId) {
    print('🔄 Refreshing messages for specific chat: $chatId');

    if (_messageStreams.containsKey(chatId) &&
        !_messageStreams[chatId]!.isClosed) {
      // Force reload messages from database
      _loadMessagesForChat(chatId, useCache: false);

      // Ensure realtime subscription is active
      if (!_messageChannels.containsKey(chatId)) {
        _setupRealtimeSubscription(chatId);
      }
    }
  }

  // Stop listening for chat updates
  void stopListeningForChatUpdates() {
    _chatChannel?.unsubscribe();
    _messagesChannel?.unsubscribe();
    for (var channel in _messageChannels.values) {
      channel.unsubscribe();
    }
    print('Stopped listening for chat updates');
  }

  // Update device token using proper schema
  Future<void> updateDeviceTokenInChat(
      String userId, String deviceToken) async {
    try {
      // Update or insert device token in device_tokens table
      await _supabase.from('device_tokens').upsert({
        'user_id': userId,
        'device_token': deviceToken,
        'platform': 'android', // or detect platform
        'is_active': true,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });

      // Also update existing chat records for backward compatibility
      Future.wait([
        _supabase
            .from('chats')
            .update({'user_device_token': deviceToken}).eq('sender_id', userId),
        _supabase.from('chats').update(
            {'send_to_device_token': deviceToken}).eq('send_to_id', userId),
      ]);
    } catch (e) {
      print('Error updating device token: $e');
    }
  }

  // Get user presence using proper schema
  Future<Map<String, dynamic>> getUserPresence(String userId) async {
    try {
      final response = await _supabase
          .from('user_presence')
          .select('is_online, last_active_time')
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        return {
          'is_online': response['is_online'] ?? false,
          'last_active': response['last_active_time']
        };
      }

      // If no presence record, assume offline
      return {'is_online': false, 'last_active': null};
    } catch (e) {
      print('Error getting user presence: $e');
      return {'is_online': false, 'last_active': null};
    }
  }

  // Check if user is online
  bool isUserOnline(Map<String, dynamic> presence) {
    if (presence['is_online'] == true) {
      return true;
    }

    // Check last active time - consider online if active within last 5 minutes
    if (presence['last_active'] != null) {
      try {
        final lastActive = DateTime.parse(presence['last_active']);
        final now = DateTime.now().toUtc();
        final difference = now.difference(lastActive);
        return difference.inMinutes < 5;
      } catch (e) {
        return false;
      }
    }

    return false;
  }

  // Format last active time with proper translations
  String formatLastActiveTime(DateTime? lastActive) {
    if (lastActive == null) return 'Offline'.tr;

    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference.inMinutes < 1) {
      return 'Just now'.tr;
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${'min ago'.tr}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${'hours ago'.tr}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${'days ago'.tr}';
    } else {
      return 'Offline'.tr;
    }
  }

  // Queue background operations for batch processing
  void _queueBackgroundOperations(
      Map<String, dynamic> chatMessageData, String chatId) {
    // Add to queue
    _messageQueue.add({
      'type': 'notification',
      'data': chatMessageData,
      'chatId': chatId,
      'timestamp': DateTime.now(),
    });

    // Process queue with debouncing
    _messageQueueTimer?.cancel();
    _messageQueueTimer = Timer(Duration(milliseconds: 100), () {
      _processMessageQueue();
    });
  }

  // Process queued background operations
  Future<void> _processMessageQueue() async {
    if (_isProcessingQueue || _messageQueue.isEmpty) return;

    _isProcessingQueue = true;
    final queue = List.from(_messageQueue);
    _messageQueue.clear();

    try {
      // Process notifications in batch
      final notificationTasks = <Future>[];

      for (var item in queue) {
        if (item['type'] == 'notification') {
          notificationTasks
              .add(_sendChatNotificationAsync(item['data'], item['chatId']));
        }
      }

      // Execute all tasks in parallel
      if (notificationTasks.isNotEmpty) {
        await Future.wait(notificationTasks, eagerError: false);
      }

      // Update indicators once after all operations (debounced)
      debouncedUpdateUnreadIndicators();
      refreshAllChatLists();
    } catch (e) {
      print('Error processing message queue: $e');
    } finally {
      _isProcessingQueue = false;
    }
  }

  // Check if chat has unread messages using proper schema
  Future<bool> hasUnreadMessages(String chatId, String userId) async {
    try {
      // Get chat info and read times
      final chat = await _supabase
          .from('chats')
          .select(
              'sender_id, send_to_id, sender_last_read_time, recipient_last_read_time')
          .eq('id', chatId)
          .single();

      final isUserSender = chat['sender_id'] == userId;
      final lastReadTime = isUserSender
          ? chat['sender_last_read_time']
          : chat['recipient_last_read_time'];

      // Count messages sent by others after last read time
      final unreadMessages = await _supabase
          .from('messages')
          .select('id')
          .eq('chat_id', chatId)
          .neq('send_by', userId)
          .gt('time', lastReadTime ?? '1970-01-01T00:00:00Z')
          .limit(1);

      return unreadMessages.isNotEmpty;
    } catch (e) {
      print('Error checking unread messages: $e');
      return false;
    }
  }

  // Start connection keep-alive for instant messaging
  void _startConnectionKeepAlive() {
    _connectionKeepAliveTimer?.cancel();
    _connectionKeepAliveTimer = Timer.periodic(Duration(seconds: 30), (_) {
      _maintainConnection();
    });
  }

  // Maintain active connection to Supabase
  Future<void> _maintainConnection() async {
    try {
      final now = DateTime.now();
      // Only ping if last check was more than 25 seconds ago
      if (_lastConnectionCheck == null ||
          now.difference(_lastConnectionCheck!).inSeconds > 25) {
        _lastConnectionCheck = now;

        // Simple lightweight query to keep connection warm
        await _supabase
            .from('chats')
            .select('id')
            .limit(1)
            .timeout(Duration(seconds: 5));
      }
    } catch (e) {
      // Silently ignore keep-alive errors
    }
  }

  // Pre-warm chat data for faster loading
  Future<void> prewarmChatData(String chatId) async {
    if (!_messageCache.containsKey(chatId)) {
      // Pre-load messages in background
      Future.microtask(() => _loadMessagesForChat(chatId));
    }

    // Ensure subscription is set up
    if (!_messageChannels.containsKey(chatId)) {
      _setupRealtimeSubscription(chatId);
    }
  }

  // Emergency method to force badge display for testing
  void forceShowBadge({int count = 3}) {
    try {
      final authController = Get.find<AuthController>();
      authController.unreadMessageCount.value = count;
      authController.hasUnreadMessages.value = count > 0;
      authController.update();
      print('🔴 EMERGENCY BADGE: Forced badge to show count $count');
    } catch (e) {
      print('🔴 EMERGENCY BADGE ERROR: $e');
      try {
        final authController = Get.put(AuthController());
        authController.unreadMessageCount.value = count;
        authController.hasUnreadMessages.value = count > 0;
        authController.update();
        print(
            '🔴 EMERGENCY BADGE: Created controller and forced badge to $count');
      } catch (e2) {
        print('🔴 EMERGENCY BADGE FATAL ERROR: $e2');
      }
    }
  }

  // Upload image to Supabase storage
  Future<String?> uploadImage(File imageFile) async {
    try {
      final fileName = 'chat_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final bytes = await imageFile.readAsBytes();

      await _supabase.storage.from('chat-images').uploadBinary(fileName, bytes);

      // Get public URL
      final publicUrl =
          _supabase.storage.from('chat-images').getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}
