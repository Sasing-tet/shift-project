import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
// ignore: unused_import
import 'package:shift_project/screens/home/home_provider/model/flood_marker_points.dart';
import 'package:shift_project/screens/home/home_provider/model/routes_with_risk_points.dart';

class OpsState {
  OpsState(
      {this.weatherData,
      this.isExpanded = false,
      this.isMapOverlayVisible = true,
      this.goNotifier = false,
      this.routes,
      this.routeCHOSEN,
      this.pointsRoad,
      this.polylinezzNotifier = false,
      this.myRoute = const [],
      this.floodLevel = '0'});

  final int? weatherData;
  final bool isExpanded;
  final bool goNotifier;
  final bool isMapOverlayVisible;
  final List<FloodMarkerRoute>? routes;
  final FloodMarkerRoute? routeCHOSEN;
  final List<GeoPoint>? pointsRoad;
  final bool polylinezzNotifier;
  final List<GeoPoint>? myRoute;
  final String? floodLevel;

  OpsState copyWith(
      {int? weatherData,
      bool? isExpanded,
      bool? goNotifier,
      List<FloodMarkerRoute>? routes,
      FloodMarkerRoute? routeCHOSEN,
      List<GeoPoint>? pointsRoad,
      bool? polylinezzNotifier,
      bool? isMapOverlayVisible,
      List<GeoPoint>? myRoute,
      String? floodLevel}) {
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
        floodLevel: floodLevel ?? this.floodLevel);
  }
}
