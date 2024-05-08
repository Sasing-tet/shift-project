import 'package:flutter/material.dart';

import '../../../../../constants/constants.dart';

class RouteOptionWidget extends StatelessWidget {
  final int i;
  final bool isAlternative;
  final String score;

  const RouteOptionWidget({
    super.key,
    required this.i,
    required this.isAlternative,
    required this.score, 
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.symmetric(
        horizontal: 5,
      ),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: shiftGrayBorder,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            isAlternative ? "Alternative" : "Route ${i + 1}",
            style: const TextStyle(
              color: Colors.black,
              fontFamily: interFontFamily,
              fontSize: titleSubtitleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
           const Text(
            "Risk Level:",
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
              color: shiftGrayBorder,
              fontFamily: interFontFamily,
              fontSize: defaultFontSize-3,
            ),
          ),
          Text(
            score,
            style:  TextStyle(
              overflow: TextOverflow.ellipsis,
              color: _getColorBasedOnRiskLevel(score),
              fontFamily: interFontFamily,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

Color _getColorBasedOnRiskLevel(String riskLevel) {
  switch (riskLevel) {
    case 'Low':
      return Colors.green; // Bright green for low risk
    case 'Medium':
      return Colors.yellow; // Yellow for medium risk
    case 'High':
      return Colors.red; // Red for high risk
    default:
      return const Color.fromARGB(255, 3, 228, 160); // Default color for other cases
  }
}