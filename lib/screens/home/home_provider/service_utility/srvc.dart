// ignore_for_file: invalid_use_of_protected_member, duplicate_ignore

import 'dart:async';
import 'dart:convert';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:shift_project/screens/home/home_provider/model/flood_marker_points.dart';
import 'package:shift_project/screens/home/home_provider/model/geojson_linestring.dart';
import 'package:shift_project/screens/home/home_provider/model/geojson_multilinestring.dart';
import 'package:shift_project/screens/home/home_provider/model/routes_with_id.dart';
import 'package:shift_project/screens/home/home_provider/model/routes_with_risk_points.dart';
import 'package:shift_project/screens/home/home_provider/notifier/operation_notifier.dart';
import 'package:shift_project/states/location/provider/address_provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:math' as math;

import '../../../../constants/constants.dart';
import '../../../../main.dart';

class Srvc {
  static Future<void> drawRoadManually(List<FloodMarkerRoute> routesOnPolylines,
      MapController mapController, int weatherData) async {
    for (var i = 0; i < routesOnPolylines.length; i++) {
      final routeOnPolyline = routesOnPolylines[i];
      final encoded = routeOnPolyline.route;
      final riskPoints = routeOnPolyline.points;

      debugPrint(
          '$i maoo ni kabuok: ${encoded.length} ug mao ni points: ${routeOnPolyline.points?.length}');
      await mapController.drawRoadManually(
          encoded,
          i == 0
              ? const RoadOption(
                  roadColor: Colors.blue,
                  roadWidth: 15,
                ) // Full opacity for the first route
              : const RoadOption(
                  roadColor: Color.fromARGB(242, 13, 65, 107),
                  roadWidth: 15,
                ) // 80% opacity for the rest
          );

      if (riskPoints!.isNotEmpty) {
        await addMarkersToMap(riskPoints, mapController, weatherData);
      }
    }

    await mapController.addMarker(routesOnPolylines[0].route.last,
        markerIcon: const MarkerIcon(
            icon: Icon(
          Icons.location_on,
          color: Colors.redAccent,
          size: 100,
        )));
  }

  static Future<void> removeAllMarkers(List<FloodMarkerRoute> routesOnPolylines,
      MapController mapController) async {
    await mapController.removeAllCircle();
    // for (var i = 0; i < routesOnPolylines.length; i++) {
    //   final routeOnPolyline = routesOnPolylines[i];
    //   final riskPoints = routeOnPolyline.points;

    //   await removeMarker(riskPoints, mapController);
    // }
  }

  static Future<List<List<GeoPoint>>> fetchOSRMRoutePolylines(
      List<GeoPoint> coordinates, MapController mapController) async {
    try {
      // Make request to ORS service
      final List<List<GeoPoint>> orsCoordinates =
          await makeRequest(coordinates);

      // If ORS response is not empty, return it
      if (orsCoordinates.isNotEmpty) {
        return orsCoordinates;
      } else {
        // Construct coordinates string for OSRM request
        const String profile = 'driving';
        final String coordinatesString = coordinates
            .map((coord) => '${coord.longitude},${coord.latitude}')
            .join(';');

        // Construct URL for OSRM request
        final String url =
            'https://router.project-osrm.org/route/v1/$profile/$coordinatesString?alternatives=true&steps=true&geometries=polyline&overview=full&annotations=false';

        // Send request to OSRM service
        final response = await http.get(Uri.parse(url));
        List<List<GeoPoint>> polylines = [];

        if (response.statusCode == 200) {
          // Parse OSRM response
          Map<String, dynamic> map = jsonDecode(response.body);
          List routes = map["routes"];

          // Extract polylines from OSRM response
          for (var route in routes) {
            var geometry = route['geometry'];
            final String list = geometry;
            final List<GeoPoint> routePoints = await list.toListGeo();

            if (routePoints.isNotEmpty) {
              polylines.add(routePoints);
            }
          }

          if (polylines.isEmpty) {
            throw Exception(
                'Failed to fetch route polylines from both ORS and OSRM services');
          }

          return polylines;
        } else {
          throw Exception(
              'Failed to fetch route polylines from both ORS and OSRM services');
        }
      }
    } catch (error) {
      print('Error: $error');
      throw Exception(
          'Failed to fetch route polylines from both ORS and OSRM services');
    }
  }

  static Future<List<List<GeoPoint>>> makeRequest(
      List<GeoPoint> coordinates) async {
    const String apiUrl =
        'https://api.openrouteservice.org/v2/directions/driving-car/geojson';
    const String apiKey =
        '5b3ce3597851110001cf6248845785a9f9cf4c4f9e633248762fc635';

    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept':
          'application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8',
      'Authorization': apiKey,
    };

