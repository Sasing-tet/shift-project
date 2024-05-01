import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riverpod/riverpod.dart';

import 'curr_location_provider.dart';

final addressProvider = FutureProvider.autoDispose<String?>((ref) async {
  final currentPosition = ref.watch(currentPositionProvider);
  return getAddressFromCoordinates(
      currentPosition.latitude, currentPosition.longitude);
});

Future<String> getAddressFromCoordinates(
    double latitude, double longitude) async {
  final url =
      'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude';

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonResult = jsonDecode(response.body);
      final address = jsonResult['display_name'];
      return address;
    }
  } catch (e) {
    Exception('Failed to get address: $e');
  }
  return 'Failed to fetch address';
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
      return address;
    }
  } catch (e) {
    Exception('Failed to get address: $e');
  }
  return null;
}
