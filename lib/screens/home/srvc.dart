import 'dart:async';
import 'dart:convert';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:shift_project/screens/home/dataTemp/highflodd.dart';
import 'package:shift_project/screens/home/dataTemp/lowflood.dart';
import 'package:shift_project/screens/home/dataTemp/mediumflood.dart';
import 'package:shift_project/screens/home/model/flood_marker_points.dart';
import 'package:shift_project/screens/home/model/routes_with_risk_points.dart';
import 'package:shift_project/screens/home/notifier/operation_notifier.dart';
import 'package:shift_project/states/location/provider/address_provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:math' as math;

import '../../constants/constants.dart';
import '../../main.dart';

class Srvc {
  static Future<void> drawRoadManually(List<FloodMarkerRoute> routesOnPolylines,
      MapController mapController) async {
    for (var i = 0; i < routesOnPolylines.length; i++) {
      final routeOnPolyline = routesOnPolylines[i];
      final encoded = routeOnPolyline.route;
      final riskPoints = routeOnPolyline.points;

      if (riskPoints!.isNotEmpty) {
        await addMarkersToMap(riskPoints, mapController);
      }

      final roadOption = i == 0
          ? const RoadOption(
              roadColor: Color.fromARGB(181, 71, 19, 16),
              roadWidth: 8,
            ) // Full opacity for the first route
          : const RoadOption(
              roadColor: Colors.red,
              roadWidth: 8,
            ); // 80% opacity for the rest

      await mapController.drawRoadManually(encoded, roadOption);
    }
  }

  static Future<void> removeAllMarkers(List<FloodMarkerRoute> routesOnPolylines,
      MapController mapController) async {
    for (var i = 0; i < routesOnPolylines.length; i++) {
      final routeOnPolyline = routesOnPolylines[i];
      final riskPoints = routeOnPolyline.points;

      await removeMarker(riskPoints, mapController);
    }
  }

  static Future<List<List<GeoPoint>>> fetchOSRMRoutePolylines(
      List<GeoPoint> coordinates, MapController mapController) async {
    const String profile = 'driving';
    final String coordinatesString = coordinates
        .map((coord) => '${coord.longitude},${coord.latitude}')
        .join(';');

    final String url =
        'https://router.project-osrm.org/route/v1/$profile/$coordinatesString?alternatives=true&steps=true&geometries=polyline&overview=full&annotations=false';

    final response = await http.get(Uri.parse(url));
    List<List<GeoPoint>> polylines = [];

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      List routes = map["routes"];

      for (var route in routes) {
        var geometry = route['geometry'];
        final String list = geometry;
        final List<GeoPoint> routePoints = await list.toListGeo();

        if (routePoints.isNotEmpty) {
          polylines.add(routePoints);
        }
      }

      return polylines;
    } else {
      throw Exception('Failed to fetch route polylines');
    }
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

