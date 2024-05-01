import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:marquee/marquee.dart';
import 'package:shift_project/screens/home/home_widgets/components/buttons/refresh_button.dart';
import 'package:shift_project/screens/home/home_widgets/components/hourly_weather_forcase_widget.dart';
import 'package:shift_project/screens/home/home_provider/notifier/operation_notifier.dart';
import '../../../../constants/constants.dart';
import '../../../../fetch/weather API/weather_forecast.dart';
import '../../../../states/location/provider/address_provider.dart';
import '../../../../states/location/provider/curr_location_provider.dart';
import '../../../../states/weather/models/weather_data_model.dart';
import 'weather code description/weather_code_description.dart';

class WeatherForecastWidget extends ConsumerStatefulWidget {
  const WeatherForecastWidget({super.key, required this.opsProvider});
  final OpsNotifier opsProvider;

  @override
  ConsumerState<WeatherForecastWidget> createState() =>
      _WeatherForecastWidgetState();
}

class _WeatherForecastWidgetState extends ConsumerState<WeatherForecastWidget> {
  LatLng? currentPosition;

  void _refreshAppBar() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // fetchWeatherData(
    //   currentPosition?.latitude ?? 0.0,
    //   currentPosition?.longitude ?? 0.0,
    //   widget.opsProvider,
    // );
    _fetchData();
  }

  void _fetchData() async {
    final currentPosition = ref.read(currentPositionProvider);
    await fetchWeatherData(
      currentPosition.latitude,
      currentPosition.longitude,
      widget.opsProvider,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentPosition = ref.watch(currentPositionProvider);

    return FutureBuilder<WeatherData>(
      future: fetchWeatherData(currentPosition.latitude,
          currentPosition.longitude, widget.opsProvider),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
            ],
          );
        } else if (snapshot.hasError) {
          return const Text('Failed to fetch weather data');
        } else {
          final weatherData = snapshot.data!;
          return FutureBuilder<String>(
            future: getAddressFromCoordinates(
              currentPosition.latitude,
              currentPosition.longitude,
            ),
            builder: (context, addressSnapshot) {
              if (addressSnapshot.connectionState == ConnectionState.waiting) {
                return const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                  ],
                );
              } else if (addressSnapshot.hasError) {
                return const Text('Failed to fetch address');
              } else {
                final address = addressSnapshot.data ?? 'Unknown Address';
                return ExpansionTile(
                  backgroundColor: Colors.transparent,
                  title: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${weatherData.currentTemperature}${weatherData.currentWeatherUnit}',
                                    style: const TextStyle(
                                      fontSize: titleFontSize,
                                      fontFamily: interFontFamily,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  RefreshButton(
                                    onPressed: _refreshAppBar,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 22,
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
                        width: 10,
                      ),
                    ],
                  ),
                  trailing: SizedBox(
                    width: 60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 35,
                          height: 35,
                          child: getWeatherIcon(
                            weatherData.hourlyWeatherDataList[0].weatherCode,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                          child: Marquee(
                            text: weatherData
                                .hourlyWeatherDataList[0].weatherDescription,
                            style: const TextStyle(
                              fontSize: titleSubtitleFontSize,
                              fontFamily: interFontFamily,
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.normal,
                            ),
                            scrollAxis: Axis.horizontal,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            blankSpace: 20.0,
                            velocity: 10.0,
                            pauseAfterRound: const Duration(seconds: 1),
                            startPadding: 0,
                            accelerationDuration: const Duration(seconds: 1),
                            accelerationCurve: Curves.linear,
                            decelerationDuration: const Duration(seconds: 2),
                            decelerationCurve: Curves.easeOut,
                          ),
                        ),
                      ],
                    ),
                  ),
                  children: [
                    HourlyWeatherForcastWidget(
                      hourlyWeatherDataList: weatherData.hourlyWeatherDataList,
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
