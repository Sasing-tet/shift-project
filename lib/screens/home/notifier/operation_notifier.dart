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

    await Srvc.drawRoadManually(routes, mapController);
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
