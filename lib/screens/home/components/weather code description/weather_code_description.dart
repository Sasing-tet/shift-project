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

    default:
      return 'Unknown';
  }
}
