import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  }

  updateImage(String userAndPostId, Map<String, dynamic> imageData) async {
    chatCollection.doc(userAndPostId).update(imageData);
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
