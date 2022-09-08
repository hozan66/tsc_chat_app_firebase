import 'dart:async';
import 'dart:developer';

//Packages
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//Services
import '../services/database_service.dart';

//Providers
import '../providers/authentication_provider.dart';

//Models
import '../models/chat.dart';
import '../models/chat_message.dart';
import '../models/chat_user.dart';

class ChatsPageProvider extends ChangeNotifier {
  final AuthenticationProvider _auth;

  late DatabaseService _db;

  List<Chat>? chats;

  // Allow us to hold the reference to a stream and we can listen to it
  // and perform operations on that stream
  late StreamSubscription _chatsStream;

  ChatsPageProvider(this._auth) {
    _db = GetIt.instance.get<DatabaseService>();
    getChats();
  }

  // Called when we leave this class
  @override
  void dispose() {
    _chatsStream.cancel();
    super.dispose();
  }

  // Getting all chats that user part of it.
  void getChats() async {
    try {
      // Listen to the get chats for user function
      // that we have written in our database service class
      log(_auth.userModel.uid);
      _chatsStream =
          _db.getChatsForUser(_auth.userModel.uid).listen((snapshot) async {
        chats = await Future.wait(
          // Waits for multiple (list of) futures to complete and collects their results.
          snapshot.docs.map(
            (d) async {
              log('========ggggg===========');
              log(d.data().toString());
              // d => document
              Map<String, dynamic> chatData = d.data() as Map<String, dynamic>;
              //Get Users In Chat
              List<ChatUser> members = [];
              for (var uid in chatData["members"]) {
                log(name: 'uid', uid);
                DocumentSnapshot userSnapshot = await _db.getUser(uid);
                log(name: 'userSnapshot', userSnapshot.toString());
                Map<String, dynamic> userData =
                    userSnapshot.data() as Map<String, dynamic>;
                userData["uid"] = userSnapshot.id;
                members.add(
                  ChatUser.fromJson(userData),
                );
              }

              //Get Last Message For Chat
              List<ChatMessage> messages = [];
              QuerySnapshot chatMessage = await _db.getLastMessageForChat(d.id);
              if (chatMessage.docs.isNotEmpty) {
                Map<String, dynamic> messageData =
                    chatMessage.docs.first.data()! as Map<String, dynamic>;
                ChatMessage message = ChatMessage.fromJSON(messageData);
                messages.add(message);
              }

              //Return Chat Instance
              return Chat(
                uid: d.id,
                currentUserUid: _auth.userModel.uid,
                members: members,
                messages: messages,
                activity: chatData["is_activity"],
                group: chatData["is_group"],
                isJoinChannel: chatData["is_join_channel"],
              );
            },
          ).toList(),
        );
        notifyListeners(); // Must be inside listen function
      });
    } catch (e) {
      log("Error getting chats.");
      log(e.toString());
    }
  }
}
