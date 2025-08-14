import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/Services/RealPush/supabase_push_service.dart';
import 'package:venta_cuba/Services/Supabase/supabase_service.dart';
import 'package:venta_cuba/Services/Supabase/rls_helper.dart';

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

  // Getter for Supabase client
  SupabaseClient get supabaseClient => _supabase;

  // Debug method to test Supabase connection and authentication
  Future<bool> testSupabaseConnection() async {
    try {
      print('💬 🔥 Testing Supabase connection and authentication...');

      // Test 1: Check if client is initialized
      print('💬 🔥 Supabase client initialized: ${_supabase.runtimeType}');

      // Test 2: Check authentication
      final session = _supabase.auth.currentSession;
      print('💬 🔥 Current session: ${session != null ? 'EXISTS' : 'NULL'}');
      if (session != null) {
        print('💬 🔥 User ID: ${session.user.id}');
        print('💬 🔥 Session expires: ${session.expiresAt}');
      }

      // Test 3: Try a simple query
      final testQuery = await _supabase.from('chats').select('count').limit(1);
      print('💬 🔥 Test query result: $testQuery');

      // Test 4: Check messages table
      final messageCount =
          await _supabase.from('messages').select('count').limit(1);
      print('💬 🔥 Messages table test: $messageCount');

      print('💬 ✅ Supabase connection test passed!');
      return true;
    } catch (e, stackTrace) {
      print('💬 ❌ Supabase connection test failed: $e');
      print('💬 ❌ Stack trace: $stackTrace');
      return false;
    }
  }

  // Message streams cache
  final Map<String, StreamController<List<Map<String, dynamic>>>>
      _messageStreams = {};

  // Realtime subscriptions
  RealtimeChannel? _chatChannel;
  RealtimeChannel? _messagesChannel;
  final Map<String, RealtimeChannel> _messageChannels = {};

  @override
  void onClose() {
    print(
        '💬 🔥 SupabaseChatController onClose called - cleaning up resources');

    // Clean up subscriptions
    _chatChannel?.unsubscribe();
    _messagesChannel?.unsubscribe();
    for (var channel in _messageChannels.values) {
      channel.unsubscribe();
    }

    // Clean up stream controllers
    for (var entry in _messageStreams.entries) {
      print('💬 🔥 Closing stream controller for chat: ${entry.key}');
      if (!entry.value.isClosed) {
        entry.value.close();
      }
    }
    _messageStreams.clear();

    super.onClose();
  }

  // Method to clear specific chat stream (for testing/debugging)
  void clearChatStream(String chatId) {
    if (_messageStreams.containsKey(chatId)) {
      print('💬 🔥 Manually clearing stream for chat: $chatId');
      if (!_messageStreams[chatId]!.isClosed) {
        _messageStreams[chatId]!.close();
      }
      _messageStreams.remove(chatId);
    }

    if (_messageChannels.containsKey(chatId)) {
      print('💬 🔥 Manually clearing channel for chat: $chatId');
      _messageChannels[chatId]?.unsubscribe();
      _messageChannels.remove(chatId);
    }
  }

  // Get all chats for the current user (where they are sender OR receiver)
  Stream<List<Map<String, dynamic>>> getAllChats(String userId) {
    print('💬 Getting all chats for user: $userId');

    // Use a custom stream controller to manually manage the combined data
    final StreamController<List<Map<String, dynamic>>> controller =
        StreamController<List<Map<String, dynamic>>>.broadcast();

    // Function to combine and emit chat data
    void combineAndEmitChats() async {
      try {
        // Fetch both sender and receiver chats
        final senderChats =
            await _supabase.from('chats').select().eq('sender_id', userId);

        final receiverChats =
            await _supabase.from('chats').select().eq('send_to_id', userId);

        // Combine and deduplicate
        final Map<String, Map<String, dynamic>> uniqueChats = {};

        for (var chat in senderChats) {
          uniqueChats[chat['id']] = chat;
        }

        for (var chat in receiverChats) {
          uniqueChats[chat['id']] = chat;
        }

        final result = uniqueChats.values.toList();
        result.sort((a, b) =>
            DateTime.parse(b['time']).compareTo(DateTime.parse(a['time'])));

        print(
            '💬 📱 Combined: ${senderChats.length} sender + ${receiverChats.length} receiver = ${result.length} total chats for user $userId');
        for (var chat in result) {
          print(
              '💬 Chat: ${chat['id']} - Sender: ${chat['sender_id']} - Receiver: ${chat['send_to_id']}');
        }

        controller.add(result);
      } catch (e) {
        print('❌ Error combining chats: $e');
        controller.addError(e);
      }
    }

    // Initial load
    combineAndEmitChats();

    // Set up real-time listeners for both sender and receiver chats
    final senderChannel = _supabase
        .channel('user_sender_chats_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'chats',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'sender_id',
            value: userId,
          ),
          callback: (payload) {
            print('🔔 Sender chat changed for user $userId');
            combineAndEmitChats();
          },
        )
        .subscribe();

    final receiverChannel = _supabase
        .channel('user_receiver_chats_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'chats',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'send_to_id',
            value: userId,
          ),
          callback: (payload) {
            print('🔔 Receiver chat changed for user $userId');
            combineAndEmitChats();
          },
        )
        .subscribe();

    // Clean up when controller is closed
    controller.onCancel = () {
      senderChannel.unsubscribe();
      receiverChannel.unsubscribe();
    };

    return controller.stream;
  }

  // Get messages for a specific chat
  Stream<List<Map<String, dynamic>>> getChatMessages(String chatId) {
    print('💬 🔥 getChatMessages called for chat: $chatId');

    // Validate chat ID
    if (chatId.isEmpty || chatId == 'null') {
      print('💬 ❌ Invalid chat ID: $chatId');
      // Return a stream with empty data
      return Stream.value(<Map<String, dynamic>>[]);
    }

    // Create or get existing stream controller for this chat
    if (!_messageStreams.containsKey(chatId) ||
        _messageStreams[chatId]!.isClosed) {
      print('💬 🔥 Creating new stream controller for chat: $chatId');
      _messageStreams[chatId] =
          StreamController<List<Map<String, dynamic>>>.broadcast();

      // Set up real-time subscription first
      _setupRealtimeSubscription(chatId);
      
      // Load initial data only when creating new stream
      _loadMessagesForChat(chatId).catchError((error) {
        print('💬 ❌ Error in initial data load: $error');
        // Add empty data to prevent infinite loading
        if (_messageStreams.containsKey(chatId) &&
            !_messageStreams[chatId]!.isClosed) {
          _messageStreams[chatId]!.add(<Map<String, dynamic>>[]);
        }
      });
    } else {
      print('💬 🔥 Using existing real-time stream for chat: $chatId');
      // Still set up subscription if it doesn't exist (in case it was lost)
      if (!_messageChannels.containsKey(chatId)) {
        print('💬 🔥 Re-setting up real-time subscription for existing stream');
        _setupRealtimeSubscription(chatId);
      }
    }

    return _messageStreams[chatId]!.stream;
  }

  // Load messages from database
  Future<void> _loadMessagesForChat(String chatId) async {
    print('💬 🔥 _loadMessagesForChat called for chat: $chatId');

    try {
      // Skip connection test for faster loading - we'll handle errors as they come
      print('💬 🔥 Loading messages directly from database...');

      print('💬 🔄 Loading messages from database for chat: $chatId');

      // Try to load messages with comprehensive error handling
      final response = await _supabase
          .from('messages')
          .select('*')
          .eq('chat_id', chatId)
          .order('time', ascending: true);

      print('💬 🔥 Raw response from database: $response');
      print('💬 🔥 Response type: ${response.runtimeType}');

      final messages = List<Map<String, dynamic>>.from(response);

      print(
          '💬 📊 Loaded ${messages.length} messages from database for chat: $chatId');

      // Debug: Log each message
      for (int i = 0; i < messages.length && i < 5; i++) {
        var msg = messages[i];
        print(
            '💬 Message $i: ${msg['message']} by ${msg['send_by']} at ${msg['time']} type: ${msg['message_type']}');
      }

      // If no messages found, check if chat exists and sample database
      if (messages.isEmpty) {
        print('💬 🔍 No messages found for chat $chatId, investigating...');

        // Check if chat exists
        try {
          final chatExists = await _supabase
              .from('chats')
              .select('id')
              .eq('id', chatId)
              .maybeSingle();
          print(
              '💬 🔍 Chat exists in database: ${chatExists != null ? 'YES' : 'NO'}');
        } catch (e) {
          print('💬 ❌ Error checking chat existence: $e');
        }

        // Sample all messages in database
        try {
          final allMessages = await _supabase
              .from('messages')
              .select('chat_id, message, send_by')
              .limit(10);
          print('💬 🔍 Sample messages in database: ${allMessages.length}');
          for (var msg in allMessages) {
            print(
                '💬 Sample: chat_id=${msg['chat_id']}, message=${msg['message']}, sender=${msg['send_by']}');
          }
        } catch (e) {
          print('💬 ❌ Error getting sample messages: $e');
        }
      }

      // CRITICAL: Always add data to stream, even if empty
      if (_messageStreams.containsKey(chatId) &&
          !_messageStreams[chatId]!.isClosed) {
        print(
            '💬 🔥 Adding ${messages.length} messages to stream for chat: $chatId');
        _messageStreams[chatId]!.add(messages);
        print('💬 ✅ Messages successfully added to stream for chat: $chatId');
      } else {
        print('💬 ❌ Stream controller issue for chat: $chatId');
        print('💬 Stream exists: ${_messageStreams.containsKey(chatId)}');
        if (_messageStreams.containsKey(chatId)) {
          print('💬 Stream closed: ${_messageStreams[chatId]!.isClosed}');
        }
      }
    } catch (e, stackTrace) {
      print('❌ CRITICAL ERROR loading messages for chat $chatId: $e');
      print('❌ Stack trace: $stackTrace');

      // CRITICAL: Add empty data to prevent infinite loading
      if (_messageStreams.containsKey(chatId) &&
          !_messageStreams[chatId]!.isClosed) {
        print('💬 🔥 Adding empty data due to error');
        _messageStreams[chatId]!.add(<Map<String, dynamic>>[]);
      }

      // Re-throw so calling code can handle
      rethrow;
    }
  }

  // Set up real-time subscription for a chat
  void _setupRealtimeSubscription(String chatId) {
    if (!_messageChannels.containsKey(chatId)) {
      print('💬 Setting up real-time subscription for chat: $chatId');

      try {
        _messageChannels[chatId] = _supabase
            .channel('messages_$chatId')
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
                print('🔔 Real-time change detected for chat $chatId');
                print('🔔 Event: ${payload.eventType}');
                print('🔔 Payload: $payload');

                // ALWAYS reload on any change to ensure real-time updates work
                print('🔄 Reloading messages for real-time update...');
                _loadMessagesForChat(chatId);

                // Update unread indicators
                updateUnreadMessageIndicators();
              },
            )
            .subscribe();
            
        print('✅ Real-time subscription created for chat: $chatId');
        
      } catch (e) {
        print('❌ Error setting up real-time subscription: $e');
      }
    }
  }
  
  // Removed polling fallback - real-time is working now

  // Removed manual refresh - using real-time subscription only

  // Send a message
  Future<void> sendMessage(
    String chatId,
    Map<String, dynamic> chatMessageData,
  ) async {
    try {
      print('💬 Sending message to chat: $chatId');
      
      // Ensure RLS context is set for the current user
      final senderId = chatMessageData['sendBy'];
      if (senderId != null) {
        await RLSHelper.setUserContext(senderId.toString());
      }

      // First, ensure the chat exists before inserting the message
      final chatExists = await _supabase
          .from('chats')
          .select('id')
          .eq('id', chatId)
          .maybeSingle();

      final chatUpdateData = {
        'message': chatMessageData['message'],
        'time': DateTime.now().toUtc().toIso8601String(), // Explicitly use UTC
        'send_by': chatMessageData['sendBy'],
        'is_messaged': true,
        'message_type': chatMessageData['messageType'] ?? 'text',
      };

      if (chatExists == null) {
        // Create new chat first
        print('💬 Creating new chat: $chatId');
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
          ...chatUpdateData,
        };

        await _supabase.from('chats').insert(newChatData);
        print('💬 ✅ New chat created successfully');
      } else {
        // Update existing chat
        print('💬 Updating existing chat: $chatId');
        await _supabase.from('chats').update(chatUpdateData).eq('id', chatId);
      }

      // Now add the message to messages table
      final messageData = {
        'chat_id': chatId,
        'message': chatMessageData['message'],
        'send_by': chatMessageData['sendBy'],
        'sender_name': chatMessageData['senderName'],
        'image': chatMessageData['image'],
        'message_type': chatMessageData['messageType'] ?? 'text',
        'time': DateTime.now().toUtc().toIso8601String(), // Explicitly use UTC
      };

      print('💬 Inserting message into messages table...');
      print('💬 Message type: ${messageData['message_type']}');
      print('💬 Message content: ${messageData['message']}');
      await _supabase.from('messages').insert(messageData);
      print('💬 ✅ Message inserted successfully');

      // Real-time subscription will automatically update the stream
      // No need to manually refresh - Supabase real-time handles this

      // Send ntfy notification to recipient
      // Add chatId to the notification data
      final notificationData = Map<String, dynamic>.from(chatMessageData);
      notificationData['chatId'] = chatId;
      await _sendChatNotification(notificationData);

      // Update unread count after sending message
      Future.delayed(const Duration(milliseconds: 500), () {
        updateUnreadMessageIndicators();
      });

      print('✅ Message sent successfully');
    } catch (e) {
      print('❌ Error sending message: $e');
      rethrow;
    }
  }

  // Send ntfy notification for chat message
  Future<void> _sendChatNotification(
      Map<String, dynamic> chatMessageData) async {
    try {
      final senderId = chatMessageData['senderId'];
      final sendToId = chatMessageData['sendToId'];

      // Don't send notification to yourself
      if (senderId == sendToId) {
        print('💬 🚨 Not sending notification to yourself');
        return;
      }

      // Send notification to recipient user via Supabase
      final chatIdForNotification = chatMessageData['chatId'] ?? '';
      print('💬 🔴 Sending notification with chatId: "$chatIdForNotification"');
      
      await SupabasePushService.sendChatNotification(
        recipientUserId: sendToId,
        senderName: chatMessageData['senderName'] ?? 'New Message'.tr,
        message: chatMessageData['message'] ?? 'New message'.tr,
        messageType: chatMessageData['messageType'] ?? 'text',
        chatId: chatIdForNotification,
      );

      print('💬 ✅ Supabase push notification sent to user: $sendToId');
    } catch (e) {
      print('💬 ❌ Error sending chat notification: $e');
    }
  }

  // Delete a chat and all its messages
  Future<void> deleteChat(String chatId) async {
    try {
      // Messages will be automatically deleted due to CASCADE
      await _supabase.from('chats').delete().eq('id', chatId);

      // Unsubscribe from this chat's channel
      if (_messageChannels.containsKey(chatId)) {
        await _messageChannels[chatId]?.unsubscribe();
        _messageChannels.remove(chatId);
      }

      print('✅ Chat deleted successfully');
    } catch (e) {
      print('❌ Error deleting chat: $e');
      rethrow;
    }
  }

  // Mark chat as read
  Future<void> markChatAsRead(String chatId, String userId) async {
    try {
      print('💬 🔄 Marking chat as read: $chatId for user $userId');

      final chat = await _supabase
          .from('chats')
          .select(
              'sender_id, send_to_id, sender_last_read_time, recipient_last_read_time')
          .eq('id', chatId)
          .single();

      print(
          '💬 Chat before update: sender_id=${chat['sender_id']}, send_to_id=${chat['send_to_id']}');
      print(
          '💬 Previous read times: sender=${chat['sender_last_read_time']}, recipient=${chat['recipient_last_read_time']}');

      Map<String, dynamic> updateData = {};
      String currentTime = DateTime.now().toUtc().toIso8601String(); // Use UTC

      if (chat['sender_id'] == userId) {
        updateData['sender_last_read_time'] = currentTime;
        print('💬 Updating sender_last_read_time to: $currentTime');
      } else if (chat['send_to_id'] == userId) {
        updateData['recipient_last_read_time'] = currentTime;
        print('💬 Updating recipient_last_read_time to: $currentTime');
      }

      if (updateData.isNotEmpty) {
        await _supabase.from('chats').update(updateData).eq('id', chatId);

        print('✅ Chat marked as read successfully');

        // Verify the update worked
        final updatedChat = await _supabase
            .from('chats')
            .select('sender_last_read_time, recipient_last_read_time')
            .eq('id', chatId)
            .single();
        print(
            '💬 After update read times: sender=${updatedChat['sender_last_read_time']}, recipient=${updatedChat['recipient_last_read_time']}');

        // Update badge count and UI indicators
        await updateBadgeCountFromChats();
        await updateUnreadMessageIndicators();
        
        // Trigger UI refresh for chat list
        update();
      } else {
        print(
            '💬 ⚠️ User $userId is neither sender nor receiver for chat $chatId');
      }
    } catch (e) {
      print('❌ Error marking chat as read: $e');
    }
  }

  // Update badge count based on unread messages
  Future<void> updateBadgeCountFromChats() async {
    try {
      print('💬 📱 🔄 Starting badge count update...');
      final authCont = Get.find<AuthController>();
      if (authCont.user?.userId == null) {
        print('💬 📱 ❌ No user found, skipping badge count update');
        return;
      }

      String currentUserId = authCont.user!.userId.toString();
      int unreadMessageCount = 0;
      print('💬 📱 Current user ID: $currentUserId');

      // Get all chats for this user (sender and receiver)
      final senderChats =
          await _supabase.from('chats').select().eq('sender_id', currentUserId);

      final receiverChats = await _supabase
          .from('chats')
          .select()
          .eq('send_to_id', currentUserId);

      // Combine and deduplicate
      final Map<String, Map<String, dynamic>> uniqueChats = {};

      for (var chat in senderChats) {
        uniqueChats[chat['id']] = chat;
      }

      for (var chat in receiverChats) {
        uniqueChats[chat['id']] = chat;
      }

      final chats = uniqueChats.values.toList();

      print('💬 📱 Found ${chats.length} total chats for badge calculation');
      print(
          '💬 📱 Sender chats: ${senderChats.length}, Receiver chats: ${receiverChats.length}');

      for (var chat in chats) {
        print(
            '💬 📱 Checking chat ${chat['id']}: is_messaged=${chat['is_messaged']}');
        if (chat['is_messaged'] == true) {
          int chatUnreadCount = await countUnreadMessagesInChat(
            chat['id'],
            currentUserId,
          );
          print('💬 📱 Chat ${chat['id']}: $chatUnreadCount unread messages');
          unreadMessageCount += chatUnreadCount;
        } else {
          print('💬 📱 Chat ${chat['id']}: Skipping (is_messaged=false)');
        }
      }

      print('💬 📱 📊 Total unread messages calculated: $unreadMessageCount');

      // Update badge count (using flutter_local_notifications)
      // await FirebaseMessagingService.setBadgeCount(unreadMessageCount);
      // Note: Badge count will be handled by local notifications
      authCont.unreadMessageCount.value = unreadMessageCount;
      authCont.hasUnreadMessages.value = unreadMessageCount > 0;
      authCont.update();

      print('✅ Badge count updated to: $unreadMessageCount');
    } catch (e) {
      print('❌ Error updating badge count: $e');
    }
  }

  // Count unread messages in a specific chat
  Future<int> countUnreadMessagesInChat(
      String chatId, String currentUserId) async {
    try {
      final chat =
          await _supabase.from('chats').select().eq('id', chatId).single();

      print(
          '💬 🔍 Checking unread messages for chat $chatId, user $currentUserId');
      print(
          '💬 Chat sender_id: ${chat['sender_id']}, send_to_id: ${chat['send_to_id']}');

      DateTime? lastReadTime;
      if (chat['sender_id'] == currentUserId) {
        lastReadTime = chat['sender_last_read_time'] != null
            ? DateTime.parse(chat['sender_last_read_time'])
            : null;
        print('💬 User is sender, last read time: $lastReadTime');
      } else if (chat['send_to_id'] == currentUserId) {
        lastReadTime = chat['recipient_last_read_time'] != null
            ? DateTime.parse(chat['recipient_last_read_time'])
            : null;
        print('💬 User is receiver, last read time: $lastReadTime');
      }

      // Get messages count - enhanced approach with proper datetime handling
      List<Map<String, dynamic>> result;

      if (lastReadTime != null) {
        // Use proper timestamp comparison
        String lastReadTimeIso = lastReadTime.toIso8601String();
        print('💬 Looking for messages after: $lastReadTimeIso');

        result = await _supabase
            .from('messages')
            .select('id, time, send_by')
            .eq('chat_id', chatId)
            .neq('send_by', currentUserId)
            .gt('time', lastReadTimeIso)
            .order('time', ascending: false);
      } else {
        print(
            '💬 No last read time found, counting all messages not sent by user');

        result = await _supabase
            .from('messages')
            .select('id, time, send_by')
            .eq('chat_id', chatId)
            .neq('send_by', currentUserId)
            .order('time', ascending: false);
      }
      print('💬 Found ${result.length} unread messages in chat $chatId');

      // Debug: show the unread messages with detailed comparison
      for (var msg in result) {
        DateTime msgTime = DateTime.parse(msg['time']);
        String comparison = lastReadTime != null
            ? (msgTime.isAfter(lastReadTime) ? 'AFTER' : 'BEFORE/EQUAL')
            : 'NO_READ_TIME';
        print(
            '💬 Unread message: ${msg['time']} by ${msg['send_by']} ($comparison last read)');
      }

      // Additional check: manually filter messages that are truly after lastReadTime
      if (lastReadTime != null) {
        final manualCount = result.where((msg) {
          try {
            DateTime msgTime = DateTime.parse(msg['time']);
            return msgTime.isAfter(lastReadTime!);
          } catch (e) {
            print('💬 ❌ Error parsing message time: ${msg['time']}');
            return false;
          }
        }).length;
        print('💬 Manual count of messages after last read: $manualCount');
        return manualCount;
      }

      return result.length;
    } catch (e) {
      print('❌ Error counting unread messages: $e');
      return 0;
    }
  }

  // Check if chat has unread messages
  bool hasUnreadMessages(Map<String, dynamic> chatData, String currentUserId) {
    try {
      String? lastMessageSendBy = chatData['send_by'];
      DateTime? lastMessageTime =
          chatData['time'] != null ? DateTime.parse(chatData['time']) : null;

      if (lastMessageTime == null || lastMessageSendBy == currentUserId) {
        return false;
      }

      DateTime? lastReadTime;
      if (chatData['sender_id'] == currentUserId) {
        lastReadTime = chatData['sender_last_read_time'] != null
            ? DateTime.parse(chatData['sender_last_read_time'])
            : null;
      } else if (chatData['send_to_id'] == currentUserId) {
        lastReadTime = chatData['recipient_last_read_time'] != null
            ? DateTime.parse(chatData['recipient_last_read_time'])
            : null;
      }

      if (lastReadTime == null) return true;

      return lastMessageTime.isAfter(lastReadTime);
    } catch (e) {
      print('❌ Error checking unread status: $e');
      return false;
    }
  }

  // User presence management
  Future<void> updateUserPresence(String userId, bool isOnline) async {
    try {
      final data = {
        'user_id': userId,
        'is_online': isOnline,
        'last_active_time': DateTime.now().toUtc().toIso8601String(), // Use UTC
      };

      await _supabase.from('user_presence').upsert(data, onConflict: 'user_id');

      print('✅ User presence updated: $userId - Online: $isOnline');
    } catch (e) {
      print('❌ Error updating user presence: $e');
    }
  }

  // Get user presence stream
  Stream<Map<String, dynamic>?> getUserPresence(String userId) {
    return _supabase
        .from('user_presence')
        .stream(primaryKey: ['user_id'])
        .eq('user_id', userId)
        .map((data) => data.isNotEmpty ? data.first : null);
  }

  // Set user online
  Future<void> setUserOnline(String userId) async {
    await updateUserPresence(userId, true);
  }

  // Set user offline
  Future<void> setUserOffline(String userId) async {
    await updateUserPresence(userId, false);
  }

  // Update unread message indicators
  Future<void> updateUnreadMessageIndicators() async {
    await updateBadgeCountFromChats();
  }

  // Start listening for chat updates
  void startListeningForChatUpdates() {
    try {
      final authCont = Get.find<AuthController>();
      if (authCont.user?.userId == null) return;

      String userId = authCont.user!.userId.toString();

      // Stop existing listeners
      stopListeningForChatUpdates();

      // Listen for chat changes
      _chatChannel = _supabase
          .channel('chats:$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'chats',
            callback: (payload) {
              print('🔔 Chat change detected');
              updateBadgeCountFromChats();
              updateUnreadMessageIndicators();
            },
          )
          .subscribe();

      print('✅ Started listening for chat updates');
    } catch (e) {
      print('❌ Error starting chat listener: $e');
    }
  }

  // Stop listening for chat updates
  void stopListeningForChatUpdates() {
    _chatChannel?.unsubscribe();
    _chatChannel = null;
    print('✅ Stopped listening for chat updates');
  }

  // Format last active time
  String formatLastActiveTime(DateTime? lastActiveTime) {
    if (lastActiveTime == null) return "Last seen long ago".tr;

    // Convert to local time for accurate calculation
    DateTime localLastActiveTime = lastActiveTime.toLocal();
    Duration difference = DateTime.now().difference(localLastActiveTime);

    if (difference.inMinutes < 1) {
      return "Active now".tr;
    } else if (difference.inMinutes < 60) {
      return "Last seen".tr + " ${difference.inMinutes} " + "minutes ago".tr;
    } else if (difference.inHours < 24) {
      return "Last seen".tr + " ${difference.inHours} " + "hours ago".tr;
    } else if (difference.inDays < 7) {
      return "Last seen".tr + " ${difference.inDays} " + "days ago".tr;
    } else {
      return "Last seen long ago".tr;
    }
  }

  // Check if user is online
  bool isUserOnline(Map<String, dynamic>? presenceData) {
    if (presenceData == null) return false;

    bool isOnline = presenceData['is_online'] ?? false;
    if (!isOnline) return false;

    DateTime? lastActiveTime = presenceData['last_active_time'] != null
        ? DateTime.parse(presenceData['last_active_time']).toLocal()
        : null;

    if (lastActiveTime != null) {
      Duration difference = DateTime.now().difference(lastActiveTime);
      if (difference.inMinutes > 5) {
        return false;
      }
    }

    return true;
  }

  // Update device token in chat
  Future<void> updateDeviceTokenInChat(
    String chatId,
    String userId,
    String newDeviceToken,
  ) async {
    try {
      final chat = await _supabase
          .from('chats')
          .select('sender_id, send_to_id')
          .eq('id', chatId)
          .single();

      Map<String, dynamic> updateData = {};

      if (chat['sender_id'] == userId) {
        updateData['user_device_token'] = newDeviceToken;
      } else if (chat['send_to_id'] == userId) {
        updateData['send_to_device_token'] = newDeviceToken;
      }

      if (updateData.isNotEmpty) {
        await _supabase.from('chats').update(updateData).eq('id', chatId);

        print('✅ Device token updated in chat');
      }
    } catch (e) {
      print('❌ Error updating device token: $e');
    }
  }

  // Add chat room
  Future<bool> addChatRoom(
      Map<String, dynamic> chatRoom, String chatRoomId) async {
    try {
      chatRoom['id'] = chatRoomId;
      await _supabase.from('chats').insert(chatRoom);
      return true;
    } catch (e) {
      print('❌ Error adding chat room: $e');
      return false;
    }
  }

  // Upload image to Supabase Storage
  Future<String?> uploadImage(String filePath, String fileName) async {
    try {
      print('💬 Attempting to upload image: $fileName');

      // Check if the bucket exists first
      try {
        await _supabase.storage.from('chat-images').list();
      } catch (bucketError) {
        print('❌ Chat images bucket not found. Creating bucket...');
        // Try to create the bucket (this might fail if user doesn't have permission)
        try {
          await _supabase.storage.createBucket(
              'chat-images',
              BucketOptions(
                public: true,
                allowedMimeTypes: ['image/*'],
              ));
          print('✅ Chat images bucket created successfully');
        } catch (createError) {
          print('❌ Failed to create chat images bucket: $createError');
          print(
              '💡 Please create the "chat-images" bucket in Supabase dashboard');
          return null;
        }
      }

      final fileBytes = File(filePath).readAsBytesSync();
      await _supabase.storage.from('chat-images').uploadBinary(
            'images/$fileName',
            fileBytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      final url = _supabase.storage
          .from('chat-images')
          .getPublicUrl('images/$fileName');

      print('✅ Image uploaded: $url');
      return url;
    } catch (e) {
      print('❌ Error uploading image: $e');
      if (e.toString().contains('Bucket not found')) {
        print(
            '💡 Please create the "chat-images" bucket in your Supabase dashboard');
        print(
            '💡 Go to Storage > Create bucket > Name: "chat-images" > Make it public');
      } else if (e.toString().contains('row-level security policy') ||
          e.toString().contains('Unauthorized') ||
          e.toString().contains('403')) {
        print('❌ Row Level Security (RLS) policy violation');
        print('💡 Please configure storage policies in Supabase:');
        print('💡 1. Go to Authentication > Policies');
        print('💡 2. Create a policy for storage.objects table');
        print('💡 3. Allow INSERT for authenticated users');
        print(
            '💡 OR disable RLS for testing: ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;');
      }
      return null;
    }
  }
}
