// Packages
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

//Pages
import '../pages/chats_page.dart';
import '../pages/users_page.dart';
import '../providers/authentication_provider.dart';
import '../services/database_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentPage = 0;
  final List<Widget> _pages = [
    const ChatsPage(),
    const UsersPage(),
  ];

  late AuthenticationProvider _auth;
  late DatabaseService _databaseService;

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthenticationProvider>(context);
    _databaseService = GetIt.instance.get<DatabaseService>();
    // Store user token
    _databaseService.storeNotificationToken(_auth.userModel.uid);

    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Home Page'),
      // ),
      body: _pages[_currentPage],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white30,
        currentIndex: _currentPage,
        onTap: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            label: "Chats",
            icon: Icon(
              Icons.chat_bubble_sharp,
              // color: Colors.white,
            ),
          ),
          BottomNavigationBarItem(
            label: "Users",
            icon: Icon(
              Icons.supervised_user_circle_sharp,
              // color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
