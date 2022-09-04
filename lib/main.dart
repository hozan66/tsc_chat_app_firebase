import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

// My packages
import 'package:provider/provider.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';

// Pages
import 'package:tsc_chat_app_firebase/pages/splash_page.dart';
import 'package:tsc_chat_app_firebase/pages/login_page.dart';
import 'package:tsc_chat_app_firebase/pages/home_page.dart';
import 'package:tsc_chat_app_firebase/pages/register_page.dart';
import 'package:tsc_chat_app_firebase/pages/admin_page.dart';

// Provider
import 'package:tsc_chat_app_firebase/providers/authentication_provider.dart';
import 'package:tsc_chat_app_firebase/services/local_push_notification.dart';

// Services
import 'package:tsc_chat_app_firebase/services/navigation_service.dart';

void main() {
  runApp(
    SplashPage(
      key: UniqueKey(),
      onInitializationComplete: () {
        runApp(const MyApp());
      },
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Foreground notification
    // work when app currently used and opened
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Receiving notification from Firestore
      // log('OnMessage: ${message.notification?.title}');
      log('OnMessage');

      // final snackBar = SnackBar(
      //   content: Text(
      //     message.notification?.title ?? '',
      //     style: const TextStyle(color: Colors.white),
      //   ),
      // );
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);

      // Display notification
      // Local notification package used for foreground notification
      LocalNotificationService.display(message);
    });

    // Work when we click on notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('OnMessage: ${message.notification?.title}');

      // final snackBar =
      //     SnackBar(content: Text(message.notification?.title ?? ''));
      //
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Global access
      providers: [
        ChangeNotifierProvider<AuthenticationProvider>(
            create: (BuildContext context) {
          return AuthenticationProvider();
        }),
      ],
      child: MaterialApp(
        title: 'Flutter Chatify',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          backgroundColor: const Color.fromRGBO(36, 35, 49, 1.0),
          scaffoldBackgroundColor: const Color.fromRGBO(36, 35, 49, 1.0),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color.fromRGBO(30, 29, 37, 1.0),
          ),
        ),
        navigatorKey: NavigationService.navigatorKey,
        initialRoute: '/login',
        // initialRoute: '/home',
        routes: {
          '/login': (BuildContext context) => const LoginPage(),
          '/register': (BuildContext context) => const RegisterPage(),
          '/home': (BuildContext context) => const HomePage(),
          '/admin': (BuildContext context) => const AdminPage(),
        },
      ),
    );
  }
}
