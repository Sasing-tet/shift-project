import 'package:flutter/material.dart';
import 'package:shift_project/constants/constants.dart';

class ClearButton extends StatelessWidget {
  const ClearButton({super.key, this.onPressed});

  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
                                margin: const EdgeInsets.only(
                                  left: 15,
                                ),
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: shiftRed,
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.location_pin,
                                    size: 35,
                                    color: Colors.white,
                                  ),
                                  onPressed: onPressed,
                                ),
                              );
  }
}