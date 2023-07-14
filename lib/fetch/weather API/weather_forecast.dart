import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() async {
  final dio = Dio();
  final position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  final latitude = position.latitude;
  final longitude = position.longitude;

  final response = await dio.get(
    'https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&hourly=temperature_2m,rain,showers',
  );

  if (response.statusCode == 200) {
    final data = response.data;
    // Process the weather forecast data
    Text(data);
  } else {
    Text('Failed to fetch weather data: ${response.statusCode}');
  }
}
