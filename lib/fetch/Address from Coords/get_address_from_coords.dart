import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String?> getAddressFromCoordinates(
    double latitude, double longitude) async {
  //USING NOMINATIM
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
    print('Failed to get address: $e');
  }

  //GEOCODER_BUDDY PLUGIN NOT WORKING IDK WHY
  // try {
  //   GBLatLng position = GBLatLng(lat: latitude, lng: longitude);
  //   GBData data = await GeocoderBuddy.findDetails(position);

  //   String road = data.address.road;
  //   String street = data.address.village;
  //   String county = data.address.county;

  //   String state = data.address.state;
  //   String stateDistrict = data.address.stateDistrict;
  //   String postalCode = data.address.postcode;
  //   String country = data.address.country;

  //   String formattedAddress =
  //       '$road, $street, $county, $state, $stateDistrict, $postalCode, $country';

  //   return formattedAddress;
  // } catch (e) {
  //   print('Failed to get address: $e');
  // }

  //USING GEOCODING PLUGIN
  // try {
  //   final List<Placemark> placemarks =
  //       await placemarkFromCoordinates(latitude, longitude);
  //   final Placemark placemark = placemarks.first;
  //   final address = placemark.street ?? '';
  //   final city = placemark.locality ?? '';
  //   final state = placemark.administrativeArea ?? '';
  //   final country = placemark.country ?? '';
  //   final postalCode = placemark.postalCode ?? '';

  //   return '$address, $city, $state, $country, $postalCode';
  // } catch (e) {
  //   print('Failed to get address: $e');
  // }
  return null;
}
