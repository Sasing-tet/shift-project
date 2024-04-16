import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:shift_project/screens/home/model/flood_marker_points.dart';

class FloodMarkerRoute {
  String _routeId;
  List<FloodMarkerPoint>? points;
  List<GeoPoint> route; // New variable
  bool _isAltRoute;
  int _frequency;

  FloodMarkerRoute(this.points, this.route, this._routeId, {bool isAltRoute = false, int frequency = 0})
      : _isAltRoute = isAltRoute,
        _frequency = frequency;

  String get routeId => _routeId;
  List<FloodMarkerPoint>? get markerPoints => points;
  List<GeoPoint> get routePoints => route; 
  bool get isAltRoute => _isAltRoute;
  int get frequency => _frequency;

  set routeId(String newRouteId) {
    _routeId = newRouteId;
  }

  set markerPoints(List<FloodMarkerPoint>? newPoints) {
    points = newPoints;
  }

  set routePoints(List<GeoPoint> newRoute) {
    route = newRoute;
  }

  set isAltRoute(bool value) {
    _isAltRoute = value;
  }

  set frequency(int value) {
    _frequency = value;
  }
}

