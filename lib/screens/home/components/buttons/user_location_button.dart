import 'package:flutter/material.dart';

class UserLocationButton extends StatelessWidget {
  const UserLocationButton({super.key, required this.onPressed});
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return   Container(
                  margin: EdgeInsets.only(
                    bottom: 12,
                    left: 15,
                  ),
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.my_location,
                      size: 35,
                    ),
                    onPressed: onPressed,
                  ),
                );
  }
}