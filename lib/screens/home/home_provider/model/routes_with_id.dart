

import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class RoutesWithId {
  final String id;
  final List<GeoPoint> points;

  RoutesWithId({required this.id, required this.points});

  // Getters for id and points
  String get getId => id;
  List<GeoPoint> get getPoints => points;

  // No setters needed as the properties are final
}
