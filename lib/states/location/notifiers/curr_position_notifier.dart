import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:riverpod/riverpod.dart';

import '../provider/address_provider.dart';

class CurrentPositionNotifier extends StateNotifier<CurrentPosition> {
  StreamSubscription<Position>? _positionStreamSubscription;
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    // By City Update
    // distanceFilter: 2, 
    distanceFilter: 200,
  );
  // bool isWeatherUpdated = true;
  String? lastFetchedCity;

  CurrentPositionNotifier() : super(CurrentPosition.unknown()) {
    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) async {
      if (position != null) {
        final address =
            await getCityFromCoordinates(position.latitude, position.longitude);
            state = CurrentPosition(
              latitude: position.latitude,
              longitude: position.longitude,
              lastCity: address,
              currentCity: address,
          );
        // By City update
        // if (state.lastCity == '' && state.currentCity == '') {
        //   state = CurrentPosition(
        //       latitude: position.latitude,
        //       longitude: position.longitude,
        //       lastCity: address,
        //       currentCity: address,
        //   );
        // }
        // if (address != lastFetchedCity) {
        //   lastFetchedCity = address;
        //   state = CurrentPosition(
        //     latitude: position.latitude,
        //     longitude: position.longitude,
        //     lastCity: state.currentCity,
        //     currentCity: address,
        //   );
        // }
      } else {
        // final city = await getAddressFromCoordinates(state.latitude, state.longitude);

        // _container.read(newCityProvider.notifier).updateCity(city);
        // debugPrint(NewCityNotifier().state.toString());
        // state = CurrentPosition.unknown();
      }
    });
  }

  // void updateCity(bool weatherUpdated) {
  //   state = CurrentPosition(
  //       latitude: state.latitude,
  //       longitude: state.longitude,
  //       lastCity: state.currentCity,
  //       currentCity: state.currentCity,
  //       isWeatherUpdated: false);
  // }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
}

class CurrentPosition {
  final double latitude;
  final double longitude;
  final String? lastCity;
  final String? currentCity;

  CurrentPosition({
    required this.latitude,
    required this.longitude,
    this.lastCity = '',
    this.currentCity = '',
  });

  CurrentPosition.unknown()
      : latitude = 0,
        longitude = 0,
        lastCity = '',
        currentCity = '';
}
