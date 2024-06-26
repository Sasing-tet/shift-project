// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shift_project/main.dart';
import 'package:shift_project/screens/home/home_provider/model/flood_marker_points.dart';
import 'package:shift_project/screens/home/home_provider/model/operation_state.dart';
import 'package:shift_project/screens/home/home_provider/model/routes_with_id.dart';
import 'package:shift_project/screens/home/home_provider/model/routes_with_risk_points.dart';
import 'package:shift_project/screens/home/home_provider/service_utility/srvc.dart';

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

  void isWithinFloodProneArea(String level) {
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

  void clearPointToRoad() {
    state = state.copyWith(
      pointsRoad: [],
    );
  }

   Future<double> calculateTotalDistance(List<GeoPoint> route) async {
    double totalDistance = 0.0;

    totalDistance += await distance2point(route.first, route.last);

    return totalDistance;
  }
  
  Future<void> storeScore()async {
   final routes = state.routes;
    if (routes != null) {
      for (var route in routes) {
        if(route.points!.isNotEmpty) {
          final score = getTotalFloodscoreBasedOnWeather(routes.indexOf(route)).toString();
          route.weatherScore = double.parse(score as String)/ await calculateTotalDistance(route.route);

          debugPrint('Score: $score  weather score:  ${route.weatherScore}');
        }
      }
      if (routes.length > 1) {
      routes.sort((a, b) => a.weatherScore.compareTo(b.weatherScore));
    }

    

    List<double> scores = routes.map((route) => route.weatherScore).toList();
    const double lowRiskThreshold = 0.13;
    const double mediumRiskThreshold = 0.17;

    List<String> riskLevels = [];
    for (double score in scores) {
      debugPrint('weather score: $score');
      if (score > mediumRiskThreshold) {
        riskLevels.add('High');
      } else if (score > lowRiskThreshold) {
        riskLevels.add('Medium');
      } else {
        riskLevels.add('Low');
      }
    }

    for (int i = 0; i < routes.length; i++) {
        routes[i].riskLevel = riskLevels[i];
      }
    }

    state = state.copyWith(
          routes: routes,
          polylinezzNotifier: true,
        );
      
    
  }


  Future<void> fetchAndDrawRoute(
      String? driverId,
      MapController mapController,
      int currentWeatherCode,
      GeoPoint currentLocation,
      GeoPoint setDestination) async {
    final coordinates = state.pointsRoad;

    try {
      final altroutes =
          await insertRideEntry(currentLocation, setDestination, driverId);
      final polylines =
          await Srvc.fetchOSRMRoutePolylines(coordinates!, mapController);

      List<RoutesWithId> r = [];
      if (driverId != null) {
        debugPrint(
            "Sending polylines ${polylines.length} to Supabase: $polylines");
        final oroutes = await Srvc.sendSavedRoutes(polylines, driverId);
        debugPrint("Sending poly ${oroutes.length} to $oroutes ");
        r = await Srvc.createRoutes(oroutes);
        debugPrint("r = ${r.length} $r");
        final response = await Srvc.fetchFloodPoints(driverId);
        debugPrint('Response from fetchFloodPoints: $response');
        final routes = await Srvc.parseFloodMarkerRoutes(response, r);
        final routesTobeAdded = await Srvc.mrClean(altroutes, routes);
        debugPrint('RoutesTobeAdded: ${routesTobeAdded.length}');
        state = state.copyWith(
          routes: [...(state.routes ?? []), ...routesTobeAdded],
        );
        await storeScore();
        final routez = state.routes!;
        await Srvc.drawRoadManually(routez, mapController, state.weatherData!);
      }
    } catch (e) {
      debugPrint("Error fetching or drawing route: $e");
    }
  }

  // Example serialization of List<List<Geopoint>> to a JSON string.
  String serializePolylines(List<List<GeoPoint>> polylines) {
    var polylineArray = polylines
        .map((list) =>
            list.map((point) => [point.latitude, point.longitude]).toList())
        .toList();

    return jsonEncode(polylineArray);
  }

  Future<void> sendPolylinesToSupabase(
      String driverId, String polylinesJson) async {
    var response = await supabase.rpc('save_osrm_route',
        params: {'driver_id': driverId, 'routes': polylinesJson});
    debugPrint("Response from Supabase: ${response.data}");
    if (response.error != null) {
      debugPrint(
          "Error inserting data into Supabase: ${response.error.message}");
    } else {
      debugPrint("Successfully inserted polyline data");
    }
  }

  Future<List<FloodMarkerRoute>> insertRideEntry(GeoPoint currentLocation,
      GeoPoint setDestination, String? driverId) async {
    var uuid = const Uuid();
    String rideId = uuid.v4();
    debugPrint('front ride_id: $rideId');

    String currentLocationWKT =
        'POINT(${currentLocation.longitude} ${currentLocation.latitude})';
    String setDestinationWKT =
        'POINT(${setDestination.longitude} ${setDestination.latitude})';

    try {
      // ignore: unused_local_variable
      var response = await supabase.rpc('insert_ride', params: {
        'ride_id': rideId,
        'driver_id': driverId,
        'current_location': currentLocationWKT,
        'set_destination': setDestinationWKT,
      });
      var ride = fetchAlternateRoutes(driverId!, setDestination, rideId);
      return ride;
    } catch (e) {
      debugPrint("Error inserting ride entry: $e");
      rethrow;
    }
  }

  Future<List<FloodMarkerRoute>> fetchAlternateRoutes(
      String driverId, GeoPoint destination, String rideId) async {
    List<FloodMarkerRoute> routes = [];
    List<String> rideIds = [];

    try {
      final response = await supabase
          .from('alt_route_view')
          .select('coordinates, frequency, ride_id, alt_route_id')
          .eq('ride_id', rideId)
          .execute();

      if (response.status == 200 && response.data != null) {
        List<dynamic> routesData = response.data as List<dynamic>;
        debugPrint('Routes data: $routesData');
        for (var routeData in routesData) {
          String rideId = routeData['ride_id'].toString();
          String altRouteId = routeData['alt_route_id'].toString();
          int frequency = routeData['frequency'] as int;
          bool isAltRoute = true;

          try {
            List<dynamic> coordinateList =
                routeData['coordinates']['coordinates'];
            final routePoint =
                await Srvc.modifyRoute(coordinateList, destination);
            FloodMarkerRoute route = FloodMarkerRoute(
                [], routePoint, altRouteId,
                frequency: frequency, isAltRoute: isAltRoute);

            routes.add(route);
            rideIds.add(rideId);
          } catch (e) { print('Error parsing coordinates: $e');}
        }
      } else {print('Error fetching alternate routes: $response');}
    } catch (error) { print('An error occurred: $error');}
    try {
      final responseData = await Srvc.getAltRoutePointsByDriver(driverId);
      final altroutes = await Srvc.parseAltFloodMarkerRoutes(responseData, routes);
      if (routes.isNotEmpty) {
        state = state.copyWith( routes: [...(state.routes ?? []), ...altroutes],);
      }
    } catch (e) {  debugPrint('Error fetching alt routes: $e'); }
    return routes;
  }

  bool isAlternativeRoute(int i) {
    return state.routes![i].isAltRoute;
  }

  int getTotalFloodscore(int i) {
    List<FloodMarkerPoint> points = state.routes![i].points!;
    int total = 0;
    if (state.routes![i].isAltRoute == true) {
      debugPrint(
          'This is an alternative route ${state.routes![i].points!.length} points}');
    }
    for (var point in points) {
      total += point.floodScore;
    }
    return total;
  }

  String getTotalFloodscoreBasedOnWeather(int i) {
    List<FloodMarkerPoint> points = state.routes![i].points!;
    int total = 0;
    if (state.routes![i].isAltRoute == true) {
      debugPrint(
          'This is an alternative route ${state.routes![i].points!.length} points}');
    }

    for (var point in points) {
      if (state.weatherData! > 80 ) {
          total += point.floodScore;
        
      } else if (state.weatherData! >= 57 && state.weatherData! <= 80) {
        if (point.floodLevel == '2' || point.floodLevel == '3') {
          total += point.floodScore;
        }
      } else {
        if (point.floodLevel == '3') {
          total += point.floodScore;
        }
      }
    }

    return total
        .toString(); // Assuming you want to return the total as a string
  }

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
      routeCHOSEN: FloodMarkerRoute(null, [], ''), // Clear routes
      polylinezzNotifier: false, // Set polylinezzNotifier to false
      goNotifier: false,
    );
  }
}
