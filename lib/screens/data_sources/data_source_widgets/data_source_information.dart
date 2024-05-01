import 'package:flutter/material.dart';
import 'package:shift_project/screens/data_sources/data_source_widgets/data_source_shift_logo.dart';

class DataSourceInformation extends StatelessWidget {
  const DataSourceInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const DataSourceShiftLogo(),
                    Image.asset(
                      'assets/images/noah_logo.png',
                      width: 120,
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Flood Data Source",
                        style: TextStyle(
                          fontFamily: 'Inter Medium',
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Text(
                        "We extend our sincere gratitude to the University of the Philippines Nationwide Operational Assessment of Hazards (UP NOAH) for providing invaluable flood zone data used in this application. By leveraging UP NOAH's data, we were able to create an application that can be used by many as an effective navigation system in co-relation to flooded Areas within Cebu.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontFamily: 'Inter Medium',
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
