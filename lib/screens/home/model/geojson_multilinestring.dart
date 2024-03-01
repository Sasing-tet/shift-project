import 'package:shift_project/screens/home/model/geojson_linestring.dart';

class GeoJsonMultiLineString {
  List<GeoJsonLineString> lineStrings;

  GeoJsonMultiLineString(this.lineStrings);

  Map<String, dynamic> toJson() {
    return {
      'type': 'MultiLineString',
      'o_coordinates': lineStrings.map((lineString) {
        return {
          'id': lineString.id,
          'coordinates': lineString.coordinatess,
        };
      }).toList(),
    };
  }
}