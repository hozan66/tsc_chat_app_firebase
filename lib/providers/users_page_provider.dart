//Packages
import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

//Services
import '../services/database_service.dart';
import '../services/navigation_service.dart';

//Providers
import '../providers/authentication_provider.dart';

//Models
import '../models/chat_user.dart';
import '../models/chat.dart';

//Pages
import '../pages/chat_page.dart';

class UsersPageProvider extends ChangeNotifier {
  final AuthenticationProvider _auth;

  late DatabaseService _database;
  late NavigationService _navigation;

  List<ChatUser>? users;
  late List<ChatUser> _selectedUsers;

  List<ChatUser> get selectedUsers {
    return _selectedUsers;
  }

  UsersPageProvider(this._auth) {
    _selectedUsers = [];
    _database = GetIt.instance.get<DatabaseService>();
    _navigation = GetIt.instance.get<NavigationService>();

    getUsers();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }

  // Bring all users
  void getUsers({String? name}) async {
    _selectedUsers = [];
    try {
      _database.getUsers(name: name).then(
        (snapshot) {
          users = snapshot.docs.map(
            (doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              data["uid"] = doc
                  .id; // There is a unique ID for each of user documents provided by Firebase
              return ChatUser.fromJson(data);
            },
          ).toList();
          notifyListeners();
        },
      );
    } catch (e) {
      log("Error getting users.");
      log(e.toString());
    }
  }

  // Selected users were a list of chat users
  // that we have added as a property to our users page
  void updateSelectedUsers(ChatUser user) {
    if (_selectedUsers.contains(user)) {
      _selectedUsers.remove(user);
    } else {
      _selectedUsers.add(user);
    }
    notifyListeners();
  }

  void createChat() async {
    try {
      //Create Chat
      List<String> membersIds = _selectedUsers.map((user) => user.uid).toList();
      membersIds.add(_auth.userModel.uid);
      bool isGroup = _selectedUsers.length > 1;
      DocumentReference? doc = await _database.createChat(
        {
          "is_group": isGroup,
          "is_activity": false,
          "members": membersIds,
        },
      );

      //Navigate To Chat Page
      List<ChatUser> members = [];
      for (var uid in membersIds) {
        DocumentSnapshot userSnapshot = await _database.getUser(uid);
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        userData["uid"] = userSnapshot.id;
        members.add(
          ChatUser.fromJson(
            userData,
          ),
        );
      }

      ChatPage chatPage = ChatPage(
        chat: Chat(
          uid: doc!.id,
          currentUserUid: _auth.userModel.uid,
          members: members,
          messages: [],
          activity: false,
          group: isGroup,
          isJoinChannel: false,
        ),
      );
      _selectedUsers = [];
      notifyListeners();
      _navigation.navigateToPage(chatPage);
    } catch (e) {
      log("Error creating chat.");
      log(e.toString());
    }
  }
}
