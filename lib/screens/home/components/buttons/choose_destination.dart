import 'package:flutter/material.dart';
import 'package:shift_project/constants/constants.dart';

class ChooseDestinationButton extends StatelessWidget {
  const ChooseDestinationButton({super.key, this.onPressed});
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Builder(builder: (ctx) {
        return TextButton(
          style: chooseDestination,
          onPressed: onPressed,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pin_drop_rounded,
                size: 25,
                color: Colors.redAccent,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                'Choose Destination',
                style: TextStyle(
                  fontFamily: interFontFamily,
                  fontSize: titleSubtitleFontSize,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
