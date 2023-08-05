import 'hourly_weather_data_model.dart';

class WeatherData {
  final double currentTemperature;
  final int currentWeatherCode;
  final String currentWeatherUnit;
  final List<HourlyWeatherData> hourlyWeatherDataList;

  WeatherData({
    required this.currentTemperature,
    required this.currentWeatherUnit,
    required this.currentWeatherCode,
    required this.hourlyWeatherDataList,
  });
}
// class WeatherData {
//   final double currentTemperature;
//   final String currentWeatherUnit;
//   final List<String> hourlyForecastTime;
//   final List<double> hourlyForecastTemperature;
//   final List<double> hourlyForecastRain;

//   WeatherData({
//     required this.currentTemperature,
//     required this.currentWeatherUnit,
//     required this.hourlyForecastTime,
//     required this.hourlyForecastTemperature,
//     required this.hourlyForecastRain,
//   });
// }
