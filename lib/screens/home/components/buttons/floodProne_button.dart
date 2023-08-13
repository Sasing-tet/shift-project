import 'package:flutter/material.dart';
import 'package:shift_project/screens/floodProneDataScreen/flood_prone_area_screen.dart';

class FloodProneButton extends StatelessWidget {
  const FloodProneButton({super.key});

  @override
  Widget build(BuildContext context) {
    return  Container(
                  margin: const EdgeInsets.only(
                    bottom: 12,
                    left: 15,
                  ),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 241, 197, 0),
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
                      Icons.warning_rounded,
                      size: 35,
                    ),
                    onPressed: () {
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (context) => const FloodProneScreen(),
                      //   ),
                      // );
                    },
                  ),
                );
  }
}