import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Notification/firebase_messaging.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';

class ChatController extends GetxController {
  String? path;
  bool isLast = false;
  bool isTyping = false;
  bool isImageSend = false;

  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();
  bool isShow = false;

  final CollectionReference chatCollection =
      FirebaseFirestore.instance.collection("chat");
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection("users");
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  Future getAllUser() async {
    return chatCollection.snapshots();
  }

  getChats(String id) async {
    return chatCollection
        .doc(id)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  Future<void> deleteChat(String docId) async {
    QuerySnapshot querySnapshot =
        await chatCollection.doc(docId).collection("messages").get();
    for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
      await chatCollection
          .doc(docId)
          .collection("messages")
          .doc(documentSnapshot.id)
          .delete();
    }
    chatCollection.doc(docId).delete().then((value) {
      print('Document deleted from Firestore');
    }).catchError((error) {
      print('Error deleting document: $error');
    });
  }

  Future sendMessage(
      String userAndPostId, Map<String, dynamic> chatMessageData) async {
    // Add a new message to the subcollection
    await chatCollection
        .doc(userAndPostId)
        .collection("messages")
        .add(chatMessageData);

    // Check if the parent document exists
    final docSnapshot = await chatCollection.doc(userAndPostId).get();
    if (docSnapshot.exists) {
      // Update if it exists
      await chatCollection.doc(userAndPostId).update(chatMessageData);
    } else {
      // Create if it doesn't exist
      await chatCollection.doc(userAndPostId).set(chatMessageData);
    }

    // Update unread count after sending message
    Future.delayed(Duration(milliseconds: 500), () {
      updateUnreadMessageIndicators();
    });
  }

  updateImage(String userAndPostId, Map<String, dynamic> imageData) async {
    chatCollection.doc(userAndPostId).update(imageData);
  }

  // Mark chat as read for the current user
  Future<void> markChatAsRead(String chatId, String userId) async {
    try {
      Map<String, dynamic> updateData = {};

      // Get the chat document to determine user role
      DocumentSnapshot chatDoc = await chatCollection.doc(chatId).get();

      if (chatDoc.exists) {
        String? senderId = chatDoc.get('senderId');
        String? sendToId = chatDoc.get('sendToId');

        // Update the appropriate lastReadTime field based on user role
        if (senderId == userId) {
          updateData['senderLastReadTime'] = FieldValue.serverTimestamp();
        } else if (sendToId == userId) {
          updateData['recipientLastReadTime'] = FieldValue.serverTimestamp();
        }

        if (updateData.isNotEmpty) {
          await chatCollection.doc(chatId).update(updateData);
          print("🔥 ✅ Chat marked as read for user $userId in chat $chatId");

          // Update badge count when messages are read
          await updateBadgeCountFromChats();
        }
      }
    } catch (e) {
      print("🔥 ❌ Error marking chat as read: $e");
    }
  }

  // Update badge count based on actual unread chat messages
  Future<void> updateBadgeCountFromChats() async {
    try {
      final authCont = Get.find<AuthController>();
      if (authCont.user?.userId == null) return;

      String currentUserId = authCont.user!.userId.toString();
      int unreadCount = 0;

      // Get all chat documents where this user participates
      QuerySnapshot chatSnapshot = await chatCollection.get();

      for (QueryDocumentSnapshot chatDoc in chatSnapshot.docs) {
        Map<String, dynamic> chatData = chatDoc.data() as Map<String, dynamic>;

        // Check if this user is part of this chat
        String? senderId = chatData['senderId']?.toString();
        String? sendToId = chatData['sendToId']?.toString();

        if (senderId == currentUserId || sendToId == currentUserId) {
          // Only count chats that have actual messages
          bool hasMessages = chatData['isMessaged'] == true ||
              (chatData['message'] != null &&
                  chatData['message'].toString().trim().isNotEmpty &&
                  chatData['message'] != "");

          if (hasMessages) {
            // Check if this chat has unread messages for this user
            bool isUnread = hasUnreadMessages(chatData, currentUserId);
            if (isUnread) {
              unreadCount++;
            }
          }
        }
      }

      // Update both the app badge and UI state
      await FCM.setBadgeCount(unreadCount);
      authCont.unreadMessageCount.value = unreadCount;
      authCont.hasUnreadMessages.value = unreadCount > 0;
      authCont.update();

      print("🔥 ✅ Badge count updated to: $unreadCount unread chats");
    } catch (e) {
      print("🔥 ❌ Error updating badge count from chats: $e");
    }
  }

  // Check if chat has unread messages for the current user
  bool hasUnreadMessages(Map<String, dynamic> chatData, String currentUserId) {
    try {
      String? senderId = chatData['senderId'];
      String? sendToId = chatData['sendToId'];
      String? lastMessageSendBy = chatData['sendBy'];
      Timestamp? lastMessageTime =
          chatData['time'] is Timestamp ? chatData['time'] : null;

      // If there's no last message time, consider it as read
      if (lastMessageTime == null) return false;

      // If the current user sent the last message, it's not unread for them
      if (lastMessageSendBy == currentUserId) return false;

      // Get the appropriate lastReadTime based on user role
      Timestamp? lastReadTime;
      if (senderId == currentUserId) {
        lastReadTime = chatData['senderLastReadTime'] is Timestamp
            ? chatData['senderLastReadTime']
            : null;
      } else if (sendToId == currentUserId) {
        lastReadTime = chatData['recipientLastReadTime'] is Timestamp
            ? chatData['recipientLastReadTime']
            : null;
      }

      // If no lastReadTime exists, consider it unread
      if (lastReadTime == null) return true;

      // Compare last message time with last read time
      return lastMessageTime.compareTo(lastReadTime) > 0;
    } catch (e) {
      print("🔥 ❌ Error checking unread status: $e");
      return false;
    }
  }

