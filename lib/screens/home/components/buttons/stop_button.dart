import 'package:flutter/material.dart';
import 'package:shift_project/constants/constants.dart';

class StopButton extends StatelessWidget {
  const StopButton({super.key, this.onTap});
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: shiftRed,
            borderRadius: BorderRadius.circular(10),
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
              "Stop",
              style: TextStyle(
                color: Colors.white,
                fontFamily: interFontFamily,
                fontSize: titleSubtitleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
