import 'package:flutter/material.dart';
import 'package:shift_project/constants/constants.dart';

class LoginLogo extends StatelessWidget {
  const LoginLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 125,
            child: logo,
          ),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'SH',
                  style: TextStyle(
                    fontFamily: interFontFamily,
                    fontSize: loginScreenTitleSize,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 10,
                  ),
                ),
                TextSpan(
                  text: 'I',
                  style: TextStyle(
                    fontFamily: interFontFamily,
                    fontSize: loginScreenTitleSize,
                    color: shiftRed,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 10,
                  ),
                ),
                TextSpan(
                  text: 'FT',
                  style: TextStyle(
                    fontFamily: interFontFamily,
                    fontSize: loginScreenTitleSize,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
