import 'package:flutter/material.dart';

// My packages
import 'package:provider/provider.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';

// Pages
import 'package:tsc_chat_app_firebase/pages/splash_page.dart';
import 'package:tsc_chat_app_firebase/pages/login_page.dart';
import 'package:tsc_chat_app_firebase/pages/home_page.dart';
import 'package:tsc_chat_app_firebase/pages/register_page.dart';

// Provider
import 'package:tsc_chat_app_firebase/providers/authentication_provider.dart';

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

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
        },
      ),
    );
  }
}
