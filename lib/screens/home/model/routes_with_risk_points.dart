import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:shift_project/screens/home/model/flood_marker_points.dart';

class FloodMarkerRoute {
  final List<FloodMarkerPoint>? points;
  final List<GeoPoint> route; // New variable

  FloodMarkerRoute(this.points, this.route);

  List<FloodMarkerPoint>? get markerPoints => points;

  List<GeoPoint> get markerRoute => route;
}