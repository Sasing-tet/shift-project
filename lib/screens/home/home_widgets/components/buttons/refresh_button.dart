import 'package:flutter/material.dart';

class RefreshButton extends StatelessWidget {
  const RefreshButton({Key? key, required this.onPressed}) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.refresh,
        color: Colors.black.withOpacity(0.5),
        size: 22,
      ),
      onPressed: onPressed,
    );
  }
}
