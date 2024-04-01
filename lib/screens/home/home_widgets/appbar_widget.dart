// app_bar_widget.dart

import 'package:flutter/material.dart';
import 'package:shift_project/screens/home/components/weather_forecast_widget.dart';
import 'package:shift_project/screens/home/notifier/operation_notifier.dart';

class MyAppBar extends StatelessWidget {
  const MyAppBar( {super.key, required this.opsNotifier});
  final OpsNotifier opsNotifier;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Builder(builder: (context) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
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
                icon: const Icon(Icons.menu_sharp),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                iconSize: 30,
              ),
            ),
            // WEATHER WIDGET
            Expanded(
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 90,
                ),
                margin: const EdgeInsets.only(
                  top: 10,
                  right: 10,
                  bottom: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: WeatherForecastWidget( opsProvider: opsNotifier,),
              ),
            ),
          ],
        );
      }),
    );
  }
}
