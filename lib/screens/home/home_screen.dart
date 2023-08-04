// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shift_project/constants/constants.dart';
import 'package:shift_project/screens/floodProneDataScreen/flood_prone_area_screen.dart';
import 'package:shift_project/screens/home/components/route_button_widget.dart';
import 'package:shift_project/screens/home/dataTemp/highflodd.dart';
import 'package:shift_project/screens/home/dataTemp/lowflood.dart';
import 'package:shift_project/screens/home/dataTemp/mediumflood.dart';
import 'package:shift_project/screens/home/home_widgets/appbar_widget.dart';
import 'package:shift_project/screens/home/services.dart';
import 'package:shift_project/widgets/drawer_widget.dart';
import 'dart:math' as math;

Map<String, List<List<GeoPoint>>> susPoints = {};

Map<String, List<List<GeoPoint>>> markerPoints = {
  'Low': [
    [
   
    ],
  ],
  'Medium': [
    [
 
      // Add more points for the 'Medium' level as needed
    ],
  ],
  'High': [
    [
   
      // Add more points for the 'High' level as needed
    ],
  ],
};

List<GeoPoint> userPath = [];
List<GeoPoint> routes = [];
List<GeoPoint> routesCHOSEN = [];



class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late GlobalKey<ScaffoldState> scaffoldKey;
  LatLng? currentPosition;
  late MapController mapController;
  bool isExpanded = false;
  bool isMapOverlayVisible = true;
  late AnimationController _animationController;
  late Animation<double> _animation;
  ValueNotifier<bool> showFab = ValueNotifier(true);
  ValueNotifier<GeoPoint?> lastGeoPoint = ValueNotifier(null);
  ValueNotifier<bool> beginDrawRoad = ValueNotifier(false);
  ValueNotifier<bool> polylinezzNotifier = ValueNotifier(false);
  List<String> polylinezz = [];

  List<GeoPoint> pointsRoad = [];
  Map<String, dynamic> details = {};



  @override
  void initState() {
    super.initState();
    _determinePosition();
    mapController = MapController.withUserPosition(
        trackUserLocation: const UserTrackingOption(
      enableTracking: true,
      unFollowUser: false,
    ));

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animationController.dispose();
    mapController.dispose();
    super.dispose();
  }

void processDataAndAddToMarkerPoints() {
  List<List<GeoPoint>> highGeoPoints = Ops.extractGeoPoints(highfloodgeojson);
  List<List<GeoPoint>> midGeoPoints = Ops.extractGeoPoints(medFloodgeojson);
  List<List<GeoPoint>> lowGeoPoints = Ops.extractGeoPoints(lowGeojson);

  markerPoints['Low']!.addAll(lowGeoPoints);
  markerPoints['Medium']!.addAll(midGeoPoints);
  markerPoints['High']!.addAll(highGeoPoints);

 

  // Categorize the GeoPoints based on their susceptibility level and add them to the corresponding list.
}
// Function to convert the given points to a list of bg.Coordinate objects

