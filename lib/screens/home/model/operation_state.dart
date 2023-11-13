
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
// ignore: unused_import
import 'package:shift_project/screens/home/model/flood_marker_points.dart';
import 'package:shift_project/screens/home/model/routes_with_risk_points.dart';
import 'package:shift_project/states/weather/models/weather_data_model.dart';

class OpsState {
  OpsState({
    
    this.weatherData,
    this.isExpanded = false,
    this.isMapOverlayVisible = true,
    this.goNotifier = false,
    this.routes,
    this.routeCHOSEN,
    this.pointsRoad,
    this.polylinezzNotifier = false, 
    this.myRoute = const [],

  });

  final int? weatherData;
  final bool isExpanded;
  final bool goNotifier;
  final bool isMapOverlayVisible;
  final List<FloodMarkerRoute>? routes;
  final FloodMarkerRoute? routeCHOSEN;
  final List<GeoPoint>? pointsRoad;
  final bool polylinezzNotifier;
  final List<GeoPoint>? myRoute;

  OpsState copyWith({

    int? weatherData,
    bool? isExpanded,
    bool? goNotifier,
    List<FloodMarkerRoute>? routes,
    FloodMarkerRoute? routeCHOSEN,
    List<GeoPoint>? pointsRoad,
    bool? polylinezzNotifier,  bool? isMapOverlayVisible,
      List<GeoPoint>? myRoute

  }) {
    return OpsState(

      weatherData: weatherData ?? this.weatherData,
      isExpanded: isExpanded ?? this.isExpanded,
      goNotifier: goNotifier ?? this.goNotifier,
      isMapOverlayVisible: isMapOverlayVisible ?? this.isMapOverlayVisible,
      routes: routes ?? this.routes,
      routeCHOSEN: routeCHOSEN ?? this.routeCHOSEN,
      pointsRoad: pointsRoad ?? this.pointsRoad,
      polylinezzNotifier: polylinezzNotifier ?? this.polylinezzNotifier,
      myRoute: myRoute ?? this.myRoute,
      
    );
  }
}