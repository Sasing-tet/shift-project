import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0), // Adjust the radius as needed
        ),
        padding: const EdgeInsets.all(24.0), // Adjust padding as needed
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/images/loading.json', // Replace with your Lottie animation asset
              width: 100,
              height: 100,
              // Other parameters as needed
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Calculating the route',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
