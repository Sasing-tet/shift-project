import 'package:flutter/material.dart';

import '../../../../../constants/constants.dart';

class RouteOptionWidget extends StatelessWidget {
  final int i;
  final bool isAlternative;
  final String score;
  final  String weatherBasedScore;
  const RouteOptionWidget({
    super.key,
    required this.i,
    required this.isAlternative,
    required this.score, 
    required this.weatherBasedScore,
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
           Text(
            "Weather based Score: $weatherBasedScore",
            style: const TextStyle(
              overflow: TextOverflow.ellipsis,
              color: shiftGrayBorder,
              fontFamily: interFontFamily,
              fontSize: defaultFontSize,
            ),
          ),
          Text(
            "Total Score: $score",
            style: const TextStyle(
              overflow: TextOverflow.ellipsis,
              color: shiftGrayBorder,
              fontFamily: interFontFamily,
              fontSize: defaultFontSize,
            ),
          ),
        ],
      ),
    );
  }
}