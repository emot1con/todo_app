import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo_list/provider/todo/todo_provider.dart';
import 'package:provider/provider.dart';

import 'package:flutter_todo_list/provider/auth/auth_provider.dart';
import 'package:flutter_todo_list/screen/starting_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Dio dio = Dio(
      BaseOptions(baseUrl: "http://10.0.2.2:8080/"),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(dio: dio),
        ),
        ChangeNotifierProvider(
          create: (context) => TodoProvider(dio: dio),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: const StartingScreen(),
      ),
    );
  }
}
