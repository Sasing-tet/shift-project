import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:shift_project/screens/home/model/flood_marker_points.dart';

class FloodMarkerRoute {
  String _routeId;
  List<FloodMarkerPoint>? points;
  List<GeoPoint> route; // New variable

  FloodMarkerRoute(this.points, this.route, this._routeId);

  String get routeId => _routeId;
  List<FloodMarkerPoint>? get markerPoints => points;
  List<GeoPoint> get routePoints => route; 

  set routeId(String newRouteId) {
    _routeId = newRouteId;
  }

  set setPoints(List<FloodMarkerPoint>? newPoints) {
    points = newPoints;
  }

  set setRoute(List<GeoPoint> newRoute) {
    route = newRoute;
  }
}
