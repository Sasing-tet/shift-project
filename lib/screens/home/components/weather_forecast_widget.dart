import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:marquee/marquee.dart';

import '../../../constants/constants.dart';
import '../../../fetch/Address from Coords/get_address_from_coords.dart';
import '../../../fetch/models/weather_data_model.dart';
import '../../../fetch/weather API/weather_forecast.dart';

class WeatherForecastWidget extends StatefulWidget {
  const WeatherForecastWidget({super.key});

  @override
  State<WeatherForecastWidget> createState() => _WeatherForecastWidgetState();
}

class _WeatherForecastWidgetState extends State<WeatherForecastWidget> {
  LatLng? currentPosition;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    final position = await Geolocator.getCurrentPosition();

    setState(() {
      currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WeatherData>(
      future: fetchWeatherData(
          currentPosition?.latitude ?? 0.0, currentPosition?.longitude ?? 0.0),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Text('Failed to fetch weather data');
        } else {
          final weatherData = snapshot.data!;
          return FutureBuilder<String?>(
            future: getAddressFromCoordinates(
              currentPosition?.latitude ?? 0.0,
              currentPosition?.longitude ?? 0.0,
            ),
            builder: (context, addressSnapshot) {
              if (addressSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (addressSnapshot.hasError) {
                return const Text('Failed to fetch address');
              } else {
                final address = addressSnapshot.data ?? 'Unknown Address';
                return Row(
                  children: [
                    Flexible(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              '${weatherData.currentTemperature}${weatherData.currentWeatherUnit}',
                              style: const TextStyle(
                                fontSize: titleFontSize,
                                fontFamily: interFontFamily,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                              child: Marquee(
                                text: address,
                                style: const TextStyle(
                                  fontSize: titleSubtitleFontSize,
                                  fontFamily: interFontFamily,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                scrollAxis: Axis.horizontal,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                blankSpace: 20.0,
                                velocity: 30.0,
                                pauseAfterRound: const Duration(seconds: 1),
                                startPadding: 10.0,
                                accelerationDuration:
                                    const Duration(seconds: 1),
                                accelerationCurve: Curves.linear,
                                decelerationDuration:
                                    const Duration(seconds: 2),
                                decelerationCurve: Curves.easeOut,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Flexible(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.thunderstorm,
                              size: 40,
                              color: Colors.blue,
                            ),
                            SizedBox(
                              height: 18,
                              child: Marquee(
                                text: 'Heavy Rain',
                                style: const TextStyle(
                                  fontSize: titleSubtitleFontSize,
                                  fontFamily: interFontFamily,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                scrollAxis: Axis.horizontal,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                blankSpace: 20.0,
                                velocity: 10.0,
                                pauseAfterRound: const Duration(seconds: 1),
                                startPadding: 10.0,
                                accelerationDuration:
                                    const Duration(seconds: 1),
                                accelerationCurve: Curves.linear,
                                decelerationDuration:
                                    const Duration(seconds: 2),
                                decelerationCurve: Curves.easeOut,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          );
        }
      },
    );
  }
}
