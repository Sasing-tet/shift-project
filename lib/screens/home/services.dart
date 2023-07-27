
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:http/http.dart' as http;

class Ops{

    static Future<void> drawRoadManually(List<String> encodedPolylines, MapController mapController) async {
    for (var i = 0; i < encodedPolylines.length; i++) {
      final encoded = encodedPolylines[i];
      final list = await encoded.toListGeo();
      debugPrint(list.toString());
      final roadOption = i == 0
          ? RoadOption(
              roadColor: Color.fromARGB(181, 71, 19, 16),
              roadWidth: 8,
            ) // Full opacity for the first polyline
          : RoadOption(
              roadColor: Colors.red, roadWidth: 8); // 80% opacity for the rest

      await mapController.drawRoadManually(list, roadOption);
    }
  }

  static Future<List<String>> fetchOSRMRoutePolylines(
      List<GeoPoint> coordinates) async {
    final String profile = 'driving';
    final String coordinatesString = coordinates
        .map((coord) => '${coord.longitude},${coord.latitude}')
        .join(';');

    final String url =
        'https://router.project-osrm.org/route/v1/$profile/$coordinatesString?alternatives=true&steps=true&geometries=polyline&overview=full&annotations=false';

    final response = await http.get(Uri.parse(url));
    List<String> polylines = [];

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      List routes = map["routes"];

      for (var route in routes) {
        var geometry = route['geometry'];
        geometry != " " ? polylines.add(geometry) : geometry.clear();
      }
      print(polylines.toString());
      return polylines;
    } else {
      throw Exception('Failed to fetch route polylines');
    }
  }

  static Future<List<String>> getDirections(
      GeoPoint start, GeoPoint destination) async {
    final String startCoords = '${start.latitude},${start.longitude}';
    final String destinationCoords =
        '${destination.latitude},${destination.longitude}';

    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$startCoords&destination=$destinationCoords&mode=driving&alternatives=true&key=AIzaSyBEUySx7hdG0n111W7NPXD9C8wLWFAqdjo';

    final response = await http.get(Uri.parse(url));
    List<String> polylines = [];

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      List routes = map["routes"];

      for (var i = 0; i < routes.length; i++) {
        var route = routes[i];
        var polyline = route["overview_polyline"]["points"];
        polyline != " " ? polylines.add(polyline) : polyline.clear();
      }
    } else {
      print('Failed to load directions');
    }
    print(polylines.toString());
    return polylines;
  }



  static Future<void> drawCircle(MapController mapController) async {
    final circle = CircleOSM(
      key: 'circle1',
      centerPoint: GeoPoint(latitude: 10.3157, longitude: 123.8854),
      radius: 5000,
      color: Colors.blue.withOpacity(0.3),
      strokeWidth: 2,
    );

    await mapController.drawCircle(circle);
  }


}


// void _updateLocation() async {
//   final myPosition = await mapController.myLocation();
//   final thresholdDistance = 3; // Set the threshold distance to 3 meters

//   // Calculate the distance between the current location and the last saved location
//   double distanceToLastSaved = 0;
//   if (userPath.isNotEmpty) {
//     distanceToLastSaved = await distance2point(myPosition, userPath.last);
//   }

//   // If the user is at least 3 meters away from the last saved location, save the current location
//   if (distanceToLastSaved >= thresholdDistance) {
//     setState(() {
//       userPath.add(myPosition);
//     });

//     mapController.drawRoadManually(userPath, RoadOption(roadColor: Colors.red, roadWidth: 10));
//   }

//   // Calculate the distance between the user's current location and the last geopoint of routesCHOSEN
//   double distanceToDestination = 0;
//   if (routesCHOSEN.isNotEmpty) {
//     distanceToDestination = await distance2point(myPosition, routesCHOSEN.last);
//   }

//   // If the user is less than 1 meter away from the last geopoint of routesCHOSEN, stop updating the location
//   if (distanceToDestination < 1) {
//     return;
//   }

//   Future.delayed(Duration(seconds: 1), () => _updateLocation());
// }