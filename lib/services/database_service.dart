import 'dart:developer';

// Packages
import 'package:cloud_firestore/cloud_firestore.dart';

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
}
