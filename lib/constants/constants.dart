import 'package:flutter/material.dart';

const scaffoldBackground = BoxDecoration(
  image: DecorationImage(
    image: AssetImage("assets/images/shift bg 1.png"),
    fit: BoxFit.fill,
  ),
);

const drawerBackground = BoxDecoration(
  image: DecorationImage(
    image: AssetImage("assets/images/shift bg 1.png"),
    fit: BoxFit.cover,
    alignment: Alignment.topCenter,
  ),
);
Image logo = Image.asset('assets/images/shift logo transparent.png');
Image facebookLogo = Image.asset('assets/images/fb login logo.png');
Image googleLogo = Image.asset('assets/images/google login logo.png');
Image githubLogo = Image.asset('assets/images/github login logo.png');

const String interFontFamily = 'Inter';

const double defaultFontSize = 14.0;
const double defaultSubtitleFontSize = 12.0;
const double titleFontSize = 28.0;
const double titleSubtitleFontSize = 16.0;

const double loginScreenTitleSize = 50.00;
const double logoScreenTitleSize = 70.00;

const Color shiftRed = Color(0xFFFD3C3B);
const Color shiftBlue = Color(0xFF071A52);
const Color shiftBlack = Color(0xFF1E232C);
const Color shiftGrayBorder = Color(0xFF888888);

final ButtonStyle chooseDestination = TextButton.styleFrom(
  minimumSize: const Size(double.infinity, 40),
  padding: const EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(2)),
  ),
);

TextTheme constTextTheme() {
  return const TextTheme(
    headlineLarge: TextStyle(
      fontFamily: 'Inter Bold',
      fontSize: 30,
      height: 1.2,
      color: Colors.white,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Inter Medium',
      fontSize: 22,
      height: 1.2,
      color: Colors.white,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Inter Light',
      fontSize: 15,
      height: 1.2,
      color: Colors.white,
    ),
    displayMedium: TextStyle(
      fontFamily: 'Inter Light',
      height: 1.2,
      fontSize: 22,
      color: Colors.white,
    ),
    displaySmall: TextStyle(
      fontFamily: 'Inter Medium',
      fontSize: 15,
      height: 1.2,
      color: Colors.white,
    ),
  );
}

final ThemeData constElevatedButtonTheme = ThemeData(
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(
        const Color(0XFF001c52),
      ),
      foregroundColor: MaterialStateProperty.all<Color>(
        Colors.white,
      ),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
  ),
);
