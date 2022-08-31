import 'dart:developer';

// Packages
import 'package:cloud_firestore/cloud_firestore.dart';

//Models
import '../models/chat_message.dart';

const String userCollection = 'Users';
const String chatCollection = 'Chats';
const String messagesCollection = 'messages';

class DatabaseService {
  final FirebaseFirestore _database = FirebaseFirestore.instance;

  DatabaseService() {}

  // Create a user
  Future<void> createUser(
    String uid,
    String email,
    String name,
    String imageURL,
  ) async {
    try {
      await _database.collection(userCollection).doc(uid).set(
        {
          "email": email,
          "image": imageURL,
          "last_active": DateTime.now().toUtc(),
          "name": name,
        },
      );
    } catch (e) {
      log(e.toString());
    }
  }

  // Getting a single document from User collection
  Future<DocumentSnapshot> getUser(String uid) {
    return _database.collection(userCollection).doc(uid).get();
  }

  // Pulling chat data for a specific user from Firestore database
  // QuerySnapshot provided by cloud Firestore
  Stream<QuerySnapshot> getChatsForUser(String uid) {
    return _database
        .collection(chatCollection)
        .where('members', arrayContains: uid) // Filtering
        .snapshots(); //snapshots of documents will update automatically
  }

  // Get the last message
  Future<QuerySnapshot> getLastMessageForChat(String chatID) {
    return _database
        .collection(chatCollection)
        .doc(chatID)
        .collection(messagesCollection)
        .orderBy("sent_time", descending: true)
        .limit(1) // only one document
        .get();
  }

  // Stream of chat messages
  Stream<QuerySnapshot> streamMessagesForChat(String chatID) {
    return _database
        .collection(chatCollection)
        .doc(chatID)
        .collection(messagesCollection)
        .orderBy("sent_time", descending: false)
        .snapshots(); // retrieve documents
  }

  // Send message to a specific chat
  Future<void> addMessageToChat(String chatID, ChatMessage message) async {
    try {
      await _database
          .collection(chatCollection)
          .doc(chatID)
          .collection(messagesCollection)
          .add(
            message.toJson(),
          );
    } catch (e) {
      log(e.toString());
    }
  }

  // Update Chat message
  // Will update a part of the data that are inside of one chat document
  Future<void> updateChatData(String chatID, Map<String, dynamic> data) async {
    try {
      await _database.collection(chatCollection).doc(chatID).update(data);
    } catch (e) {
      log(e.toString());
    }
  }

  // Update the last_active time (part of document)
  Future<void> updateUserLastSeenTime(String uid) async {
    try {
      await _database.collection(userCollection).doc(uid).update(
        {
          "last_active": DateTime.now().toUtc(),
        },
      );
    } catch (e) {
      log(e.toString());
    }
  }

  // Delete Chat
  Future<void> deleteChat(String chatID) async {
    try {
      await _database.collection(chatCollection).doc(chatID).delete();
    } catch (e) {
      log(e.toString());
    }
  }
}
