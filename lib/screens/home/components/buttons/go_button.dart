import 'package:flutter/material.dart';
import 'package:shift_project/constants/constants.dart';

class GoButton extends StatelessWidget {
  const GoButton({super.key, this.onTap});
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        decoration: BoxDecoration(
          color: shiftBlue,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            "Go",
            style: TextStyle(
              color: Colors.white,
              fontFamily: interFontFamily,
              fontSize: titleSubtitleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
