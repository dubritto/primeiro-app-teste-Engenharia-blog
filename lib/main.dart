import 'package:clube_da_obra/screens/home_screen.dart';
import 'package:clube_da_obra/screens/login_screen.dart';
import 'package:clube_da_obra/screens/signup_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primaryColor: Colors.blueAccent
      ),
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}