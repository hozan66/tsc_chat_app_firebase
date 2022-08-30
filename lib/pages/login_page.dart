import 'dart:developer';

// Packages
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

// Widgets
import 'package:tsc_chat_app_firebase/widgets/custom_text_form_field.dart';
import '../widgets/rounded_button.dart';

// Providers
import 'package:tsc_chat_app_firebase/providers/authentication_provider.dart';

// Services
import 'package:tsc_chat_app_firebase/services/navigation_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late double _deviceHeight;
  late double _deviceWidth;
  final _loginFormKey = GlobalKey<FormState>();

  late AuthenticationProvider _auth;
  late NavigationService _navigation;

  String? _email;
  String? _password;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();

    return _buildUI();
  }

  Widget _buildUI() {
    // _deviceWidth *0.03 => 3% of our device
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: _deviceWidth * 0.03,
            vertical: _deviceHeight * 0.02,
          ),
          width: _deviceWidth * 0.98,
          // height: _deviceHeight * 0.97,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                // Stretched to the maximum size that it can have
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _pageTitle(),
                  const SizedBox(height: 40.0),
                  _loginForm(),
                  const SizedBox(height: 40.0),
                  _loginButton(),
                  const SizedBox(height: 20.0),
                  _registerAccountLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _registerAccountLink() {
    return InkWell(
      onTap: () {
        log('Clicked!');

        _navigation.navigateToRoute('/register');
      },
      child: const SizedBox(
        child: Text(
          'Don\'t have an account?',
          style: TextStyle(
            color: Colors.blueAccent,
          ),
        ),
      ),
    );
  }

  Widget _pageTitle() {
    return SizedBox(
      height: _deviceHeight * 0.12,
      child: const Text(
        'Chatify',
        style: TextStyle(
          color: Colors.white,
          fontSize: 40.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _loginForm() {
    return SizedBox(
      // height: _deviceHeight * 0.18,
      child: Form(
        key: _loginFormKey, // Used for validation
        child: Column(
          // Stretched to the maximum size that it can have
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomTextFormField(
              onSaved: (value) {
                setState(() {
                  _email = value;
                });
              },
              // Define what characters are we looking for
              regEx:
                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
              hintText: 'Email Address',
              obscureText: false,
            ),
            const SizedBox(height: 20.0),
            CustomTextFormField(
              onSaved: (value) {
                setState(() {
                  _password = value;
                });
              },
              // Define what characters are we looking for
              regEx: r".{8,}", // Must be at least 8 characters in length
              hintText: 'Password',
              obscureText: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _loginButton() {
    return RoundedButton(
      name: 'Login',
      width: _deviceWidth * 0.65,
      height: _deviceHeight * 0.065,
      onPressed: () {
        if (_loginFormKey.currentState!.validate()) {
          // We'll call the save function on both of these TextFormField
          // and the values would be saved appropriately
          log('Email: $_email, Password: $_password');
          _loginFormKey.currentState!.save();
          log('Email: $_email, Password: $_password');
          _auth.loginUsingEmailAndPassword(_email!, _password!);
        }
      },
    );
  }
}

// r'^
// (?=.*[A-Z])       // should contain at least one upper case
// (?=.*[a-z])       // should contain at least one lower case
// (?=.*?[0-9])      // should contain at least one digit
// (?=.*?[!@#\$&*~]) // should contain at least one Special character
//     .{8,}             // Must be at least 8 characters in length
// $