    Map<String, dynamic> data = {
      "coordinates": [
        [coordinates[0].longitude, coordinates[0].latitude],
        [coordinates[1].longitude, coordinates[1].latitude]
      ],
      "alternative_routes": {"target_count": 2, "share_factor": 0.6},
      "attributes": ["detourfactor"],
      "geometry_simplify": "true",
      "instructions": "false",
      "preference": "fastest"
    };

    try {
      http.Response response = await http.post(Uri.parse(apiUrl),
          headers: headers, body: json.encode(data));
      if (response.statusCode == 200) {
        // Parse and extract coordinates from the response
        print("Responsez: ${response.body}");
        return extractCoordinates(response.body);
      } else {
        // Handle error response
        print("Error: ${response.statusCode}");
        return [];
      }
    } catch (error) {
      // Handle connection error
      print("Connection Error: $error");
      return [];
    }
  }

  static List<List<GeoPoint>> extractCoordinates(String jsonResponse) {
    List<List<GeoPoint>> coordinatesList = [];

    if (jsonResponse.isEmpty) {
      // If response is empty, return an empty list
      return coordinatesList;
    }

    Map<String, dynamic> responseData = json.decode(jsonResponse);
    int totalSetsOfCoordinates = 0; // Initialize a counter

    if (responseData.containsKey('features')) {
      List<dynamic> features = responseData['features'];
      for (var feature in features) {
        if (feature.containsKey('geometry')) {
          Map<String, dynamic> geometry = feature['geometry'];
          if (geometry.containsKey('coordinates')) {
            List<dynamic> coordinates = geometry['coordinates'];

            List<GeoPoint> featureCoordinates = [];

            // Extract coordinates from the LineString geometry
            debugPrint('Setz 1');
            for (var coordinate in coordinates) {
              if (coordinate is List<dynamic> && coordinate.length == 2) {
                GeoPoint point =
                    GeoPoint(latitude: coordinate[1], longitude: coordinate[0]);
                featureCoordinates.add(point);
                debugPrint('$coordinate');
              }
            }

            // Add extracted coordinates to the main list
            if (featureCoordinates.isNotEmpty) {
              coordinatesList.add(featureCoordinates);
              totalSetsOfCoordinates++; // Increment the counter

              // Print each set of coordinates
              // debugPrint('Setz ${coordinatesList.length}: $featureCoordinates');
            }
          }
        }
      }
    }

    print(
        'Number of sets of coordinates: $totalSetsOfCoordinates'); // Print the number of sets of coordinates
    return coordinatesList;
  }

  static bool isBetween(GeoPoint a, GeoPoint b, GeoPoint c,
      {double epsilon = 1e-8}) {
    double crossProduct =
        (c.latitude - a.latitude) * (b.longitude - a.longitude) -
            (c.longitude - a.longitude) * (b.latitude - a.latitude);

    if ((crossProduct).abs() > epsilon) {
      return false;
    }

    double dotProduct =
        (c.longitude - a.longitude) * (b.longitude - a.longitude) +
            (c.latitude - a.latitude) * (b.latitude - a.latitude);

    if (dotProduct < 0 ||
        dotProduct >
            (b.longitude - a.longitude) * (b.longitude - a.longitude) +
                (b.latitude - a.latitude) * (b.latitude - a.latitude)) {
      return false;
    }

    return true;
  }

  static Color getMarkerColor(String level, int weatherData) {
    // Add logic to determine marker color based on the susceptibility level
    
      if (weatherData < 53) {
        if (level == '1') {
          return Color.fromARGB(5, 76, 175, 79);
        } else if (level == '2') {
          return const Color.fromARGB(5, 255, 153, 0);
        } else {
          return const Color.fromARGB(101, 244, 67, 54);
        }
      } else if (weatherData >= 53 && weatherData <= 63) {
         if (level == '1') {
          return const Color.fromARGB(101, 76, 175, 79);
        } else if (level == '2') {
          return const Color.fromARGB(5, 255, 153, 0);
        } else {
          return const Color.fromARGB(101, 244, 67, 54);
        }
        
      } else {
        return const Color.fromARGB(101, 244, 67, 54);
      }
    } else if (weatherData >= 53 && weatherData <= 63) {
      if (level == '1') {
        return const Color.fromARGB(101, 76, 175, 79);
      } else if (level == '2') {
        return const Color.fromARGB(62, 255, 153, 0);
      } else {
        return const Color.fromARGB(101, 244, 67, 54);
      }
    } else {
      if (level == '1') {
        return const Color.fromARGB(101, 76, 175, 79);
      } else if (level == '2') {
        return const Color.fromARGB(101, 255, 153, 0);
      } else {
        return const Color.fromARGB(101, 244, 67, 54);
      }
    }
  }

  static Future<void> addMarkersToMap(List<FloodMarkerPoint>? pointsOnPolyline,
      MapController mapController, int weatherData) async {
    if (pointsOnPolyline == null) {
      return;
    }

    for (var markerPoint in pointsOnPolyline) {
      String level = markerPoint.floodLevel;
      List<List<GeoPoint>> groupsOfPoints = markerPoint.points;
      for (var groupPoints in groupsOfPoints) {
        // Get the marker color based on the level
        Color markerColor = getMarkerColor(level, weatherData);

        var uuid = const Uuid();
        String markerId = uuid.v4();

        await mapController.drawCircle(CircleOSM(
          key: markerId,
          centerPoint: groupPoints[groupPoints.length ~/ 2],
          radius: await distance2point(groupPoints.first, groupPoints.last) *
                      0.5 <=
                  10
              ? 10
              : await distance2point(groupPoints.first, groupPoints.last) * 0.5,
          color: markerColor,
          strokeWidth: 0.5,
        ));
      }
    }
  }

  static Future<void> removeMarker(List<FloodMarkerPoint>? pointsOnPolyline,
      MapController mapController) async {
    if (pointsOnPolyline == null) {
      return;
    }
    await mapController.removeAllCircle();
    for (var markerPoint in pointsOnPolyline) {
      List<List<GeoPoint>> groupsOfPoints = markerPoint.markerPoints;

      for (var groupPoints in groupsOfPoints) {
        // Get the marker color based on the level

        // Add the marker to the map
        await mapController.removeMarker(groupPoints.first);
      }
    }
  }

  static List<List<GeoPoint>> extractGeoPoints(String geoJsonString) {
    List<List<GeoPoint>> geoPointsList = [];

    Map<String, dynamic> geoJsonData = jsonDecode(geoJsonString);
    List<dynamic> features = geoJsonData['features'];

    for (dynamic feature in features) {
      dynamic geometry = feature['geometry'];
      if (geometry != null && geometry['type'] == 'MultiLineString') {
        List<dynamic> lines = geometry['coordinates'];

        for (dynamic line in lines) {
          List<GeoPoint> geoPoints = [];

          for (dynamic point in line) {
            double longitude = point[0].toDouble();
            double latitude = point[1].toDouble();
            geoPoints.add(GeoPoint(latitude: latitude, longitude: longitude));
          }

          if (geoPoints.isNotEmpty) {
            geoPointsList.add(geoPoints);
          }
        }
      }
    }

    return geoPointsList;
  }

  static Future<LatLng>? determinePosition(context) async {
    bool serviceEnabled;
    PermissionStatus permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Location Services Disabled'),
          content:
              const Text('Please enable location services to use this app.'),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }

    permission = await Permission.locationWhenInUse.status;
    if (permission.isDenied) {
      permission = await Permission.locationWhenInUse.request();
      if (permission.isDenied) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Location Permissions Denied'),
            content: const Text(
                'Please grant location permissions to use this app.'),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }

    if (permission.isPermanentlyDenied) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Location Permissions Denied'),
          content: const Text(
              'Please enable location permissions from the app settings.'),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }

    final position = await Geolocator.getCurrentPosition();

    return LatLng(position.latitude, position.longitude);
  }

  // Function to check if a Geopoint is within a certain distance of the polyline
  static Future<bool> isWithinFloodProneArea(
      GeoPoint point, double maxDistance, List<GeoPoint> polyline) async {
    for (int i = 0; i < polyline.length - 1; i++) {
      GeoPoint point1 = polyline[i];
      GeoPoint point2 = polyline[i + 1];

      double distanceToSegment =
          await calculateDistanceToSegment(point, point1, point2);

      if (distanceToSegment <= maxDistance) {
        return true;
      }
      // }
      // if(isBetween(point, point1,point2)){
      //   return true;
      // }
    }
    return false;
  }

