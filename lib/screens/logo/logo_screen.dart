// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:shift_project/screens/login/login_screen.dart';

import '../../constants/constants.dart';


class LogoScreen extends StatefulWidget {
  const LogoScreen({super.key});

  @override
  State<LogoScreen> createState() => _LogoScreenState();
}

class _LogoScreenState extends State<LogoScreen> {
  @override
  Widget build(BuildContext context) {
    bool isLoading = true;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LoginScreen(),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: scaffoldBackground,
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 200,
                              child: logo,
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'SH',
                                    style: TextStyle(
                                      fontFamily: interFontFamily,
                                      fontSize: logoScreenTitleSize,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 10,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'I',
                                    style: TextStyle(
                                      fontFamily: interFontFamily,
                                      fontSize: logoScreenTitleSize,
                                      color: shiftRed,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 10,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'FT',
                                    style: TextStyle(
                                      fontFamily: interFontFamily,
                                      fontSize: logoScreenTitleSize,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                              visible: isLoading,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isLoading = false;
                                  });
                                },
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.blue),
                                    strokeWidth: 6.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
