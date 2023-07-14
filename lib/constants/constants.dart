import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
const Color shiftBlack = Color(0xFF1E232C);
const Color shiftGrayBorder = Color(0xFF888888);

final ButtonStyle chooseDestination = TextButton.styleFrom(
  minimumSize: Size(double.infinity, 40),
  padding: EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(2)),
  ),
);
