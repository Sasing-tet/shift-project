import 'package:flutter/material.dart';

class ReturnFloodProneButton extends StatelessWidget {
  const ReturnFloodProneButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
        left: 15,
      ),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xffd1455c),
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
          color: Colors.white,
          Icons.arrow_back_outlined,
          size: 35,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
