 import 'package:flutter/material.dart';
import 'package:flutter_todo_list/screen/auth/login_screen.dart';
import 'package:flutter_todo_list/screen/todo/main_screen.dart';

void toMainScreen(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MainScreen(),
      ),
    );
  }

  void toLoginScreen(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }
