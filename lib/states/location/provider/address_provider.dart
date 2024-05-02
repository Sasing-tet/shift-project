import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod/riverpod.dart';

import 'curr_location_provider.dart';

final addressProvider = FutureProvider.autoDispose<String?>((ref) async {
  final currentPosition = ref.watch(currentPositionProvider);

  return getAddressFromCoordinates(
      currentPosition.latitude, currentPosition.longitude);
});

Future<String?> getAddressFromCoordinates(
    double latitude, double longitude) async {
  // final position = await Geolocator.getCurrentPosition(
  //   desiredAccuracy: LocationAccuracy.high,
  // );
  // final latitude = position.latitude;
  // final longitude = position.longitude;
  final url =
      'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude';

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonResult = jsonDecode(response.body);
      final address = jsonResult['display_name'];
      print('Address: $address');
      return address;
    }
  } catch (e) {
    print('Error fetching address: $e');
    return null;
  }
  return null;
}

Future<String?> getCityFromCoordinates(
    double latitude, double longitude) async {
  final url =
      'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude';

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonResult = jsonDecode(response.body);
      final address = jsonResult['address']['city'];
      print('TESTING AAAAAAAAAA: ${jsonResult.toString()}');
      return address;
    }
  } catch (e) {
    Exception('Failed to get address: $e');
  }
  return null;
}
