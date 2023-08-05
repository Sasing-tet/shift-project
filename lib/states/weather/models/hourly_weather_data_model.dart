class HourlyWeatherData {
  final String time;
  final double temperature;
  final int weatherCode;
  final String weatherDescription;

  HourlyWeatherData({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.weatherDescription,
  });
}
