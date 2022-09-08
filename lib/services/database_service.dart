import 'dart:convert';
import 'dart:developer';

// Packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

//Models
import '../models/chat_message.dart';

const String userCollection = 'Users';
const String chatCollection = 'Chats';
const String messagesCollection = 'messages';

class DatabaseService {
  final FirebaseFirestore _database = FirebaseFirestore.instance;

  DatabaseService();

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

  // Getting all users
  Future<QuerySnapshot> getUsers({String? name}) {
    Query query = _database.collection(userCollection);
    if (name != null) {
      // We check to see all of users whose name contains
      // this name stream that gets passed in
      // and we take all of those users and make another query
      // on top of that query where we take the existing name that
      // was passed and we add z to it.
      // and this return all of the users whose name field contains
      // the name that was passed to us
      query = query
          .where("name", isGreaterThanOrEqualTo: name)
          .where("name", isLessThanOrEqualTo: "${name}z");
    }

    log(name: 'Getting all users', '${query.get()}');
    return query.get();
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

  // Create Chat In Cloud Firestore
  Future<DocumentReference?> createChat(Map<String, dynamic> data) async {
    try {
      // Create a new document inside chats collection
      DocumentReference chat =
          await _database.collection(chatCollection).add(data);
      return chat;
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  // =========================================================

  // We have to create a notification token for our device.
  // Each token for each device
  Future<void> storeNotificationToken(String userId) async {
    String? token = await FirebaseMessaging.instance.getToken();

    // Store my own token to Firestore
    FirebaseFirestore.instance.collection(userCollection).doc(userId).set(
      {'token': token},
      // Make sure to SetOptions to true
      // otherwise your previous data will get lost.
      SetOptions(merge: true),
    );
  }

  Future<DocumentSnapshot> getReceiverInfo(String receiverId) async {
    // Get receiver doc from Firestore
    return FirebaseFirestore.instance
        .collection(userCollection)
        .doc(receiverId)
        .get();
  }

  // Send notification from our side
  Future<void> sendNotification(String title, String token) async {
    // Data about the notification
    final Map<String, dynamic> data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK', // Don't miss spelling
      'id': '1',
      'status': 'done',
      'message': title,
    };

    try {
      http.Response response =
          await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: <String, String>{
                'Content-Type': 'application/json',
                'Authorization':
                    'key=AAAAcdMt1Bw:APA91bEA8Z-Tcqhe6qQEI83YdvX9x9KqIaKhdMbb-1kHG4lRFsRAWYLj2mHZWJmtoRhKS9Le0H8SmeX6j2W3C3OywURTs4Xzj_-zFhse_H_Mq-Ss60Iz9HIyZ_C4Sexiine5EUY0U3EV'
                // key=ADD-YOUR-SERVER-KEY-HERE
              },
              body: jsonEncode(<String, dynamic>{
                'notification': <String, dynamic>{
                  'title': title,
                  'body': 'You are followed by someone!',
                },
                'priority': 'high',
                'data': data,
                'to': token,
                // We send the notification to a specific user according to this token
              }));

      // Checking for the response
      if (response.statusCode == 200) {
        log("Yeah notification is send it");
      } else {
        log("Error In statusCode");
      }
    } catch (e) {
      log(e.toString());
    }
  }

  // Send notification to all admins who subscription to the channel
  Future<void> sendNotificationToTopic(String title) async {
    // Data about the notification
    final Map<String, dynamic> data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK', // Don't miss spelling
      'id': '1',
      'status': 'done',
      'message': title,
    };

    try {
      http.Response response =
          await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: <String, String>{
                'Content-Type': 'application/json',
                'Authorization':
                    'key=AAAAcdMt1Bw:APA91bEA8Z-Tcqhe6qQEI83YdvX9x9KqIaKhdMbb-1kHG4lRFsRAWYLj2mHZWJmtoRhKS9Le0H8SmeX6j2W3C3OywURTs4Xzj_-zFhse_H_Mq-Ss60Iz9HIyZ_C4Sexiine5EUY0U3EV'
                // key=ADD-YOUR-SERVER-KEY-HERE
              },
              body: jsonEncode(<String, dynamic>{
                'notification': <String, dynamic>{
                  'title': title,
                  'body': 'You are followed by someone!',
                },
                'priority': 'high',
                'data': data,
                'to': '/topics/subscription',
                // Send the notification from channel all subscriptions
              }));

      // Checking for the response
      if (response.statusCode == 200) {
        log("Yeah notification is send from the channel");
      } else {
        log("Error In statusCode");
      }
    } catch (e) {
      log(e.toString());
    }
  }
}
