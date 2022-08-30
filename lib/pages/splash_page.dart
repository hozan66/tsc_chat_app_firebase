import 'package:flutter/material.dart';

// My packages
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';

// Services
import 'package:tsc_chat_app_firebase/services/navigation_service.dart';
import '../services/cloud_storage_service.dart';
import '../services/database_service.dart';
import '../services/media_service.dart';

class SplashPage extends StatefulWidget {
  final VoidCallback onInitializationComplete;

  const SplashPage({
    Key? key,
    required this.onInitializationComplete,
  }) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2)).then((_) {
      _setup().then(
        (_) => widget.onInitializationComplete(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        backgroundColor: const Color.fromRGBO(36, 35, 49, 1.0),
        scaffoldBackgroundColor: const Color.fromRGBO(36, 35, 49, 1.0),
      ),
      home: Scaffold(
        body: Center(
          child: Container(
            width: 200.0,
            height: 200.0,
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.contain,
                image: AssetImage('assets/images/logo.png'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _setup() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp();
    _registerServices();
  }

  // Registration of services
  void _registerServices() {
    GetIt.instance.registerSingleton<NavigationService>(NavigationService());

    GetIt.instance.registerSingleton<MediaService>(MediaService());

    GetIt.instance
        .registerSingleton<CloudStorageService>(CloudStorageService());
    GetIt.instance.registerSingleton<DatabaseService>(DatabaseService());
  }
}
