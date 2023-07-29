import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constants/constants.dart';
import '../../../fetch/models/hourly_weather_data_model.dart';
import 'weather code description/weather_code_description.dart';

class HourlyWeatherForcastWidget extends StatelessWidget {
  final List<HourlyWeatherData> hourlyWeatherDataList;
  const HourlyWeatherForcastWidget(
      {super.key, required this.hourlyWeatherDataList});

  @override
  Widget build(BuildContext context) {
    final currentHour = DateTime.now().hour;

    final filteredList = hourlyWeatherDataList.where((item) {
      final itemHour = DateTime.parse(item.time).hour;
      return itemHour >= currentHour;
    }).toList();

    final timeFormat = DateFormat.jm();

    return Padding(
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
        bottom: 10,
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: shiftGrayBorder,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filteredList.map((item) {
              final parsedTime = DateTime.parse(item.time);
              final formattedTime = timeFormat.format(parsedTime);
              final icon = getWeatherIcon(item.weatherCode);
              final temperature = item.temperature;

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(formattedTime),
                    SizedBox(height: 8),
                    icon,
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text('$temperature°C'),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