  static Future<List<FloodMarkerRoute>> getRoutesOnPolylines(
      List<List<GeoPoint>> polylines, // Changed to List<List<GeoPoint>>
      List<FloodMarkerPoint> markerPoints,
      MapController
          mapController, // Pass the mapController for the toListGeo() function
      int currentWeatherCode,
      {double epsilon = 1e-8}) async {
    List<FloodMarkerRoute> routesOnPolylines = [];

    if (currentWeatherCode <= 48 && currentWeatherCode >= 2) {
      for (int polylineIndex = 0;
          polylineIndex < polylines.length;
          polylineIndex++) {
        List<GeoPoint> polyline = polylines[polylineIndex];
        List<FloodMarkerPoint>? pointsOnPolyline = [];
        for (var markerPoint
            in markerPoints.where((mp) => mp.floodLevel == "High")) {
          String level = markerPoint.floodLevel;
          List<List<GeoPoint>> pointGroups = markerPoint.markerPoints;
          List<List<GeoPoint>> riskpointGroups = [];

          for (var groupPoints in pointGroups) {
            List<GeoPoint> currentGroup = [];

            for (var point in groupPoints) {
              for (int i = 0; i < polyline.length - 1; i++) {
                if (isBetween(polyline[i], polyline[i + 1], point,
                    epsilon: epsilon)) {
                  currentGroup.add(point);
                }
              }
            }

            if (currentGroup.isNotEmpty && currentGroup.length > 1) {
              riskpointGroups.add(currentGroup);
            }
          }
          if (riskpointGroups.isNotEmpty) {
            // ignore: avoid_print
            print(level);
            print(riskpointGroups.length);
            print(riskpointGroups.toList());
            pointsOnPolyline.add(FloodMarkerPoint(level, riskpointGroups));
          }
        }
        routesOnPolylines.add(FloodMarkerRoute(
          pointsOnPolyline,
          polyline,
        ));
      }
    } else if (currentWeatherCode >= 51 && currentWeatherCode <= 61) {
      for (int polylineIndex = 0;
          polylineIndex < polylines.length;
          polylineIndex++) {
        List<GeoPoint> polyline = polylines[polylineIndex];
        List<FloodMarkerPoint>? pointsOnPolyline = [];
        for (var markerPoint in markerPoints.where(
            (mp) => mp.floodLevel == "Medium" || mp.floodLevel == "High")) {
          String level = markerPoint.floodLevel;
          List<List<GeoPoint>> pointGroups = markerPoint.markerPoints;
          List<List<GeoPoint>> riskpointGroups = [];

          for (var groupPoints in pointGroups) {
            List<GeoPoint> currentGroup = [];

            for (var point in groupPoints) {
              for (int i = 0; i < polyline.length - 1; i++) {
                if (isBetween(polyline[i], polyline[i + 1], point,
                    epsilon: epsilon)) {
                  currentGroup.add(point);
                }
              }
            }

            if (currentGroup.isNotEmpty && currentGroup.length > 1) {
              riskpointGroups.add(currentGroup);
            }
          }
          if (riskpointGroups.isNotEmpty) {
            print(level);
            print(riskpointGroups.length);
            print(riskpointGroups.toList());
            pointsOnPolyline.add(FloodMarkerPoint(level, riskpointGroups));
          }
        }
        routesOnPolylines.add(FloodMarkerRoute(
          pointsOnPolyline,
          polyline,
        ));
      }
    } else if (currentWeatherCode >= 63 && currentWeatherCode <= 99) {
      for (int polylineIndex = 0;
          polylineIndex < polylines.length;
          polylineIndex++) {
        List<GeoPoint> polyline = polylines[polylineIndex];
        List<FloodMarkerPoint>? pointsOnPolyline = [];
        for (var markerPoint in markerPoints) {
          String level = markerPoint.floodLevel;
          List<List<GeoPoint>> pointGroups = markerPoint.markerPoints;
          List<List<GeoPoint>> riskpointGroups = [];

          for (var groupPoints in pointGroups) {
            List<GeoPoint> currentGroup = [];

            for (var point in groupPoints) {
              for (int i = 0; i < polyline.length - 1; i++) {
                if (isBetween(polyline[i], polyline[i + 1], point,
                    epsilon: epsilon)) {
                  currentGroup.add(point);
                }
              }
            }

            if (currentGroup.isNotEmpty && currentGroup.length > 1) {
              riskpointGroups.add(currentGroup);
            }
          }
          if (riskpointGroups.isNotEmpty) {
            print(level);
            print(riskpointGroups.length);
            print(riskpointGroups.toList());
            pointsOnPolyline.add(FloodMarkerPoint(level, riskpointGroups));
          }
        }
        routesOnPolylines.add(FloodMarkerRoute(
          pointsOnPolyline,
          polyline,
        ));
      }
    } else {
      for (int i = 0; i < polylines.length; i++) {
        routesOnPolylines.add(FloodMarkerRoute([], polylines[i]));
      }
      return routesOnPolylines;
    }

    return routesOnPolylines;
  }

