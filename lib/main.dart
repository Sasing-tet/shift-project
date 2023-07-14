import 'package:flutter/material.dart';
import 'package:shift_project/screens/home/home_screen.dart';
import 'package:shift_project/screens/login/login_screen.dart';
import 'package:shift_project/screens/logo/logo_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const LogoScreen(),
    );
  }
}
