import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shift_project/main.dart';
import 'package:shift_project/screens/home/model/flood_marker_points.dart';
import 'package:shift_project/screens/home/model/operation_state.dart';
import 'package:shift_project/screens/home/model/routes_with_id.dart';
import 'package:shift_project/screens/home/model/routes_with_risk_points.dart';
import 'package:shift_project/screens/home/srvc.dart';

class OpsNotifier extends StateNotifier<OpsState> {
  OpsNotifier() : super(OpsState());

  bool get goNotifier => state.goNotifier;
  String? get floodLevel => state.floodLevel;
  void addNewPointToMyRoute(GeoPoint newPoint) {
    state = state.copyWith(myRoute: [...state.myRoute ?? [], newPoint]);
  }

  void clearMyRoute() {
    state = state.copyWith(myRoute: []);
  }

  void addWeatherData(int newWeatherData) {
    state = state.copyWith(weatherData: newWeatherData);
  }

  void addChosenRoute(FloodMarkerRoute newRoute) {
    state = state.copyWith(routeCHOSEN: newRoute);
  }

  void toggleExpansion() {
    state = state.copyWith(
        isExpanded: !state.isExpanded,
        isMapOverlayVisible: !state.isMapOverlayVisible);
  }
  void isWithinFloodProneArea(String level){
    state = state.copyWith(floodLevel: level);
  }

  void stopButtonNotifier() {
    state = state.copyWith(goNotifier: !state.goNotifier);
  }

  void isPolylinesGenerated() {
    state = state.copyWith(polylinezzNotifier: !state.polylinezzNotifier);
  }

  void clearChosenRoute() {
    state = state.copyWith(routeCHOSEN: null);
  }

  void addRoute(FloodMarkerRoute newRoute) {
    state = state.copyWith(
      routes: [...state.routes ?? [], newRoute],
    );
  }

  void addPointToRoad(GeoPoint newPoint) {
    state = state.copyWith(
      pointsRoad: [...state.pointsRoad ?? [], newPoint],
    );
  }

 Future<void> fetchAndDrawRoute(String? driverId, MapController mapController, int currentWeatherCode) async {
  final coordinates = state.pointsRoad;

  try {
    final polylines =
        await Srvc.fetchOSRMRoutePolylines(coordinates!, mapController);

    List<RoutesWithId> r = [];
    if (driverId != null) {
      debugPrint("Sending polylines ${polylines.length} to Supabase: $polylines");
      final oroutes = await Srvc.sendSavedRoutes(polylines, driverId);
      debugPrint("Sending poly ${oroutes.length} to ${oroutes} ");
      r = await Srvc.createRoutes(oroutes);
      debugPrint("r = ${r.length} $r");
       final response = await Srvc.fetchFloodPoints(driverId);
    debugPrint('Response from fetchFloodPoints: $response');
    final routes = await Srvc.parseFloodMarkerRoutes(response, r);
    state = state.copyWith(
      routes: [
        ...(state.routes ?? []),
        ...routes
      ],
      polylinezzNotifier: true,
    );

    final routez = state.routes!;
    await Srvc.drawRoadManually(routez, mapController);

    
    }

    
  } catch (e) {
    debugPrint("Error fetching or drawing route: $e");
  }
}



  // Example serialization of List<List<Geopoint>> to a JSON string.
  String serializePolylines(List<List<GeoPoint>> polylines) {
    var polylineArray = polylines.map((list) => 
      list.map((point) => [point.latitude, point.longitude]).toList()
    ).toList();

    return jsonEncode(polylineArray);
  }