  static Color getMarkerColor(String level) {
    // Add logic to determine marker color based on the susceptibility level
    if (level == 'Low') {
      return Colors.green;
    } else if (level == 'Medium') {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  static Future<void> addMarkersToMap(List<FloodMarkerPoint>? pointsOnPolyline,
      MapController mapController) async {
    if (pointsOnPolyline == null) {
      return;
    }

    for (var markerPoint in pointsOnPolyline) {
      String level = markerPoint.floodLevel;
      List<List<GeoPoint>> groupsOfPoints = markerPoint.markerPoints;

      for (var groupPoints in groupsOfPoints) {
        // Get the marker color based on the level
        Color markerColor = getMarkerColor(level);

        // Add the marker to the map
        await mapController.addMarker(
          groupPoints.first,
          markerIcon: MarkerIcon(
            icon: Icon(
              Icons.flood,
              color: markerColor, // Set the marker color based on the level
              size: 50,
            ),
          ),
        );
      }
    }
  }

  static Future<void> removeMarker(List<FloodMarkerPoint>? pointsOnPolyline,
      MapController mapController) async {
    if (pointsOnPolyline == null) {
      return;
    }

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

  static List<FloodMarkerPoint> processDataAndAddToMarkerPoints() {
    List<List<GeoPoint>> highGeoPoints =
        Srvc.extractGeoPoints(highfloodgeojson);
    List<List<GeoPoint>> midGeoPoints = Srvc.extractGeoPoints(medFloodgeojson);
    List<List<GeoPoint>> lowGeoPoints = Srvc.extractGeoPoints(lowGeojson);

    // Create new FloodMarkerPoints and update the markerPoints list
    final newMarkerPoints = [
      FloodMarkerPoint('Low', lowGeoPoints),
      FloodMarkerPoint('Medium', midGeoPoints),
      FloodMarkerPoint('High', highGeoPoints),
      // Add more FloodMarkerPoint instances as needed
    ];

    return newMarkerPoints;
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
      duration: const Duration(seconds: 5),
      snackBarStrategy: StackSnackBarStrategy(),
      mobileSnackBarPosition: MobileSnackBarPosition.bottom,
      mobilePositionSettings: const MobilePositionSettings(
        right: 15,
        left: 80,
        bottomOnAppearance: 145,
      ),
    ).show(context);
  }

  static Future<void> checkFloodProneArea(
      GeoPoint userLocation,
      double maxDistance,
      List<FloodMarkerPoint>? floodProneArea,
      context) async {
    for (var markerPoint in floodProneArea!) {
      String level = markerPoint.floodLevel;
      List<List<GeoPoint>> polylines = markerPoint.markerPoints;

      for (var polyline in polylines) {
        bool isInside =
            await isWithinFloodProneArea(userLocation, maxDistance, polyline);
        if (isInside) {
          showAlertDialog(context, level);
          return;
        }
      }
    }

    print('You are not in a flood-prone area. Safe to proceed.');
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
      print('hey' + notifier.state.myRoute!.toString());
    }
  }

  static Future<void> sendSavedRoute(List<GeoPoint>? route, String? driverId) async {
    GeoJsonLineString geoJsonLineString = GeoJsonLineString(route);
    GeoPoint lastLocation = route?.last ?? GeoPoint(latitude: 0, longitude: 0);
    String? location = await getAddressFromCoordinates(lastLocation.latitude, lastLocation.longitude);
    String geoJsonString = jsonEncode(geoJsonLineString.toJson());
    
    
    try{
      await supabase.rpc('saving_route_geom', params: {'driver_id': driverId, 'name': location, 'route_text': geoJsonString});
    }
    catch(e){
      debugPrint(e.toString());
    }
    debugPrint("Saved Route: ${geoJsonString}");
  }

  static Future<void> updateLocation(
      FloodMarkerRoute routeCHOSEN,
      MapController mapController,
      AnimationController animationController,
      OpsNotifier notifier,
      context) async {
    if (routeCHOSEN.route.isNotEmpty) {
      final myposition = await mapController.myLocation();
      // ignore: invalid_use_of_protected_member

      myRoutez(myposition, notifier, notifier.state.myRoute!);

      final dist = await distance2point(myposition, routeCHOSEN.route.last);

      print(dist.toString() + 'hey');

      if (dist < 5 || notifier.goNotifier == false) {
        animationController.stop();
        mapController.clearAllRoads();
        removeMarker(routeCHOSEN.points, mapController);
        return;
      }
      checkFloodProneArea(myposition, 5, routeCHOSEN.points, context);

      Future.delayed(
          const Duration(seconds: 1),
          () => updateLocation(
                routeCHOSEN,
                mapController,
                animationController,
                notifier,
                context,
              ));
    }
  }

  static Future<void> fetchFloodPoints(String? driverId) async {
  final response = await supabase.rpc('get_intersecting_points_by_driver', params: {'driver_id_param': driverId});

  if (response is List<dynamic>) {
    // Handle the case when the response is a list
    debugPrint(response.toString());
  } else {
    // Handle the case when the response is an object
    if (response['error'] != null) {
      debugPrint(response['error']['message']);
    } else {
      debugPrint(response['data'].toString());
    }
  }
}

}

class GeoJsonMultiLineString {
  List<GeoJsonLineString> lineStrings;

  GeoJsonMultiLineString(this.lineStrings);

  Map<String, dynamic> toJson() {
    return {
      'type': 'MultiLineString',
      'o_coordinates': lineStrings.map((lineString) {
        return {
          'id': lineString.id,
          'coordinates': lineString.coordinates,
        };
      }).toList(),
    };
  }
}

Future<void> sendSavedRoutes(List<List<GeoPoint>> routes, String? driverId) async {
  List<GeoJsonLineString> geoJsonLineStrings = routes
      .map((route) => GeoJsonLineString(route))
      .toList();
  GeoJsonMultiLineString multiLineString = GeoJsonMultiLineString(geoJsonLineStrings);
  String geoJsonString = jsonEncode(multiLineString.toJson());
  
  try {
    await supabase.rpc('save_osrm_routes', params: {'driver_id': driverId, 'routes_geojson': geoJsonString});
  } catch (e) {
    debugPrint(e.toString());
  }
  debugPrint("Saved Routes: $geoJsonString");
}


class GeoJsonLineString {
  String type = 'LineString';
  List<List<double>>? coordinates;
  String id = const Uuid().v4();

  GeoJsonLineString(List<GeoPoint>? points) {
    coordinates = points?.map((point) => [point.longitude, point.latitude]).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'o_routeid': id,
      'coordinates': coordinates,
    };
  }
}