
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:shift_project/screens/home/dataTemp/highflodd.dart';
import 'package:shift_project/screens/home/dataTemp/lowflood.dart';
import 'package:shift_project/screens/home/dataTemp/mediumflood.dart';
import 'package:shift_project/screens/home/model/flood_marker_points.dart';

class Ops{
    static Future<void> drawRoadManually(List<String> encodedPolylines, MapController mapController) async {
    for (var i = 0; i < encodedPolylines.length; i++) {
      final encoded = encodedPolylines[i];
      final list = await encoded.toListGeo();
      debugPrint(list.toString());
      final roadOption = i == 0
          ? const RoadOption(
              roadColor: Color.fromARGB(181, 71, 19, 16),
              roadWidth: 8,
            ) // Full opacity for the first polyline
          : const RoadOption(
              roadColor: Colors.red, roadWidth: 8); // 80% opacity for the rest

      await mapController.drawRoadManually(list, roadOption);
    }
  }

  static Future<List<String>> fetchOSRMRoutePolylines(
      List<GeoPoint> coordinates) async {
    const String profile = 'driving';
    final String coordinatesString = coordinates
        .map((coord) => '${coord.longitude},${coord.latitude}')
        .join(';');

    final String url =
        'https://router.project-osrm.org/route/v1/$profile/$coordinatesString?alternatives=true&steps=true&geometries=polyline&overview=full&annotations=false';

    final response = await http.get(Uri.parse(url));
    List<String> polylines = [];

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      List routes = map["routes"];

      for (var route in routes) {
        var geometry = route['geometry'];
        geometry != " " ? polylines.add(geometry) : geometry.clear();
      }
      print(polylines.toString());
      return polylines;
    } else {
      throw Exception('Failed to fetch route polylines');
    }
  }

 


  static Future<void> drawCircle(MapController mapController) async {
    final circle = CircleOSM(
      key: 'circle1',
      centerPoint: GeoPoint(latitude: 10.3157, longitude: 123.8854),
      radius: 5000,
      color: Colors.blue.withOpacity(0.3),
      strokeWidth: 2,
    );

    await mapController.drawCircle(circle);
  }

  static bool isBetween(GeoPoint a, GeoPoint b, GeoPoint c, {double epsilon = 1e-8}) {
  double crossProduct =
      (c.latitude - a.latitude) * (b.longitude - a.longitude) -
      (c.longitude - a.longitude) * (b.latitude - a.latitude);

  if ((crossProduct).abs() > epsilon) {
    return false;
  }

  double dotProduct = (c.longitude - a.longitude) * (b.longitude - a.longitude) +
      (c.latitude - a.latitude) * (b.latitude - a.latitude);

  if (dotProduct < 0 || dotProduct > (b.longitude - a.longitude) * (b.longitude - a.longitude) +
      (b.latitude - a.latitude) * (b.latitude - a.latitude)) {
    return false;
  }

  return true;
}




static Future<Map<String, List<List<GeoPoint>>>> getPointsOnPolylines(List<String> polylines, Map<String, List<List<GeoPoint>>> markerPoints, {double epsilon = 1e-8}) async {
  Map<String, List<List<GeoPoint>>> pointsOnPolylines = {};

  for (int polylineIndex = 0; polylineIndex < polylines.length; polylineIndex++) {
    List<GeoPoint> polyline = await polylines[polylineIndex].toListGeo();

    for (var entry in markerPoints.entries) {
      String level = entry.key;
      List<List<GeoPoint>> pointGroups = entry.value;
      List<List<GeoPoint>> groupedPoints = [];

      for (var groupPoints in pointGroups) {
        List<GeoPoint> currentGroup = [];

        for (var markerPoint in groupPoints) {
          for (int i = 0; i < polyline.length - 1; i++) {
            if (isBetween(polyline[i], polyline[i + 1], markerPoint, epsilon: epsilon)) {
              currentGroup.add(markerPoint);
              // break;
            }
          }
        }

        if (currentGroup.isNotEmpty) {
          print(currentGroup.toList().toString());
          groupedPoints.add(currentGroup);
        }
        
      }

      if (groupedPoints.isNotEmpty) {
        if (pointsOnPolylines.containsKey(level)) {
          pointsOnPolylines[level]!.addAll(groupedPoints);
        } else {
          pointsOnPolylines[level] = groupedPoints;
        }
      }
    }
  }

  debugPrint(pointsOnPolylines.toString());
  return pointsOnPolylines;
}





static Color getMarkerColor(String level) {
  // Add logic to determine marker color based on the susceptibility level
  if (level == 'Low') {
    return Colors.green;
  } else if (level == 'Medium') {
    return Colors.orange;
  } else {
    return Colors.red;
  }
}

static void addMarkersToMap(Map<String, List<List<GeoPoint>>> pointsOnPolyline, MapController mapController) async {
  for (var entry in pointsOnPolyline.entries) {
    String level = entry.key;
    List<List<GeoPoint>> groupsOfPoints = entry.value;
   print(level);
    for (var groupPoints in groupsOfPoints) {
      // Get the marker color based on the level
      Color markerColor = getMarkerColor(level);

      
     
        // Add the marker to the map
        await mapController.addMarker(
          groupPoints.first,
          markerIcon: MarkerIcon(
            icon: Icon(
              Icons.flood,
              color: markerColor, // Set the marker color based on the level
              size: 50,
            ),
          ),
        );
      
    }
  }
}






static List<List<GeoPoint>> extractGeoPoints(String geoJsonString) {
  List<List<GeoPoint>> geoPointsList = [];

  Map<String, dynamic> geoJsonData = jsonDecode(geoJsonString);
  List<dynamic> features = geoJsonData['features'];

  for (dynamic feature in features) {
    dynamic geometry = feature['geometry'];
    if (geometry != null && geometry['type'] == 'MultiLineString') {
      List<dynamic> lines = geometry['coordinates'];

      for (dynamic line in lines) {
        List<GeoPoint> geoPoints = [];

        for (dynamic point in line) {
          double longitude = point[0].toDouble();
          double latitude = point[1].toDouble();
          geoPoints.add(GeoPoint(latitude: latitude, longitude: longitude));
        }

        if (geoPoints.isNotEmpty) {
          geoPointsList.add(geoPoints);
        }
      }
    }
  }

  return geoPointsList;
}



  static List<FloodMarkerPoint> processDataAndAddToMarkerPoints() {
    List<List<GeoPoint>> highGeoPoints = Ops.extractGeoPoints(highfloodgeojson);
    List<List<GeoPoint>> midGeoPoints = Ops.extractGeoPoints(medFloodgeojson);
    List<List<GeoPoint>> lowGeoPoints = Ops.extractGeoPoints(lowGeojson);

    // Create new FloodMarkerPoints and update the markerPoints list
    final newMarkerPoints = [
      FloodMarkerPoint('Low', lowGeoPoints),
      FloodMarkerPoint('Medium', midGeoPoints),
      FloodMarkerPoint('High', highGeoPoints),
      // Add more FloodMarkerPoint instances as needed
    ];

    return newMarkerPoints;

  }
 

}

