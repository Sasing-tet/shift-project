import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class FloodMarkerPoint {
  
  final String level;
  final List<List<GeoPoint>> points;

  FloodMarkerPoint(this.level, this.points);

  String get floodLevel => level;

  List<List<GeoPoint>> get markerPoints => points;

}