  // Update user presence (online/offline status)
  Future<void> updateUserPresence(String userId, bool isOnline) async {
    try {
      Map<String, dynamic> presenceData = {
        'isOnline': isOnline,
        'lastActiveTime': FieldValue.serverTimestamp(),
      };

      await usersCollection
          .doc(userId)
          .set(presenceData, SetOptions(merge: true));
      print("🔥 ✅ User presence updated: $userId - Online: $isOnline");
    } catch (e) {
      print("🔥 ❌ Error updating user presence: $e");
    }
  }

  // Get user presence data
  Stream<DocumentSnapshot> getUserPresence(String userId) {
    return usersCollection.doc(userId).snapshots();
  }

  // Set user as online when app becomes active
  Future<void> setUserOnline(String userId) async {
    await updateUserPresence(userId, true);
  }

  // Set user as offline when app goes to background
  Future<void> setUserOffline(String userId) async {
    await updateUserPresence(userId, false);
  }

  // Update unread message indicators for UI
  Future<void> updateUnreadMessageIndicators() async {
    try {
      final authCont = Get.find<AuthController>();
      if (authCont.user?.userId == null) return;

      String currentUserId = authCont.user!.userId.toString();
      int unreadCount = 0;

      // Get all chat documents where this user participates
      QuerySnapshot chatSnapshot = await chatCollection.get();

      for (QueryDocumentSnapshot chatDoc in chatSnapshot.docs) {
        Map<String, dynamic> chatData = chatDoc.data() as Map<String, dynamic>;

        // Check if this user is part of this chat
        String? senderId = chatData['senderId']?.toString();
        String? sendToId = chatData['sendToId']?.toString();

        if (senderId == currentUserId || sendToId == currentUserId) {
          // Only count chats that have actual messages
          bool hasMessages = chatData['isMessaged'] == true ||
              (chatData['message'] != null &&
                  chatData['message'].toString().trim().isNotEmpty &&
                  chatData['message'] != "");

          if (hasMessages) {
            // Check if this chat has unread messages for this user
            bool isUnread = hasUnreadMessages(chatData, currentUserId);
            if (isUnread) {
              unreadCount++;
            }
          }
        }
      }

      // Update both the count and boolean indicator
      authCont.unreadMessageCount.value = unreadCount;
      authCont.hasUnreadMessages.value = unreadCount > 0;
      authCont.update();

      print("🔥 ✅ Unread message indicator updated: $unreadCount unread chats");
    } catch (e) {
      print("🔥 ❌ Error updating unread message indicators: $e");
    }
  }

  // Start listening for real-time chat updates
  void startListeningForChatUpdates() {
    try {
      final authCont = Get.find<AuthController>();
      if (authCont.user?.userId == null) return;

      // Listen for changes in chat collection
      chatCollection.snapshots().listen((QuerySnapshot snapshot) {
        // Update unread count whenever chat data changes
        updateUnreadMessageIndicators();
      });

      print(
          "🔥 ✅ Started listening for chat updates for user: ${authCont.user!.userId}");
    } catch (e) {
      print("🔥 ❌ Error starting chat listener: $e");
    }
  }

  // Stop listening for chat updates
  void stopListeningForChatUpdates() {
    // This would be implemented if we need to cancel the stream subscription
    print("🔥 ✅ Stopped listening for chat updates");
  }

  // Format last active time for display
  String formatLastActiveTime(Timestamp? lastActiveTime) {
    if (lastActiveTime == null) return "Last seen long ago".tr;

    DateTime lastActive = lastActiveTime.toDate();
    DateTime now = DateTime.now();
    Duration difference = now.difference(lastActive);

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

  // Check if user is currently online
  bool isUserOnline(Map<String, dynamic>? presenceData) {
    if (presenceData == null) return false;

    bool isOnline = presenceData['isOnline'] ?? false;
    Timestamp? lastActiveTime = presenceData['lastActiveTime'];

    if (!isOnline) return false;

    // Consider user offline if last active time is more than 5 minutes ago
    if (lastActiveTime != null) {
      DateTime lastActive = lastActiveTime.toDate();
      DateTime now = DateTime.now();
      Duration difference = now.difference(lastActive);

      if (difference.inMinutes > 5) {
        return false;
      }
    }

    return true;
  }

  // Update device token in chat document
  Future<void> updateDeviceTokenInChat(
      String chatId, String userId, String newDeviceToken) async {
    try {
      // Get the chat document
      DocumentSnapshot chatDoc = await chatCollection.doc(chatId).get();

      if (chatDoc.exists) {
        Map<String, dynamic> updateData = {};

        // Determine which field to update based on user ID
        String? senderId = chatDoc.get('senderId');
        String? sendToId = chatDoc.get('sendToId');

        if (senderId == userId) {
          updateData['userDeviceToken'] = newDeviceToken;
          print(
              "🔥 Updated userDeviceToken for sender $userId in chat $chatId");
        } else if (sendToId == userId) {
          updateData['sendToDeviceToken'] = newDeviceToken;
          print(
              "🔥 Updated sendToDeviceToken for recipient $userId in chat $chatId");
        }

        if (updateData.isNotEmpty) {
          await chatCollection.doc(chatId).update(updateData);
          print("🔥 Device token updated successfully in chat document");
        }
      }
    } catch (e) {
      print("🔥 Error updating device token in chat: $e");
    }
  }

  Future<bool>? addChatRoom(chatRoom, chatRoomId) {
    chatCollection.doc(chatRoomId).set(chatRoom).catchError((e) {
      print(e);
    });
  }
}