  Future<void> sendPolylinesToSupabase(String driverId, String polylinesJson) async {
  var response = await supabase.rpc('save_osrm_route', params: {'driver_id': driverId, 'routes': polylinesJson});
  debugPrint("Response from Supabase: ${response.data}");
  if (response.error != null) {
    debugPrint("Error inserting data into Supabase: ${response.error.message}");
  } else {
    debugPrint("Successfully inserted polyline data");
  }
}

Future<void> insertRideEntry(GeoPoint currentLocation, GeoPoint setDestination, String? driverId) async {
  String currentLocationWKT = 'POINT(${currentLocation.longitude} ${currentLocation.latitude})';
  String setDestinationWKT = 'POINT(${setDestination.longitude} ${setDestination.latitude})';

  try {
   
    var response = await supabase.rpc('insert_ride', params: {
      'driver_id': driverId,
      'current_location': currentLocationWKT,
      'set_destination': setDestinationWKT,
    });
    var ride = fetchAlternateRoutes(driverId!);
    
  } catch (e) {

    debugPrint("Error inserting ride entry: $e");
  }
}

Future<List<String>> fetchAlternateRoutes(String driverId) async {
  List<FloodMarkerRoute> routes = [];
  List<String> rideIds = [];

 try {
  // Define the query to fetch data
  final response = await supabase
      .from('alt_route_view')
      .select('coordinates, frequency, ride_id, alt_route_id')
      .eq('driver_id', driverId)
      .execute();

  // Check if the query was successful
  if (response.status == 200 && response.data != null) {
    // Extract data from response
    List<dynamic> routesData = response.data as List<dynamic>;

    // Process the retrieved data
    for (var routeData in routesData) {
      String rideId = routeData['ride_id'].toString();
      String altRouteId = routeData['alt_route_id'].toString();
      int frequency = routeData['frequency'] as int;
      debugPrint("altRouteId: " + altRouteId);
      String coordinates = routeData['coordinates'].toString();
      bool isAltRoute = true;

      try {
  // Convert coordinates string to list of GeoPoints
  List<GeoPoint> geoPoints = [];
  List<dynamic> coordinateList = routeData['coordinates']['coordinates'];
  for (var coord in coordinateList) {
    if (coord is List<dynamic> && coord.length == 2) {
      double longitude = coord[0];
      double latitude = coord[1];
      geoPoints.add(GeoPoint(latitude: latitude, longitude: longitude));
    }
  }

  // Create FloodMarkerRoute instance
  FloodMarkerRoute route = FloodMarkerRoute([], geoPoints, altRouteId, frequency: frequency, isAltRoute: isAltRoute);

  // Add route to the list
  routes.add(route);
  rideIds.add(rideId);
} catch (e) {
  // Handle parsing error
  print('Error parsing coordinates: $coordinates');
}
    }
  } else {
    // Handle error
    print('Error fetching alternate routes: ${response}');
  }
} catch (error) {
  // Handle any exception that occurs during execution
  print('An error occurred: $error');
}


  if(routes.isNotEmpty){
    state = state.copyWith(
      routes: [
        ...(state.routes ?? []),
        ...routes
      ],
    );
  }
  return rideIds;
}

bool isAlternativeRoute(int i){
  return state.routes![i].isAltRoute;
}

int getTotalFloodscore(int i){
  List<FloodMarkerPoint> points = state.routes![i].points!;
  int total = 0;
  if(state.routes![i].isAltRoute == true){
   debugPrint('This is an alternative route ${state.routes![i].points!.length} points}');
  }
  for(var point in points){
  total += point.floodScore;
    }
  return total;
}

// Future<void> fetchAlternateRoutes(String driverId) async {
//   try {
//     // Define the query to fetch data
//     final response = await supabase
//         .from('alt_route_view')
//         .select('coordinates, frequency, ride_id, alt_route_id')
//         .eq('driver_id', driverId)
//         .execute();

//     // Check if the query was successful
//     if (response.status == 200 && response.data != null) {
//       // Extract data from response
//       List<dynamic> routesData = response.data as List<dynamic>;
//       List<Map<String, dynamic>> routes = [];

//       // Process the retrieved data
//       for (var routeData in routesData) {
//         try {
//           // Convert coordinates from string to list

//           String coordinate = routeData['coordinates'].toString();
//           String frequency = routeData['frequency'].toString();
//           String rideId = routeData['ride_id'].toString();
//           String altRouteId = routeData['alt_route_id'].toString();

//           // Create a new route map
//           Map<String, dynamic> route = {
//             'coordinates': coordinate,
//             'frequency': frequency,
//             'ride_id': rideId,
//             'alt_route_id': altRouteId,
//           };

//           // Add route to the list
//           routes.add(route);
//         } catch (e) {
//           // Handle parsing error
//           print('Error parsing coordinates: ${routeData['coordinates']}');
//         }
//       }

//       // Print or process the retrieved routes
//       for (var route in routes) {
//         debugPrint(
//             'Coordinates: ${route['coordinates']}, Frequency: ${route['frequency']}, Ride ID: ${route['ride_id']}, Alt Route ID: ${route['alt_route_id']}');
//       }
//     } else {
//       // Handle error
//       print('Error fetching alternate routes: ${response}');
//     }
//   } catch (error) {
//     // Handle any exception that occurs during execution
//     print('An error occurred: $error');
//   }
// }


  void clearData() {
    state = state.copyWith(
      pointsRoad: [], // Clear points road
      routes: [], // Clear routes
      polylinezzNotifier: false, // Set polylinezzNotifier to false
      goNotifier: false,
    );
  }

  void clearAllData() {
    state = state.copyWith(
      pointsRoad: [], // Clear points road
      routes: [],
      routeCHOSEN: FloodMarkerRoute(null, [],''), // Clear routes
      polylinezzNotifier: false, // Set polylinezzNotifier to false
      goNotifier: false,
    );
  }

  
}