// Function to calculate the distance between a point and a line segment
  static Future<double> calculateDistanceToSegment(
      GeoPoint point, GeoPoint segmentStart, GeoPoint segmentEnd) async {
    double segmentLength = await distance2point(segmentStart, segmentEnd);

    if (segmentLength == 0) {
      return distance2point(point, segmentStart);
    }

    double t = math.max(
        0,
        math.min(
            1,
            ((point.latitude - segmentStart.latitude) *
                        (segmentEnd.latitude - segmentStart.latitude) +
                    (point.longitude - segmentStart.longitude) *
                        (segmentEnd.longitude - segmentStart.longitude)) /
                (segmentLength * segmentLength)));

    double nearestLatitude = segmentStart.latitude +
        t * (segmentEnd.latitude - segmentStart.latitude);
    double nearestLongitude = segmentStart.longitude +
        t * (segmentEnd.longitude - segmentStart.longitude);

    return distance2point(point,
        GeoPoint(latitude: nearestLatitude, longitude: nearestLongitude));
  }

  static Future<void> showAlertDialog(context, String message) async {
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return AlertDialog(
    //       title: Text('Flood-Prone Area'),
    //       content: Text(message),
    //     );
    //   },
    // );
    AnimatedSnackBar(
      builder: ((context) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          //height: 50,
          child: Column(
            children: [
              Row(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xffFFC250),
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(
                              'assets/images/Dangerous.png',
                              height: 40,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Flood Susceptibility',
                          style: TextStyle(
                            fontSize: defaultFontSize,
                            fontFamily: interFontFamily,
                            fontWeight: FontWeight.bold,
                            height: 1.5,
                          ),
                        ),
                        Text(
                          message,
                          style: const TextStyle(
                            fontSize: titleFontSize,
                            fontFamily: interFontFamily,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                        const Text(
                          'Flood-prone Area',
                          style: TextStyle(
                            fontSize: defaultFontSize,
                            fontFamily: interFontFamily,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
      duration: const Duration(minutes: 10),
      snackBarStrategy: RemoveSnackBarStrategy(),
      mobileSnackBarPosition: MobileSnackBarPosition.bottom,
      mobilePositionSettings: const MobilePositionSettings(
        right: 15,
        left: 80,
        bottomOnAppearance: 100,
      ),
    ).show(context);
  }

  static Future<String> checkFloodProneArea(
      GeoPoint userLocation,
      double maxDistance,
      List<FloodMarkerPoint>? floodProneArea,
      context,
      OpsNotifier opsNotifier,
      String prevlevel) async {
    List<String> levelsToCheck = [];
    if (opsNotifier.state.weatherData != null) {
      if (opsNotifier.state.weatherData! < 53) {
        levelsToCheck.add('3');
      } else if (opsNotifier.state.weatherData! >= 53 &&
          opsNotifier.state.weatherData! <= 63) {
        levelsToCheck.addAll(['2', "3"]);
      } else {
        levelsToCheck.addAll(["1", "2", "3"]);
      }
    }

    for (var markerPoint in floodProneArea!) {
      String level = markerPoint.floodLevel;
      //  if (!levelsToCheck.contains(level)) {
      if (level == '3') {
        continue;
      }
      List<List<GeoPoint>> polylines = markerPoint.markerPoints;

      for (var polyline in polylines) {
        bool isInside =
            await isWithinFloodProneArea(userLocation, maxDistance, polyline);

        if (isInside) {
          debugPrint("Flood Level: $level and $prevlevel");
          if (prevlevel != level && prevlevel == '0') {
            showAlertDialog(context, level);
          } else if (prevlevel != level && prevlevel != '0') {
            debugPrint("Flood Level: $level and $prevlevel");
            AnimatedSnackBar.removeAll();
            showAlertDialog(context, level);
          }

          return level;
        } else {
          debugPrint("Flood Level: $level and $prevlevel");
          AnimatedSnackBar.removeAll();
          prevlevel = '4';
        }
      }
    }
    return '4';
  }

  static Future<void> myRoutez(
    GeoPoint myLocation,
    OpsNotifier notifier,
    List<GeoPoint> route,
  ) async {
    final dist = await distance2point(route.last, myLocation);
    if (dist > 5) {
      notifier.addNewPointToMyRoute(myLocation);
      // ignore: avoid_print
      print('hey${notifier.state.myRoute!}');
    }
  }

  static Future<void> sendSavedRoute(
      List<GeoPoint>? route, String? driverId) async {
    GeoJsonLineString geoJsonLineString = GeoJsonLineString(route);
    GeoPoint lastLocation = route?.last ?? GeoPoint(latitude: 0, longitude: 0);
    String? location = await getAddressFromCoordinates(
        lastLocation.latitude, lastLocation.longitude);
    String geoJsonString = jsonEncode(geoJsonLineString.toJson());

    try {
      await supabase.rpc('saving_route_geom', params: {
        'driver_id': driverId,
        'name': location,
        'route_text': geoJsonString
      });
    } catch (e) {
      debugPrint(e.toString());
    }
    debugPrint("Saved Route: $geoJsonString");
  }

  static Future<void> updateLocation(
      FloodMarkerRoute routeCHOSEN,
      MapController mapController,
      AnimationController animationController,
      OpsNotifier notifier,
      context,
      String prlevel) async {
    String prevlevel = prlevel;
    if (routeCHOSEN.route.isNotEmpty) {
      final myposition = await mapController.myLocation();
      // ignore: invalid_use_of_protected_member

      // ignore: invalid_use_of_protected_member
      myRoutez(myposition, notifier, notifier.state.myRoute!);

      final dist = await distance2point(myposition, routeCHOSEN.route.last);

      print('${dist}hey');

      if (dist < 5 || notifier.goNotifier == false) {
        animationController.stop();
        mapController.clearAllRoads();
        mapController.removeAllCircle();
        removeMarker(routeCHOSEN.points, mapController);
        notifier.clearAllData();
        AnimatedSnackBar.removeAll();
        return;
      }
      prevlevel = await checkFloodProneArea(
          myposition, 5, routeCHOSEN.points, context, notifier, prevlevel);

      Future.delayed(
          const Duration(seconds: 1),
          () => updateLocation(routeCHOSEN, mapController, animationController,
              notifier, context, prevlevel));
    }
  }

  static Future<Map<String, dynamic>> fetchFloodPoints(String? driverId) async {
    try {
      final response = await supabase.rpc('get_o_route_points_by_driver',
          params: {'driver_id_param': driverId});

      if (response is List) {
        // Handle list response
        List<Map<String, dynamic>> jsonResponseList = [];
        for (var item in response) {
          if (item is Map<String, dynamic>) {
            jsonResponseList.add(item);
          }
        }
        return {'data': jsonResponseList};
      } else if (response is Map<String, dynamic>) {
        // Handle regular map response
        return response;
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      throw Exception('Error fetching flood points: $e');
    }
  }

  static Future<List<RoutesWithId>> createRoutes(
      Map<String, dynamic> data) async {
    List<RoutesWithId> routes = [];
    try {
      if (data.containsKey('status') && data['status'] == 'success') {
        String geoJsonString = data['routes_geojson'];
        Map<String, dynamic> geoJson = jsonDecode(geoJsonString);
        List<dynamic> coordinates = geoJson['o_coordinates'];
        for (var coordinate in coordinates) {
          List<dynamic> coord = coordinate['coordinates'];
          String routeId = coordinate['id'];
          List<GeoPoint> points = [];

          for (var pointData in coord) {
            GeoPoint point = GeoPoint(
              longitude: pointData[0],
              latitude: pointData[1],
            );
            points.add(point);
          }

          RoutesWithId route = RoutesWithId(id: routeId, points: points);
          routes.add(route);
        }
      } else {
        print('Error creating routes: ${data['error']}');
      }
    } catch (e) {
      // Handle any parsing errors
      print('Error creating routes: $e');
    }
    return routes;
  }

  static Future<Map<String, dynamic>> getAltRoutePointsByDriver(
      String driverId) async {
    try {
      // Call the Supabase RPC endpoint
      var response =
          await supabase.rpc('get_alt_route_points_by_driver', params: {
        'driver_id_param': driverId,
      });

      // Check if the response is a list

      if (response is List) {
        // Handle list response
        List<Map<String, dynamic>> jsonResponseList = [];
        for (var item in response) {
          if (item is Map<String, dynamic>) {
            jsonResponseList.add(item);
          }
        }
        debugPrint("jsonResponseList: $jsonResponseList");
        return {'data': jsonResponseList};
      } else if (response is Map<String, dynamic>) {
        // Handle regular map response
        return response;
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      throw Exception('Error fetching flood points: $e');
    }
  }

  static Future<Map<String, dynamic>> sendSavedRoutes(
      List<List<GeoPoint>> routes, String? driverId) async {
    debugPrint("howmany ${routes.length}");
    List<GeoJsonLineString> geoJsonLineStrings =
        routes.map((route) => GeoJsonLineString(route)).toList();
    GeoJsonMultiLineString multiLineString =
        GeoJsonMultiLineString(geoJsonLineStrings);
    String geoJsonString = jsonEncode(multiLineString.toJson());

    try {
      // Call Supabase RPC to save routes
      await supabase.rpc('save_osrm_routes',
          params: {'driver_id': driverId, 'routes_geojson': geoJsonString});
    } catch (e) {
      // Handle errors
      debugPrint(e.toString());
      // Return an error response if there's an error
      return {
        'status': 'error',
        'error': e.toString(),
      };
    }

    // Construct and return the success response map
    return {
      'status': 'success',
      'driver_id': driverId,
      'routes_geojson': geoJsonString,
    };
  }

// static Future<List<List<GeoPoint>>> removePointsInsideRadius(List<List<GeoPoint>> pointsList) async {
//   List<List<GeoPoint>> filteredList = [];

//   for (int i = 0; i < pointsList.length; i++) {
//     List<GeoPoint> group = pointsList[i];
//     GeoPoint centerPoint = group[group.length ~/ 2]; // Middle point as center
//     double radius = await distance2point(centerPoint, group.last) ;

//     bool shouldAddGroup = true;

//     // Check if this group overlaps with any other group
//     for (int j = 0; j < pointsList.length; j++) {
//       if (i != j) {
//         GeoPoint otherCenterPoint = pointsList[j][pointsList[j].length ~/ 2];

//         double distanceBetweenCenters = await distance2point(centerPoint, otherCenterPoint);
//         if (distanceBetweenCenters < radius ) {
//           shouldAddGroup = false;

//         }
//          if (shouldAddGroup) {
//       filteredList.add(group);
//     }
//       }
//     }

//   }

//   return filteredList;
// }
  static bool isPointBetween(GeoPoint point, GeoPoint start, GeoPoint end) {
    double crossProduct = (point.latitude - start.latitude) *
            (end.longitude - start.longitude) -
        (point.longitude - start.longitude) * (end.latitude - start.latitude);

    if (crossProduct.abs() > 1e-7) {
      return false;
    }

    double dotProduct = (point.longitude - start.longitude) *
            (end.longitude - start.longitude) +
        (point.latitude - start.latitude) * (end.latitude - start.latitude);

    if (dotProduct < 0 ||
        dotProduct >
            (end.longitude - start.longitude) *
                    (end.longitude - start.longitude) +
                (end.latitude - start.latitude) *
                    (end.latitude - start.latitude)) {
      return false;
    }

    return true;
  }

  static Future<List<List<GeoPoint>>> filterPointsByRoute(
      List<List<GeoPoint>> pointsList, List<GeoPoint> route) async {
    List<List<GeoPoint>> filteredList = [];

    for (List<GeoPoint> group in pointsList) {
      List<GeoPoint> filteredGroup = [];

      // Check if any point in the group is between or intersects the route
      for (GeoPoint point in group) {
        bool isPointBetweenRoute = false;
        for (int i = 0; i < route.length - 1; i++) {
          if (isPointBetween(point, route[i], route[i + 1])) {
            isPointBetweenRoute = true;
            break;
          }
        }
        if (isPointBetweenRoute) {
          filteredGroup.add(point);
        }
      }

      // Ensure all points in the filtered group are between the route's start and end points
      if (filteredGroup.isNotEmpty && filteredGroup.length > 1) {
        filteredList.add(filteredGroup);
      }
    }

    return filteredList;
  }

  static Future<List<FloodMarkerRoute>> parseFloodMarkerRoutes(
      dynamic responseData, List<RoutesWithId> routesWithIds) async {
    List<FloodMarkerRoute> floodMarkerRoutes = [];

    Map<String, List<GeoPoint>> routePointsMap = {};

    for (var route in routesWithIds) {
      routePointsMap[route.id] = route.points;
      // Initialize FloodMarkerRoute with routesWithIds data
      floodMarkerRoutes.add(
        FloodMarkerRoute(
          [], // Initialize with empty list
          route.points,
          route.id,
        ),
      );
    }

    // Loop through each item in the response data
    for (var item in responseData['data']) {
      String level = item['level'].toString();
      String routeId = item['o_routeid'];

      int floodScore = item['floodscore']; // No need for int.parse() here
      String intersectionId = item['intersection_id'];
      List<dynamic> coordinates = item['intersecting_geog']['coordinates'];
      List<List<GeoPoint>> routePoints = [];
      if (coordinates.length > 1) {
        for (var coordinateList in coordinates) {
          if (coordinateList.isNotEmpty && coordinateList.length >= 2) {
            // For coordinates with multiple points
            List<GeoPoint> points = [];
            for (var coord in coordinateList) {
              if (coord is List<dynamic> && coord.length >= 2) {
                double latitude = double.parse(coord[1].toString());
                double longitude = double.parse(coord[0].toString());
                points.add(
                  GeoPoint(
                    latitude: latitude,
                    longitude: longitude,
                  ),
                );
              } else if (coord is double) {
                double latitude = coord;
                double longitude = coord;
                points.add(
                  GeoPoint(
                    latitude: latitude,
                    longitude: longitude,
                  ),
                );
              } else {
                debugPrint("Invalid coordinate format in $coordinateList");
                throw Exception("Invalid coordinate format in $coordinateList");
              }
            }
            routePoints.add(points);
          } else {
            debugPrint("Invalid coordinates: $coordinateList");
            throw Exception("Invalid coordinates: $coordinateList");
          }
        }
      } else if (coordinates.length == 1) {
        // For single coordinate list
        var coordinateList = coordinates[0];
        if (coordinateList is List<dynamic> && coordinateList.length >= 2) {
          double latitude = double.parse(coordinateList[1].toString());
          double longitude = double.parse(coordinateList[0].toString());
          routePoints.add([
            GeoPoint(
              latitude: latitude,
              longitude: longitude,
            ),
          ]);
        } else {
          debugPrint("Invalid coordinate format: $coordinateList");
          throw Exception("Invalid coordinate format: $coordinateList");
        }
      } else {
        debugPrint("Invalid coordinates: $coordinates");
        throw Exception("Invalid coordinates: $coordinates");
      }
      for (var route in floodMarkerRoutes) {
        if (route.routeId == routeId && route.routeId != '') {
          debugPrint("matched by route_id ${route.routeId} and $routeId");
          List<List<GeoPoint>> filteredRoutePoints =
              await filterPointsByRoute(routePoints, route.route);
          // debugPrint("R5");
          // Create FloodMarkerPoint object with route points
          FloodMarkerPoint floodMarkerPoint = FloodMarkerPoint(
            level,
            filteredRoutePoints,
            floodScore,
            intersectionId,
          );
          route.points?.add(floodMarkerPoint);
        } else {
          debugPrint("not matched ${route.routeId} and $routeId");
        }
      }
    }

    return floodMarkerRoutes;
  }

  static Future<List<FloodMarkerRoute>> parseAltFloodMarkerRoutes(
      dynamic responseData, List<FloodMarkerRoute> altFl) async {
    List<FloodMarkerRoute> floodMarkerRoutes = altFl;

    // Loop through each item in the response data
    for (var item in responseData['data']) {
      String level = item['level'].toString();
      String? routeId = item['alt_route_id'];

      int floodScore = item['floodscore']; // No need for int.parse() here
      String intersectionId = item['intersection_id'];
      List<dynamic> coordinates = item['intersecting_geog']['coordinates'];
      List<List<GeoPoint>> routePoints = [];
      if (coordinates.length > 1) {
        for (var coordinateList in coordinates) {
          if (coordinateList.isNotEmpty && coordinateList.length >= 2) {
            // For coordinates with multiple points
            List<GeoPoint> points = [];
            for (var coord in coordinateList) {
              if (coord is List<dynamic> && coord.length >= 2) {
                double latitude = double.parse(coord[1].toString());
                double longitude = double.parse(coord[0].toString());
                points.add(
                  GeoPoint(
                    latitude: latitude,
                    longitude: longitude,
                  ),
                );
              } else if (coord is double) {
                double latitude = coord;
                double longitude = coord;
                points.add(
                  GeoPoint(
                    latitude: latitude,
                    longitude: longitude,
                  ),
                );
              } else {
                debugPrint("Invalid coordinate format in $coordinateList");
                throw Exception("Invalid coordinate format in $coordinateList");
              }
            }
            routePoints.add(points);
          } else {
            debugPrint("Invalid coordinates: $coordinateList");
            throw Exception("Invalid coordinates: $coordinateList");
          }
        }
      } else if (coordinates.length == 1) {
        // For single coordinate list
        var coordinateList = coordinates[0];
        if (coordinateList is List<dynamic> && coordinateList.length >= 2) {
          double latitude = double.parse(coordinateList[1].toString());
          double longitude = double.parse(coordinateList[0].toString());
          routePoints.add([
            GeoPoint(
              latitude: latitude,
              longitude: longitude,
            ),
          ]);
        } else {
          debugPrint("Invalid coordinate format: $coordinateList");
          throw Exception("Invalid coordinate format: $coordinateList");
        }
      } else {
        debugPrint("Invalid coordinates: $coordinates");
        throw Exception("Invalid coordinates: $coordinates");
      }
      for (var route in floodMarkerRoutes) {
        if (route.routeId == routeId && route.routeId != '') {
          debugPrint("matched by route_id ${route.routeId} and $routeId");
          List<List<GeoPoint>> filteredRoutePoints =
              await filterPointsByRoute(routePoints, route.route);
          // debugPrint("R5");
          // Create FloodMarkerPoint object with route points
          FloodMarkerPoint floodMarkerPoint = FloodMarkerPoint(
            level,
            filteredRoutePoints,
            floodScore,
            intersectionId,
          );
          route.points?.add(floodMarkerPoint);
        } else {
          debugPrint("not matched ${route.routeId} and $routeId");
        }
      }
    }

    return floodMarkerRoutes;
  }

  static Future<List<GeoPoint>> modifyRoute(
      List<dynamic> routeData, GeoPoint destination,
      {double threshold = 0.1}) async {
    List<GeoPoint> geoPoints = [];
    List<GeoPoint> alternateRoute = [];

    // Extract coordinates from routeData
    for (var currentCoord in routeData) {
      if (currentCoord is List<dynamic> && currentCoord.length == 2) {
        double longitude = currentCoord[0];
        double latitude = currentCoord[1];
        geoPoints.add(GeoPoint(latitude: latitude, longitude: longitude));
      }
    }

    // Find the index of the point closest to the destination
    int closestIndex = -1;
    double minDistance = double.infinity;
    for (int i = geoPoints.length - 1; i >= 0; i--) {
      double distance = await distance2point(geoPoints[i], destination);
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    if (closestIndex != -1) {
      // Remove points after the closest point
      geoPoints.removeRange(closestIndex + 1, geoPoints.length);

      // Check distances to determine whether to add destination or replace last point
      if (closestIndex > 0) {
        double distanceToLastPoint =
            await distance2point(geoPoints[closestIndex - 1], destination);
        double distanceToDest =
            await distance2point(geoPoints[closestIndex], destination);

        if (distanceToDest < distanceToLastPoint) {
          geoPoints.add(destination); // Add destination
        } else if (distanceToDest > distanceToLastPoint) {
          geoPoints[closestIndex] =
              destination; // Replace last point with destination
        }
        // If distances are equal, do nothing
      }
    }

    final String coordinatesString = geoPoints
        .map((coord) => '${coord.longitude},${coord.latitude}')
        .join(';');

    String url =
        'http://router.project-osrm.org/match/v1/driving/$coordinatesString?geometries=polyline&overview=simplified&annotations=true&tidy=true';

    // Make the API call
    try {
      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Handle successful response
        String responseBody = response.body;
        String geometry = extractGeometry(responseBody);
        debugPrint('hahay: $geometry');
        alternateRoute = await geometry.toListGeo();
        debugPrint('Response body: ${response.body}');
        debugPrint('alternateRoute: $alternateRoute');
      } else {
        // Handle other status codes
        debugPrint('Failed to call OSRM API: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
    } catch (e) {
      // Handle any exceptions
      print('Exception occurred while calling OSRM API: $e');
    }

    return alternateRoute;
  }

  static String extractGeometry(String responseBody) {
    try {
      // Parse the JSON response
      Map<String, dynamic> jsonResponse = json.decode(responseBody);

      // Check if the response contains matchings
      if (jsonResponse.containsKey('matchings')) {
        List<dynamic> matchings = jsonResponse['matchings'];
        if (matchings.isNotEmpty) {
          // Take the geometry from the first matching
          Map<String, dynamic> firstMatching = matchings[0];
          if (firstMatching.containsKey('geometry')) {
            return firstMatching['geometry'] as String;
          }
        }
      }
    } catch (e) {
      print('Error parsing JSON response: $e');
    }

    // Return an empty string if the geometry cannot be extracted
    return '';
  }

  static Future<List<FloodMarkerRoute>> mrClean(
      List<FloodMarkerRoute> altRoutes, List<FloodMarkerRoute> routes) async {
    final routesToRemove = <String>[];

    // Iterate through altRoutes and compare flood scores and total distances
    for (final altRoute in altRoutes) {
      final altTotalFloodScore = await _calculateTotalFloodScore(altRoute);
      final altTotalDistance = await _calculateTotalDistance(altRoute.route);

      // Iterate through routes and compare flood scores and total distances
      for (final route in routes) {
        final totalFloodScore = await _calculateTotalFloodScore(route);
        final totalDistance = await _calculateTotalDistance(route.route);
        debugPrint(
            'altTotalFloodScore: $altTotalFloodScore totalFloodScore: $totalFloodScore altTotalDistance: $altTotalDistance totalDistance: $totalDistance');
        // If flood scores and total distances match, add route ID to routesToRemove list
        if (altTotalFloodScore == totalFloodScore &&
            (altTotalDistance - totalDistance).abs() < 6) {
          routesToRemove.add(route.routeId);
        }
      }
    }

    // Remove routes with matching flood scores and total distances
    routes.removeWhere((route) => routesToRemove.contains(route.routeId));

    return routes;
  }

// Helper function to calculate the total flood score of a route
  static Future<int> _calculateTotalFloodScore(FloodMarkerRoute route) async {
    int total = 0;

    if (route.points != null) {
      for (var point in route.points!) {
        total += point.floodScore;
      }
    }

    return total;
  }

  static Future<double> _calculateTotalDistance(List<GeoPoint> route) async {
    double totalDistance = 0.0;

    totalDistance += await distance2point(route.first, route.last);

    return totalDistance;
  }
}
