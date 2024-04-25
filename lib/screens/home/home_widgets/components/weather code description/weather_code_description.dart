import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../constants/constants.dart';

String getWeatherDescription(int weatherCode) {
  switch (weatherCode) {
    case 0:
      return 'Clear Sky';
    case 1:
      return 'Mainly Clear';
    case 2:
      return 'Partly Cloudy';
    case 3:
      return 'Overcast';
    case 45:
      return 'Fog';
    case 48:
      return 'Depositing Rime Fog';
    case 51:
      return 'Drizzle: Light Intensity';
    case 53:
      return 'Drizzle: Moderate Intensity';
    case 55:
      return 'Drizzle: Dense Intensity';
    case 56:
      return 'Freezing Drizzle: Light';
    case 57:
      return 'Freezing Drizzle: Dense Intensity';
    case 61:
      return 'Rain: Slight Intensity';
    case 63:
      return 'Rain: Moderate Intensity';
    case 65:
      return 'Rain: Heavy Intensity';
    case 66:
      return 'Freezing Rain: Light Intensity';
    case 67:
      return 'Freezing Rain: Heavy Intensity';
    case 80:
      return 'Rain Showers: Slight';
    case 81:
      return 'Rain Showers: Moderate';
    case 82:
      return 'Rain showers: Violent';
    case 95:
      return 'Thunderstorm';
    case 96:
      return 'Thunderstorm: slight hail';
    case 99:
      return 'Thunderstorm: heavy hail';

    default:
      return 'Unknown';
  }
}

FaIcon getWeatherIcon(int weatherCode) {
  switch (weatherCode) {
    case 0:
      return const FaIcon(
        FontAwesomeIcons.solidSun,
        size: 25,
        color: shiftBlue,
      );
    case 1:
      return const FaIcon(
        FontAwesomeIcons.cloudSun,
        size: 25,
        color: shiftBlue,
      );
    case 2:
      return const FaIcon(
        FontAwesomeIcons.cloud,
        size: 25,
        color: shiftBlue,
      );
    case 3:
      return const FaIcon(
        FontAwesomeIcons.cloud,
        size: 25,
        color: shiftBlue,
      );
    case 45:
      return const FaIcon(
        FontAwesomeIcons.smog,
        size: 25,
        color: shiftBlue,
      );
    case 48:
      return const FaIcon(
        FontAwesomeIcons.cloud,
        size: 25,
        color: shiftBlue,
      );
    case 51:
      return const FaIcon(
        FontAwesomeIcons.droplet,
        size: 25,
        color: shiftBlue,
      );
    case 53:
      return const FaIcon(
        FontAwesomeIcons.droplet,
        size: 25,
        color: shiftBlue,
      );
    case 55:
      return const FaIcon(
        FontAwesomeIcons.cloudRain,
        size: 25,
        color: shiftBlue,
      );
    case 56:
      return const FaIcon(
        FontAwesomeIcons.snowflake,
        size: 25,
        color: shiftBlue,
      );
    case 57:
      return const FaIcon(
        FontAwesomeIcons.snowflake,
        size: 25,
        color: shiftBlue,
      );
    case 61:
      return const FaIcon(
        FontAwesomeIcons.cloudShowersHeavy,
        size: 25,
        color: shiftBlue,
      );
    case 63:
      return const FaIcon(
        FontAwesomeIcons.cloudShowersHeavy,
        size: 25,
        color: shiftBlue,
      );
    case 65:
      return const FaIcon(
        FontAwesomeIcons.cloudShowersHeavy,
        size: 25,
        color: shiftBlue,
      );
    case 66:
      return const FaIcon(
        FontAwesomeIcons.cloudShowersHeavy,
        size: 25,
        color: shiftBlue,
      );
    case 67:
      return const FaIcon(
        FontAwesomeIcons.cloudShowersHeavy,
        size: 25,
        color: shiftBlue,
      );
    case 80:
      return const FaIcon(
        FontAwesomeIcons.cloudRain,
        size: 25,
        color: shiftBlue,
      );
    case 81:
      return const FaIcon(
        FontAwesomeIcons.cloudRain,
        size: 25,
        color: shiftBlue,
      );
    case 82:
      return const FaIcon(
        FontAwesomeIcons.cloudRain,
        size: 25,
        color: shiftBlue,
      );
    case 95:
      return const FaIcon(
        FontAwesomeIcons.cloudBolt,
        size: 25,
        color: shiftBlue,
      );
    case 96:
      return const FaIcon(
        FontAwesomeIcons.cloudRain,
        size: 25,
        color: shiftBlue,
      );
    case 99:
      return const FaIcon(
        FontAwesomeIcons.cloudRain,
        size: 25,
        color: shiftBlue,
      );

    default:
      return const FaIcon(Icons.help);
  }
}
