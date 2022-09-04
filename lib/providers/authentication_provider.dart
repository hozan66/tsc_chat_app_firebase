// Packages
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

// Service
import '../services/database_service.dart';
import '../services/navigation_service.dart';

// Models
import '../models/chat_user.dart';

// This class is going to be responsible for providing authentication capabilities
// to other pages inside of our app such as (login and register)
// and also going to be responsible for kind of managing the state of authentication

// ChangeNotifier allows other pieces of code to actually
// listen to changes that happen within this class and interact to them
class AuthenticationProvider extends ChangeNotifier {
  late final FirebaseAuth _auth;
  late final NavigationService _navigationService;
  late final DatabaseService _databaseService;

  late ChatUser userModel;

  AuthenticationProvider() {
    _auth = FirebaseAuth.instance;
    _navigationService = GetIt.instance.get<NavigationService>();
    _databaseService = GetIt.instance.get<DatabaseService>();

    // Getting notified for login
    // Listen to stream (changes of authentication) provided by firebase

    // _auth.signOut();

    _auth.authStateChanges().listen((user) {
      if (user != null) {
        log('Logged In');

        _databaseService.updateUserLastSeenTime(user.uid);

        _databaseService.getUser(user.uid).then(
          (snapshot) {
            Map<String, dynamic> userData =
                snapshot.data()! as Map<String, dynamic>;
            userModel = ChatUser.fromJson(
              {
                "uid": user.uid,
                "name": userData["name"],
                "email": userData["email"],
                "last_active": userData["last_active"],
                "image": userData["image"],
              },
            );

            // Check roles
            log(userModel.toMap().toString());
            if (userModel.name == 'admin') {
              _navigationService.removeAndNavigateToRoute('/admin');
            } else {
              _navigationService.removeAndNavigateToRoute('/home');
            }
          },
        );
      } else {
        log('Not Authenticated');
        _navigationService.removeAndNavigateToRoute('/login');
      }
    });
  }

  // Login
  Future<void> loginUsingEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // log('${_auth.currentUser}');
    } on FirebaseAuthException {
      log("Error logging user into Firebase");
    } catch (e) {
      // General Exception
      log(e.toString());
    }
  }

  // Register
  Future<String?> registerUserUsingEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential credentials = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credentials.user!.uid;
    } on FirebaseAuthException {
      log("Error registering user.");
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log(e.toString());
    }
  }
}
