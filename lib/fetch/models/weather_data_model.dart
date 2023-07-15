class WeatherData {
  final double currentTemperature;
  final String currentWeatherUnit;
  final List<String> hourlyForecastTime;
  final List<double> hourlyForecastTemperature;
  final List<double> hourlyForecastRain;

  WeatherData({
    required this.currentTemperature,
    required this.currentWeatherUnit,
    required this.hourlyForecastTime,
    required this.hourlyForecastTemperature,
    required this.hourlyForecastRain,
  });
}