// Function to create the geofence polygon from the given points


  Future<void> _determinePosition() async {
    bool serviceEnabled;
    PermissionStatus permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Location Services Disabled'),
          content:
              const Text('Please enable location services to use this app.'),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    permission = await Permission.locationWhenInUse.status;
    if (permission.isDenied) {
      permission = await Permission.locationWhenInUse.request();
      if (permission.isDenied) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Location Permissions Denied'),
            content: const Text(
                'Please grant location permissions to use this app.'),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
        return;
      }
    }

    if (permission.isPermanentlyDenied) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Location Permissions Denied'),
          content: const Text(
              'Please enable location permissions from the app settings.'),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    final position = await Geolocator.getCurrentPosition();

    setState(() {
      currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  void _updateLocation(Map<String, List<List<GeoPoint>>> sus) async {
    if (routesCHOSEN.isNotEmpty) {
      final dynamicPolylinePoints = routesCHOSEN.toList();
      final myposition = await mapController.myLocation();

      final dist =
          await distance2point(myposition, dynamicPolylinePoints.first);
      final prevDist = dist;
      print(dist.toString() + 'hey');

      if (dist < 10) {
        routesCHOSEN.removeAt(0);
        // mapController.removeLastRoad();

        // mapController.drawRoadManually(
        //     routesCHOSEN, RoadOption(roadColor: Colors.blue, roadWidth: 15));

        if (routesCHOSEN.isEmpty) {
          _animationController.stop();
          return;
        }
        checkFloodProneArea(myposition,10,sus);

      }
      Future.delayed(Duration(seconds: 1), () => _updateLocation(sus));
    }
  }


  final List<GeoPoint> floodProneAreaPolyline = [
 GeoPoint(latitude: 10.3141958 , longitude: 123.881018), GeoPoint(latitude: 10.3141498 , longitude: 123.8809266)
  // Add more Geopoints to define the polyline shape of the flood-prone area
];

// Function to calculate the distance between two Geopoints using the Haversine formula


// Function to check if a Geopoint is within a certain distance of the polyline
Future<bool> isWithinFloodProneArea(GeoPoint point, double maxDistance, List<GeoPoint> polyline) async {
  for (int i = 0; i < polyline.length - 1; i++) {
    GeoPoint point1 = polyline[i];
    GeoPoint point2 = polyline[i + 1];

    double distanceToSegment = await calculateDistanceToSegment(point, point1, point2);

    if (distanceToSegment <= maxDistance) {
      return true;
    }
  }

  return false;
}

// Function to calculate the distance between a point and a line segment
Future<double> calculateDistanceToSegment(GeoPoint point, GeoPoint segmentStart, GeoPoint segmentEnd) async {
  double segmentLength =await distance2point(segmentStart, segmentEnd);

  if (segmentLength == 0) {
    return distance2point(point, segmentStart);
  }

  double t = math.max(0, math.min(1, ((point.latitude - segmentStart.latitude) *
      (segmentEnd.latitude - segmentStart.latitude) +
      (point.longitude - segmentStart.longitude) *
          (segmentEnd.longitude - segmentStart.longitude)) /
      (segmentLength * segmentLength)));

  double nearestLatitude = segmentStart.latitude + t * (segmentEnd.latitude - segmentStart.latitude);
  double nearestLongitude = segmentStart.longitude + t * (segmentEnd.longitude - segmentStart.longitude);

  return distance2point(point, GeoPoint(latitude: nearestLatitude, longitude:nearestLongitude));
}

void showAlertDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Flood-Prone Area'),
        content: Text(message),
      );
    },
  );

  // Automatically close the AlertDialog after 2 seconds
  Timer(Duration(seconds: 2), () {
    Navigator.of(context).pop();
  });
}

