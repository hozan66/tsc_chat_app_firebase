import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//Provides
import '../providers/authentication_provider.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthenticationProvider auth =
        Provider.of<AuthenticationProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Page'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
            ),
            onPressed: () async {
              // Clear token
              await FirebaseMessaging.instance.deleteToken();

              auth.logout();
            },
          ),
          const SizedBox(width: 10.0),
        ],
      ),
      body: const Center(
        child: Text(
          'This is admin page',
          style: TextStyle(
            fontSize: 30.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
