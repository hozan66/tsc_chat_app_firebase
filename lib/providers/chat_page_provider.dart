import 'dart:async';
import 'dart:developer';

//Packages
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

//Services
import '../services/database_service.dart';
import '../services/cloud_storage_service.dart';
import '../services/media_service.dart';
import '../services/navigation_service.dart';

//Providers
import '../providers/authentication_provider.dart';

//Models
import '../models/chat_message.dart';

class ChatPageProvider extends ChangeNotifier {
  late DatabaseService _db;
  late CloudStorageService _storage;
  late MediaService _media;
  late NavigationService _navigation;

  AuthenticationProvider _auth;
  final ScrollController _messagesListViewController;

  final String _chatId;
  List<ChatMessage>? messages;

  late StreamSubscription _messagesStream;
  // Listen to keyboard event
  late StreamSubscription _keyboardVisibilityStream;
  // Provided from package
  late KeyboardVisibilityController _keyboardVisibilityController;

  String? _message;

  String get message {
    return _message!;
  }

  set message(String value) {
    _message = value;
  }

  ChatPageProvider(this._chatId, this._auth, this._messagesListViewController) {
    _db = GetIt.instance.get<DatabaseService>();
    _storage = GetIt.instance.get<CloudStorageService>();
    _media = GetIt.instance.get<MediaService>();
    _navigation = GetIt.instance.get<NavigationService>();
    _keyboardVisibilityController = KeyboardVisibilityController();
    listenToMessages();
    listenToKeyboardChanges();
  }

  @override
  void dispose() {
    // Dispose the stream when a chat_page_provider gets destroyed
    _messagesStream.cancel();
    super.dispose();
  }

  // Setting up the messages stream and also taking care of giving
  // or notifying us the UI of the chat_page, so can render the UI
  void listenToMessages() {
    try {
      _messagesStream = _db.streamMessagesForChat(_chatId).listen(
        (snapshot) {
          List<ChatMessage> messagesList = snapshot.docs.map(
            (m) {
              // message
              Map<String, dynamic> messageData =
                  m.data() as Map<String, dynamic>;
              return ChatMessage.fromJSON(messageData);
            },
          ).toList();
          messages = messagesList;
          notifyListeners();

          // After all UI is loaded then execute this function
          WidgetsBinding.instance.addPostFrameCallback(
            (_) {
              // hasClients means has data
              if (_messagesListViewController.hasClients) {
                // Jump to a specific point
                _messagesListViewController.jumpTo(
                    _messagesListViewController.position.maxScrollExtent);
              }
            },
          );
        },
      );
    } catch (e) {
      log("Error getting messages.");
      log(e.toString());
    }
  }

  // Listen to keyboard
  void listenToKeyboardChanges() {
    _keyboardVisibilityStream = _keyboardVisibilityController.onChange.listen(
      (bool event) {
        // event will be true when keyboard is opened
        // event will be false when keyboard is closed
        _db.updateChatData(_chatId, {"is_activity": event});
      },
    );
  }

  // Send Text
  void sendTextMessage() {
    if (_message != null) {
      ChatMessage messageToSend = ChatMessage(
        content: _message!,
        type: MessageType.TEXT,
        senderID: _auth.userModel.uid, // Current logged in user
        sentTime: DateTime.now(),
      );
      _db.addMessageToChat(_chatId, messageToSend);
    }
  }

  // Send Image
  void sendImageMessage() async {
    try {
      // We need to upload an image before getting the URL
      // then we can send to the actual faster database to be stored
      PlatformFile? file = await _media.pickImageFromLibrary();
      if (file != null) {
        String? downloadURL = await _storage.saveChatImageToStorage(
            _chatId, _auth.userModel.uid, file);
        ChatMessage messageToSend = ChatMessage(
          content: downloadURL!,
          type: MessageType.IMAGE,
          senderID: _auth.userModel.uid,
          sentTime: DateTime.now(),
        );
        _db.addMessageToChat(_chatId, messageToSend);
      }
    } catch (e) {
      log("Error sending image message.");
      log(e.toString());
    }
  }

  // Delete chat
  void deleteChat() {
    // We need to go back because once we delete a chat, we won't
    // have access to the data anymore
    goBack();
    _db.deleteChat(_chatId);
  }

  void goBack() {
    _navigation.goBack();
  }
}
