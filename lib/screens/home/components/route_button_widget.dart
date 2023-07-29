import 'package:flutter/material.dart';

import '../../../constants/constants.dart';

class RouteOptionWidget extends StatelessWidget {
  final int i;
  const RouteOptionWidget({
    super.key, required this.i,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: EdgeInsets.symmetric(
        horizontal: 5,
      ),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: shiftGrayBorder,
        ),
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            "Route ${i+1}",
            style: TextStyle(
              color: Colors.black,
              fontFamily: interFontFamily,
              fontSize:
                  titleSubtitleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Text(
          //   "via this street churva churva",
          //   style: TextStyle(
          //     overflow:
          //         TextOverflow.ellipsis,
          //     color: shiftGrayBorder,
          //     fontFamily: interFontFamily,
          //     fontSize: defaultFontSize,
          //   ),
          // ),
        ],
      ),
    );
  }
}
