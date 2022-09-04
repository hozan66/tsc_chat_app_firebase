//Packages
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

//Widgets
import '../models/chat_user.dart';
import '../services/database_service.dart';
import '../widgets/top_bar.dart';
import '../widgets/custom_list_view_tiles.dart';
import '../widgets/custom_input_fields.dart';

//Models
import '../models/chat.dart';
import '../models/chat_message.dart';

//Providers
import '../providers/authentication_provider.dart';
import '../providers/chat_page_provider.dart';

class ChatPage extends StatefulWidget {
  final Chat chat;

  const ChatPage({
    Key? key,
    required this.chat,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late ChatPageProvider _pageProvider;

  late GlobalKey<FormState> _messageFormState;
  late ScrollController _messagesListViewController; // To control the list view
  late DatabaseService _db;

  @override
  void initState() {
    super.initState();
    _messageFormState = GlobalKey<FormState>();
    _messagesListViewController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    _db = GetIt.instance.get<DatabaseService>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatPageProvider>(
          create: (_) => ChatPageProvider(
            widget.chat.uid,
            _auth,
            _messagesListViewController,
          ),
        ),
      ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Builder(builder: (context) {
      _pageProvider = context.watch<ChatPageProvider>();
      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: _deviceWidth * 0.03,
                vertical: _deviceHeight * 0.02,
              ),
              height: _deviceHeight,
              width: _deviceWidth * 0.97,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TopBar(
                    widget.chat.title(),
                    fontSize: 20,
                    primaryAction: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Color.fromRGBO(0, 82, 218, 1.0),
                      ),
                      onPressed: () {
                        _pageProvider.deleteChat();
                      },
                    ),
                    secondaryAction: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color.fromRGBO(0, 82, 218, 1.0),
                      ),
                      onPressed: () {
                        _pageProvider.goBack();
                      },
                    ),
                  ),
                  _messagesListView(),
                  _sendMessageForm(),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _messagesListView() {
    if (_pageProvider.messages != null) {
      if (_pageProvider.messages!.isNotEmpty) {
        return SizedBox(
          height: _deviceHeight * 0.74,
          child: ListView.builder(
            controller: _messagesListViewController,
            itemCount: _pageProvider.messages!.length,
            itemBuilder: (BuildContext context, int index) {
              ChatMessage message = _pageProvider.messages![index];
              bool isOwnMessage = message.senderID == _auth.userModel.uid;
              return CustomChatListViewTile(
                deviceHeight: _deviceHeight,
                width: _deviceWidth * 0.80,
                message: message,
                isOwnMessage: isOwnMessage,
                // If condition is true it will add to the list
                sender: widget.chat.members
                    .where((m) => m.uid == message.senderID)
                    .first,
              );
            },
          ),
        );
      } else {
        return const Align(
          alignment: Alignment.center,
          child: Text(
            "Be the first to say Hi!",
            style: TextStyle(color: Colors.white),
          ),
        );
      }
    } else {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }
  }

  // Message field
  Widget _sendMessageForm() {
    return Container(
      height: _deviceHeight * 0.06,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(30, 29, 37, 1.0),
        borderRadius: BorderRadius.circular(100),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: _deviceWidth * 0.04,
        vertical: _deviceHeight * 0.03,
      ),
      child: Form(
        key: _messageFormState,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _messageTextField(),
            _sendMessageButton(),
            _imageMessageButton(),
          ],
        ),
      ),
    );
  }

  Widget _messageTextField() {
    return SizedBox(
      width: _deviceWidth * 0.65,
      child: CustomTextFormField(
        onSaved: (value) {
          _pageProvider.message = value;
        },
        // No spaces, dollar signs, things like that
        regEx: r"^(?!\s*$).+",
        hintText: "Type a message",
        obscureText: false,
      ),
    );
  }

  Widget _sendMessageButton() {
    double size = _deviceHeight * 0.04;
    return SizedBox(
      height: size,
      width: size,
      child: IconButton(
        icon: const Icon(
          Icons.send,
          color: Colors.white,
        ),
        onPressed: () async {
          if (_messageFormState.currentState!.validate()) {
            _messageFormState.currentState!.save(); // Call onSaved function
            _pageProvider.sendTextMessage();
            _messageFormState.currentState!.reset(); // Clear TextField

            // Store user token
            // await _db.storeNotificationToken(_auth.userModel.uid);

            // Get receiver id
            List<ChatUser> recipients = widget.chat.recepients();
            log(recipients.first.uid);

            // Get receiver token
            DocumentSnapshot snapshot =
                await _db.getReceiverInfo(recipients.first.uid);
            Map<String, dynamic> receiverData =
                snapshot.data() as Map<String, dynamic>;
            log(receiverData['token']);
            String? receiverToken = receiverData['token'];

            // Send the notification
            _db.sendNotification(widget.chat.title(), receiverToken ?? '');
          }
        },
      ),
    );
  }

  Widget _imageMessageButton() {
    double size = _deviceHeight * 0.04;
    return SizedBox(
      height: size,
      width: size,
      child: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(0, 82, 218, 1.0),
        onPressed: () {
          _pageProvider.sendImageMessage();
        },
        child: const Icon(Icons.camera_enhance),
      ),
    );
  }
}
