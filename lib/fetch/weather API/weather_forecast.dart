import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shift_project/screens/home/notifier/operation_notifier.dart';

import '../../screens/home/components/weather code description/weather_code_description.dart';
import '../../states/weather/models/hourly_weather_data_model.dart';
import '../../states/weather/models/weather_data_model.dart';


Future<WeatherData> fetchWeatherData(double latitude, double longitude, OpsNotifier opsNotifier) async {
  final dio = Dio();
  final position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  final latitude = position.latitude;
  final longitude = position.longitude;

  final response = await dio.get(
    'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&hourly=temperature_2m,weathercode&current_weather=true&forecast_days=1',
  );

  if (response.statusCode == 200) {
    final data = response.data;

    final currentTemperature = data['current_weather']['temperature'];
    final currentWeatherCode = data['current_weather']['weathercode'];
    final currentWeatherUnit = data['hourly_units']['temperature_2m'];

    final hourlyForecastTime = List<String>.from(data['hourly']['time']);
    final hourlyForecastTemp =
        List<double>.from(data['hourly']['temperature_2m']);
    final hourlyForecastWeatherCode =
        List<int>.from(data['hourly']['weathercode']);

    final hourlyWeatherDataList =
        List<HourlyWeatherData>.generate(hourlyForecastTime.length, (index) {
      return HourlyWeatherData(
        time: hourlyForecastTime[index],
        temperature: hourlyForecastTemp[index],
        weatherCode: hourlyForecastWeatherCode[index],
        weatherDescription:
            getWeatherDescription(hourlyForecastWeatherCode[index]),
      );
    });

    final weatherData = WeatherData(
      currentTemperature: currentTemperature,
      currentWeatherUnit: currentWeatherUnit,
      currentWeatherCode: currentWeatherCode,
      hourlyWeatherDataList: hourlyWeatherDataList,
    );
    // final currentWeather = data['current_weather']['temperature'];
    // final currentWeatherUnit = data['hourly_units']['temperature_2m'][0];
    // final hourlyForecastTime = List<String>.from(data['hourly']['time']);
    // final hourlyForecastTemp =
    //     List<double>.from(data['hourly']['temperature_2m']);
    // final hourlyForecastRain = List<double>.from(data['hourly']['rain']);

    // final weatherData = WeatherData(
    //   currentTemperature: currentWeather,
    //   currentWeatherUnit: currentWeatherUnit,
    //   hourlyForecastTime: hourlyForecastTime,
    //   hourlyForecastTemperature: hourlyForecastTemp,
    //   hourlyForecastRain: hourlyForecastRain,
    // );
    print(data);
    opsNotifier.addWeatherData(weatherData );
    return weatherData;
  } else {
    throw Exception('Failed to fetch weather data: ${response.statusCode}');
  }
}

//INITIAL WEATHER DATA FETCH IMPLEMENTATION FOR REFERENCE
// Future<void> fetchWeatherData1(double latitude, double longitude) async {
//   final dio = Dio();
//   // final position = await Geolocator.getCurrentPosition(
//   //   desiredAccuracy: LocationAccuracy.high,
//   // );
//   // final latitude = position.latitude;
//   // final longitude = position.longitude;
//   final response1 = await dio.get(
//     'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&hourly=temperature_2m,rain,showers',
//   );
//   final response = await dio.get(
//     'https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.419&hourly=temperature_2m,rain,showers',
//   );

//   if (response.statusCode == 200) {
//     final data = response.data;
//     // Process the weather forecast data

//     final currentWeather = data['hourly']['temperature_2m'][0];
//     final hourlyForecastTime = data['hourly']['time'];
//     final hourlyForecastTemp = data['hourly']['temperature_2m'];
//     final hourlyForecastRain = data['hourly']['rain'];

//     // Process the current weather and hourly forecast data
//     print(data);
//     print('Current Weather: $currentWeather');
//     print('Hourly Forecast Time: $hourlyForecastTime');
//     print('Hourly Forecast Temperatures: $hourlyForecastTemp');
//     print('Hourly Forecast Rain: $hourlyForecastRain');
//   } else {
//     print('Failed to fetch weather data: ${response.statusCode}');
//   }
// }
