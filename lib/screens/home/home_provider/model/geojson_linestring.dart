import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:uuid/uuid.dart';

class GeoJsonLineString {
  String type = 'LineString';
  List<List<double>>? _coordinates; // Private field for coordinates
  late String _id; // Private field for id

  GeoJsonLineString(List<GeoPoint>? points) {
    _id = const Uuid().v4(); // Generate id when an instance is created
    _coordinates = points?.map((point) => [point.longitude, point.latitude]).toList();
  }

  // Getter for coordinates
  List<List<double>>? get coordinatess => _coordinates;

  // Setter for coordinates
  set coordinates(List<List<double>>? value) {
    _coordinates = value;
  }

  // Getter for id
  String get id => _id;

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'o_routeid': _id,
      'coordinates': _coordinates,
    };
  }
}