Future<void> checkFloodProneArea(GeoPoint userLocation, double maxDistance, Map<String, List<List<GeoPoint>>> floodProneArea) async {
  Map<String, List<List<GeoPoint>>> floodProneAreaPolyline = floodProneArea;

  floodProneAreaPolyline.forEach((level, polylines) async {
    for (var polyline in polylines) {
      bool isInside = await isWithinFloodProneArea(userLocation, maxDistance, polyline);
      if (isInside) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('You are within a $level flood-prone area. Please be cautious.'),
        //     duration: Duration(seconds: 3), // The duration for which the snackbar is displayed
        //   ),
        // );
        // return; // Stop further checks if the user is already inside a flood-prone area

        showAlertDialog(context, 'You are within a $level flood-prone area. Please be cautious.');
        return;
      }
    }
  });

  print('You are not in a flood-prone area. Safe to proceed.');
}

  void _toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
      if (!isExpanded) {
        isMapOverlayVisible = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 250),
        child: MyAppBar(),
      ),
      extendBodyBehindAppBar: true,
      drawer: SafeArea(
        child: WeatherDrawer(),
      ),
      body: Stack(
        children: [
          currentPosition == null
              ? const Center(child: CircularProgressIndicator())
              : OSMFlutter(
                  enableRotationByGesture: true,
                  controller: mapController,
                  initZoom: 15,
                  minZoomLevel: 8,
                  maxZoomLevel: 19,
                  stepZoom: 12.0,
                  userLocationMarker: UserLocationMaker(
                    personMarker: const MarkerIcon(
                      icon: Icon(
                        Icons.location_on,
                        color: Colors.blueAccent,
                        size: 100,
                      ),
                    ),
                    directionArrowMarker: const MarkerIcon(
                      icon: Icon(
                        Icons.navigation,
                        color: Colors.blueAccent,
                        size: 100,
                      ),
                    ),
                  ),
                  roadConfiguration: const RoadOption(
                    roadColor: Colors.yellowAccent,
                  ),
                ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(
                    bottom: 12,
                    left: 15,
                  ),
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 241, 197, 0),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.warning_rounded,
                      size: 35,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FloodProneScreen(),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    bottom: 12,
                    left: 15,
                  ),
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.my_location,
                      size: 35,
                    ),
                    onPressed: () async {
                      if (currentPosition != null) {
                        await mapController.currentLocation();
                        await mapController.enableTracking(
                          enableStopFollow: true,
                        );
                        await mapController.zoomIn();
                      }
                    },
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: polylinezzNotifier,
                  builder: (context, value, child) {
                    return value
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                  left: 15,
                                ),
                                padding: EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: shiftRed,
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.location_pin,
                                    size: 35,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    mapController.clearAllRoads();
                                    polylinezz.clear();

                                    setState(() {
                                      polylinezzNotifier.value = false;
                                    });
                                  },
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 100,
                                      margin: EdgeInsets.all(16),
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 2,
                                            blurRadius: 10,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: RouteButtons(
                                              polylinezz: polylinezz,
                                              mapController: mapController,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          GestureDetector(
                                            onTap: () async {
                                              routesCHOSEN.addAll(routes);
                                              mapController.clearAllRoads();
                                              routesCHOSEN.insert(
                                                0,
                                                await mapController
                                                    .myLocation(),
                                              );
                                              mapController.drawRoadManually(
                                                routesCHOSEN,
                                                RoadOption(
                                                    roadColor: Colors.blue,
                                                    roadWidth: 15),
                                              );
                                              print(routesCHOSEN.toString());
                                              // Ops.addGeofence();
                                              // Ops.setupGeofence();
                                              _updateLocation(susPoints);
                                            },
                                            child: Container(
                                              width: 60,
                                              decoration: BoxDecoration(
                                                color: shiftBlue,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.5),
                                                    spreadRadius: 2,
                                                    blurRadius: 5,
                                                    offset: Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "Go",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: interFontFamily,
                                                    fontSize:
                                                        titleSubtitleFontSize,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Container(
                            margin: EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Builder(builder: (ctx) {
                              return TextButton(
                                style: chooseDestination,
                                onPressed: () async {
                                  pointsRoad
                                      .add(await mapController.myLocation());
                                  var p = await Navigator.pushNamed(
                                      context, "/search");

                                  pointsRoad.add(p as GeoPoint);
                                  polylinezz.addAll(
                                      await Ops.fetchOSRMRoutePolylines(
                                          pointsRoad));

                                  processDataAndAddToMarkerPoints();
                                   susPoints =
                                      await Ops.getPointsOnPolylines(
                                          polylinezz, markerPoints);
                                     
                                         
                               
// Assuming you have a MapController instance called 'mapController'

    Ops.addMarkersToMap(susPoints, mapController);

                                  Ops.drawRoadManually(
                                      polylinezz, mapController);

                                  // mapController.addMarker(pointsRoad.last,
                                  //     markerIcon: MarkerIcon(
                                  //         icon: Icon(
                                  //       Icons.pin_drop_rounded,
                                  //       size: 100,
                                  //       color: Colors.redAccent,
                                  //     )));

                                  pointsRoad.clear();
                                  mapController.enableTracking(
                                    enableStopFollow: false,
                                    disableUserMarkerRotation: false,
                                  );
                                  setState(() {
                                    polylinezzNotifier.value = true;
                                  });
                                
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.pin_drop_rounded,
                                      size: 25,
                                      color: Colors.redAccent,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      'Choose Destination',
                                      style: TextStyle(
                                        fontFamily: interFontFamily,
                                        fontSize: titleSubtitleFontSize,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RouteButtons extends StatelessWidget {
  const RouteButtons({
    super.key,
    required this.polylinezz,
    required this.mapController,
  });

  final List<String> polylinezz;
  final MapController mapController;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: polylinezz.length,
      itemBuilder: (context, index) {
        final poly = polylinezz[index];
        final roadColor = Colors.red;

        return GestureDetector(
          onTap: () async {
            mapController.clearAllRoads();
            final list = await poly.toListGeo();
            mapController.drawRoadManually(
              list,
              RoadOption(
                roadColor: roadColor,
                roadWidth: 3,
              ),
            );
            mapController.zoomOut();
            routes.clear();
            final route = await polylinezz[index].toListGeo();
            debugPrint(route.toString());
            routes.addAll(route);
          },
          child: RouteOptionWidget(i: index),
        );
      },
    );
  }
}
