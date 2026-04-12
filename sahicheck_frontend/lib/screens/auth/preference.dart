import 'package:flutter/material.dart';
import 'package:sahicheck_frontend/screens/auth/login_screen.dart';
import 'package:sahicheck_frontend/screens/auth/register_screen.dart';

class Preference extends StatefulWidget {
  const Preference({super.key});

  @override
  State<Preference> createState() => _PreferenceState();
}

class _PreferenceState extends State<Preference> {
  bool loginScreen = true;

  void toogleScreen() {
    setState(() {
      loginScreen = !loginScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loginScreen) {
      return LoginScreen(toggleScreen: toogleScreen);
    } else {
      return RegisterScreen(toggleScreen: toogleScreen);
    }
  }
}
