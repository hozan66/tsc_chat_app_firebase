//Packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

//Providers
import '../providers/authentication_provider.dart';
import '../providers/chats_page_provider.dart';

//Services
// import '../services/navigation_service.dart';

//Pages
// import '../pages/chat_page.dart';

//Widgets
import '../widgets/top_bar.dart';
import '../widgets/custom_list_view_tiles.dart';

//Models
import '../models/chat.dart';
import '../models/chat_user.dart';
import '../models/chat_message.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({Key? key}) : super(key: key);

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;

  // late NavigationService _navigation;
  late ChatsPageProvider _pageProvider;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    // _navigation = GetIt.instance.get<NavigationService>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatsPageProvider>(
            create: (_) => ChatsPageProvider(_auth)),
      ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Builder(
        // Builder function has a builder property that has a function
        // that kind of describes how the builder is going to build out its widget
        // tree inside of it, and it takes in a build context that we need
        // this context for our provider
        builder: (BuildContext context) {
      // Watching (listening) our ChatsPageProvider
      // that is going to watch our channel provider

      // Whenever a new state is emitted By Bloc or Provider
      // Rebuild the widget from which the lookup was started
      _pageProvider = context.watch<ChatsPageProvider>();
      return SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: _deviceWidth * 0.03,
            vertical: _deviceHeight * 0.02,
          ),
          height: _deviceHeight * 0.98,
          width: _deviceWidth * 0.97,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TopBar(
                'Chats',
                primaryAction: IconButton(
                  icon: const Icon(
                    Icons.logout,
                    color: Color.fromRGBO(0, 82, 218, 1.0),
                  ),
                  onPressed: () {
                    _auth.logout();
                  },
                ),
              ),
              _chatsList(),
            ],
          ),
        ),
      );
    });
  }

  Widget _chatsList() {
    List<Chat>? chats = _pageProvider.chats;

    return Expanded(
      // We indicate that this function needs to be run
      // ((){})()
      child: (() {
        if (chats != null) {
          if (chats.isNotEmpty) {
            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                return _chatTile(chats[index]);
              },
            );
          } else {
            return const Center(
              child: Text(
                'No Chats Found.',
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
      })(),
    );
  }

  Widget _chatTile(Chat chat) {
    List<ChatUser> recipients = chat.recepients();
    bool isActive = recipients.any((d) => d.wasRecentlyActive());
    String subtitleText = '';

    if (chat.messages.isNotEmpty) {
      subtitleText = chat.messages.first.type != MessageType.TEXT
          ? 'Media Attachment'
          : chat.messages.first.content;
    }

    return CustomListViewTileWithActivity(
      height: _deviceHeight * 0.10,
      title: chat.title(),
      subtitle: subtitleText,
      imagePath: chat.imageURL(), // 'https://i.pravatar.cc/300'
      isActive: isActive,
      isActivity: chat.activity,
      onTap: () {},
    );
  }
}
