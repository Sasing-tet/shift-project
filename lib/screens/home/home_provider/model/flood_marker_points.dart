import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class FloodMarkerPoint {
  
   final int score;
   final String intersectId;
  final String level;
  final List<List<GeoPoint>> points;

  FloodMarkerPoint(this.level, this.points, this.score, this.intersectId);

  int get floodScore => score;
  String get intersect => intersectId;
  String get floodLevel => level;
  List<List<GeoPoint>> get markerPoints => points;

}