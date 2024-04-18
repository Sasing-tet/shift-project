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

import 'package:shift_project/screens/home/model/flood_marker_points.dart';
import 'package:shift_project/screens/home/model/geojson_linestring.dart';
import 'package:shift_project/screens/home/model/geojson_multilinestring.dart';
import 'package:shift_project/screens/home/model/routes_with_id.dart';
import 'package:shift_project/screens/home/model/routes_with_risk_points.dart';
import 'package:shift_project/screens/home/notifier/operation_notifier.dart';
import 'package:shift_project/states/location/provider/address_provider.dart';
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


      
      await mapController.drawRoadManually(encoded, i == 0
          ? const RoadOption(
              roadColor: Colors.blue,
              roadWidth: 15,
            ) // Full opacity for the first route
          : const RoadOption(
              roadColor: Color.fromARGB(242, 13, 65, 107),
              roadWidth: 15,
            )// 80% opacity for the rest
);
      
      if (riskPoints!.isNotEmpty) {
        await addMarkersToMap(riskPoints, mapController);
      }
    }
  }

  static Future<void> removeAllMarkers(List<FloodMarkerRoute> routesOnPolylines,
      MapController mapController) async {
    await mapController.removeAllCircle();
    for (var i = 0; i < routesOnPolylines.length; i++) {
      final routeOnPolyline = routesOnPolylines[i];
      final riskPoints = routeOnPolyline.points;

      await removeMarker(riskPoints, mapController);
    }
    
  }

  static Future<List<List<GeoPoint>>> fetchOSRMRoutePolylines(
    List<GeoPoint> coordinates, MapController mapController) async {
  try {
    // Make request to ORS service
    final List<List<GeoPoint>> orsCoordinates = await makeRequest(coordinates);

    // If ORS response is not empty, return it
    if (orsCoordinates.isNotEmpty) {
      return orsCoordinates;
    }else{

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
        throw Exception('Failed to fetch route polylines from both ORS and OSRM services');
      }

      return polylines;
    } else {
      throw Exception('Failed to fetch route polylines from both ORS and OSRM services');
    }}
  } catch (error) {
    print('Error: $error');
    throw Exception('Failed to fetch route polylines from both ORS and OSRM services');
  }
}


  static Future<List<List<GeoPoint>>> makeRequest(List<GeoPoint> coordinates) async {
  const String apiUrl = 'https://api.openrouteservice.org/v2/directions/driving-car/geojson';
  const String apiKey = '5b3ce3597851110001cf6248845785a9f9cf4c4f9e633248762fc635';

  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=utf-8',
    'Accept': 'application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8',
    'Authorization': apiKey,
  };

  Map<String, dynamic> data = {
    "coordinates": [[coordinates[0].longitude, coordinates[0].latitude], [coordinates[1].longitude, coordinates[1].latitude]],
    "alternative_routes": {"target_count": 2, "share_factor": 0.6},
    "attributes": ["detourfactor"],
    "geometry_simplify": "true",
    "instructions": "false",
    "preference": "fastest"
  };

  try {
    http.Response response = await http.post(Uri.parse(apiUrl), headers: headers, body: json.encode(data));
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
              GeoPoint point = GeoPoint(latitude: coordinate[1], longitude: coordinate[0]);
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

  print('Number of sets of coordinates: $totalSetsOfCoordinates'); // Print the number of sets of coordinates
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

  static Future<List<FloodMarkerRoute>> getRoutesOnPolylines(
      List<List<GeoPoint>> polylines, // Changed to List<List<GeoPoint>>
      List<FloodMarkerPoint> markerPoints,
      MapController
          mapController, // Pass the mapController for the toListGeo() function
      int currentWeatherCode,
      {double epsilon = 1e-8}) async {
    List<FloodMarkerRoute> routesOnPolylines = [];

   
    return routesOnPolylines;
  }

  static Color getMarkerColor(String level) {
    // Add logic to determine marker color based on the susceptibility level
    if (level == '1') {
      return Color.fromARGB(55, 76, 175, 79);
    } else if (level == '2') {
      return const Color.fromARGB(55, 255, 153, 0);
    } else {
      return const Color.fromARGB(55, 244, 67, 54);
    }
  }
  static Future<void> addMarkersToMap(List<FloodMarkerPoint>? pointsOnPolyline,
      MapController mapController) async {
    if (pointsOnPolyline == null) {
      return;
    }

    for (var markerPoint in pointsOnPolyline) {
      int i = 0;
      String level = markerPoint.floodLevel;
      List<List<GeoPoint>> groupsOfPoints = markerPoint.points;

      for (var groupPoints in groupsOfPoints) {
        // Get the marker color based on the level
        Color markerColor = getMarkerColor(level);

        // Add the marker to the map
        // await mapController.addMarker(
        //   groupPoints.first,
        //   markerIcon: MarkerIcon(
        //     icon: Icon(
        //       Icons.flood,
        //       color: markerColor, // Set the marker color based on the level
        //       size: 50,
        //     ),
        //   ),
        // // );
        await mapController.drawCircle(CircleOSM(
              key: "circle$level-$i",
              centerPoint: groupPoints[groupPoints.length ~/ 2],
              radius:  await distance2point(groupPoints[groupPoints.length ~/ 2], groupPoints.last) ,
              color: markerColor,
              strokeWidth: 0.3,
            ));
            i++;
        // await mapController.drawRoadManually(groupPoints, RoadOption(roadColor: markerColor, roadWidth: 8));
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
      duration: const Duration(minutes: 10),
      snackBarStrategy: RemoveSnackBarStrategy(),
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
      context, OpsNotifier opsNotifier) async {
        
    for (var markerPoint in floodProneArea!) {
      String level = markerPoint.floodLevel;
      List<List<GeoPoint>> polylines = markerPoint.markerPoints;

      for (var polyline in polylines) {
        bool isInside =  await isWithinFloodProneArea(userLocation, maxDistance, polyline);

      //       if(isInside && opsNotifier.floodLevel == '0'){
      //       opsNotifier.isWithinFloodProneArea(level);
      //      showAlertDialog(context, level);
      //     return;
      //   }
      //  else if (isInside && opsNotifier.state.floodLevel != level ) {
      //     opsNotifier.isWithinFloodProneArea(level);
      //     showAlertDialog(context, level);
      //     return;
      //   } else{
      //       opsNotifier.isWithinFloodProneArea('0');
      //     return;
      //   }
       if(isInside ){
        debugPrint("Flood Level: ${opsNotifier.floodLevel}");
          
           showAlertDialog(context, level);
          return;
        }
        else{
          AnimatedSnackBar.removeAll();
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
      print('hey${notifier.state.myRoute!}');
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
        return;
      }
      checkFloodProneArea(myposition, 5, routeCHOSEN.points, context, notifier);

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

//   static Future<void> fetchFloodPoints(String? driverId) async {
//   final response = await supabase.rpc('get_intersecting_points_by_driver', params: {'driver_id_param': driverId});

//   if (response is List<dynamic>) {
//     // Handle the case when the response is a list
//     debugPrint(response.toString());
//   } else {
//     // Handle the case when the response is an object
//     if (response['error'] != null) {
//       debugPrint(response['error']['message']);
//     } else {
//       debugPrint(response['data'].toString());
//     }
//   }
// }

static Future<Map<String, dynamic>> fetchFloodPoints(String? driverId) async {
  try {
    final response = await supabase.rpc('get_o_route_points_by_driver', params: {'driver_id_param': driverId});
    
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



static Future<List<RoutesWithId>> createRoutes(Map<String, dynamic> data) async {
  List<RoutesWithId> routes = [];
  try {
    if (data.containsKey('status') && data['status'] == 'success') {

      String geoJsonString = data['routes_geojson'];
      Map<String, dynamic> geoJson = jsonDecode(geoJsonString);
      List<dynamic> coordinates = geoJson['o_coordinates'];
      for(var coordinate in coordinates) {
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
      routes.add(route);}
    } else {
      print('Error creating routes: ${data['error']}');
    }
  } catch (e) {
    // Handle any parsing errors
    print('Error creating routes: $e');
  }
  return routes;
}

static Future<void> getAltRoutePointsByDriver(String driverId) async {
  try {
    // Call the Supabase RPC endpoint
    var response = await supabase.rpc('get_alt_route_points_by_driver', params: {
      'driver_id_param': driverId,
    });

    // Check if the response is a list
    if (response is List) {
      debugPrint('Unexpected response format: $response');
      return;
    }

    // Check for errors in the response
    if (response.error != null) {
      // Handle error
      debugPrint('Error: ${response.error!.message}');
    } else if (response.data != null) {
      // Extract and handle data
      var data = response.data;
      debugPrint('Data: $data');
      // You can parse the JSON data here if needed
      // Example: var jsonData = json.decode(data);
    } else {
      // Handle unexpected response
      debugPrint('Unexpected response: $response');
    }
  } catch (e) {
    // Handle any exceptions that occur during the RPC call
    debugPrint('Error during RPC call: $e');
  }
}




static Future<Map<String, dynamic>> sendSavedRoutes(List<List<GeoPoint>> routes, String? driverId) async {

  debugPrint("howmany ${routes.length}");
  List<GeoJsonLineString> geoJsonLineStrings = routes
      .map((route) => GeoJsonLineString(route))
      .toList();
  GeoJsonMultiLineString multiLineString = GeoJsonMultiLineString(geoJsonLineStrings);
  String geoJsonString = jsonEncode(multiLineString.toJson());
  
  try {
    // Call Supabase RPC to save routes
    await supabase.rpc('save_osrm_routes', params: {'driver_id': driverId, 'routes_geojson': geoJsonString});
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
  double crossProduct =
      (point.latitude - start.latitude) * (end.longitude - start.longitude) -
      (point.longitude - start.longitude) * (end.latitude - start.latitude);

  if (crossProduct.abs() > 1e-8) {
    return false;
  }

  double dotProduct =
      (point.longitude - start.longitude) * (end.longitude - start.longitude) +
      (point.latitude - start.latitude) * (end.latitude - start.latitude);

  if (dotProduct < 0 ||
      dotProduct >
          (end.longitude - start.longitude) * (end.longitude - start.longitude) +
              (end.latitude - start.latitude) * (end.latitude - start.latitude)) {
    return false;
  }

  return true;
}

static Future<List<List<GeoPoint>>> filterPointsByRoute(List<List<GeoPoint>> pointsList, List<GeoPoint> route)async {
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
    if (filteredGroup.isNotEmpty) {
      filteredList.add(filteredGroup);
    }
  }

  return filteredList;
}






static Future<List<FloodMarkerRoute>> parseFloodMarkerRoutes(dynamic responseData, List<RoutesWithId> routesWithIds) async {
  List<FloodMarkerRoute> floodMarkerRoutes = [];
  

  
  // Create a map to store routes by ID for efficient access
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
    
 
    // Extract route ID, flood score, intersection ID, and route coordinates
    String level = item['level'].toString();

   String? routeId = item['o_routeid'] ?? item['alt_route_id'];





    int floodScore = item['floodscore']; // No need for int.parse() here

    String intersectionId = item['intersection_id'];

    List<dynamic> coordinates = item['intersecting_geog']['coordinates'];
  

   
    
// Convert route coordinates into GeoPoint objects
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
         
        }else if (coord is double) {
      // If coord is a double (single coordinate)
      // Assume the same coordinate is used for both latitude and longitude
      double latitude = coord;
      double longitude = coord; // Adjust this as needed
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







    // Find corresponding route points based on route ID
    


 
    for (var route in floodMarkerRoutes) {
      
 
      if (route.routeId == routeId) {
        debugPrint("matched ${route.routeId} and $routeId");
        List<List<GeoPoint>> filteredRoutePoints = await filterPointsByRoute(routePoints,  route.route);
    //

  debugPrint("R5");
    // Create FloodMarkerPoint object with route points
    FloodMarkerPoint floodMarkerPoint = FloodMarkerPoint(
      level, 
      filteredRoutePoints, 
      floodScore, 
      intersectionId,
    );
        route.points?.add(floodMarkerPoint);
        
      
      }else{
        debugPrint("not matched ${route.routeId} and $routeId");
      }
      }


  }

  return floodMarkerRoutes;
}




}


