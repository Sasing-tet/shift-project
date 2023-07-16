// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geocoder_buddy/geocoder_buddy.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:marquee/marquee.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:shift_project/constants/constants.dart';
import 'package:shift_project/fetch/models/weather_data_model.dart';
import 'package:shift_project/screens/home/components/road_choice_widget.dart';
import 'package:shift_project/screens/home/components/weather_forecast_widget.dart';
import 'package:shift_project/widgets/drawer_widget.dart';

import '../../fetch/weather API/weather_forecast.dart';

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

  Future<void> drawRoadManually(List<String> encodedPolylines, RoadOption roadOp) async {
    for (var encoded in encodedPolylines) {
      final list = await encoded.toListGeo();
      await mapController.drawRoadManually(
        list,
         roadOp,
      );
    }
  }

  
Future<List<String>> fetchOSRMRoutePolylines(
    List<GeoPoint> coordinates) async {
  final String profile = 'driving';
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
      polylines.add(geometry);
    }

    return polylines;
  } else {
    throw Exception('Failed to fetch route polylines');
  }
}

  Future<List<String>> getDirections(
      GeoPoint start, GeoPoint destination) async {
    final String startCoords = '${start.latitude},${start.longitude}';
    final String destinationCoords =
        '${destination.latitude},${destination.longitude}';

    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$startCoords&destination=$destinationCoords&mode=driving&alternatives=true&key=AIzaSyBEUySx7hdG0n111W7NPXD9C8wLWFAqdjo';

    final response = await http.get(Uri.parse(url));
    List<String> polylines = [];

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      List routes = map["routes"];

      for (var i = 0; i < routes.length; i++) {
        var route = routes[i];
        var polyline = route["overview_polyline"]["points"];
        polylines.add(polyline);
      }
    } else {
      print('Failed to load directions');
    }
    print(polylines.toString());
    return polylines;
  }

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
        preferredSize: Size(double.infinity, isExpanded ? 250 : 110),
        child: SafeArea(
          child: Builder(builder: (context) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(2),
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
                  child: IconButton(
                    icon: const Icon(Icons.menu_sharp),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    iconSize: 30,
                  ),
                ),
                //WEATHER WIDGET
                Expanded(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.fastEaseInToSlowEaseOut,
                    child: GestureDetector(
                      onTap: () {
                        _toggleExpanded();
                      },
                      child: Container(
                        height: isExpanded ? double.infinity : null,
                        margin: EdgeInsets.only(
                          top: 10,
                          right: 10,
                          bottom: 10,
                        ),
                        padding: EdgeInsets.all(2),
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
                        child: WeatherForecastWidget(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
      extendBodyBehindAppBar: true,
      drawer: SafeArea(
        child: WeatherDrawer(),
      ),
      body: Stack(
        children: [
          currentPosition == null
              ? const Center(child: CircularProgressIndicator())
              :
              // : FlutterMap(
              //     mapController: mapController,
              //     options: MapOptions(
              //       center: currentPosition!,
              //       zoom: 17,
              //     ),
              //     children: [
              //       TileLayer(
              //         urlTemplate:
              //             "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              //         subdomains: const ['a', 'b', 'c'],
              //       ),
              //       CircleLayer(
              //         circles: [
              //           CircleMarker(
              //             point: currentPosition!,
              //             color: Colors.blue,
              //             radius: 8,
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              OSMFlutter(
                  enableRotationByGesture: true,
                  controller: mapController,
                  initZoom: 15,
                  minZoomLevel: 8,
                  maxZoomLevel: 19,
                  stepZoom: 12.0,
                  userLocationMarker: UserLocationMaker(
                    personMarker: const MarkerIcon(
                      icon: Icon(
                        Icons.person_pin_circle,
                        color: Colors.blueAccent,
                        size: 100,
                      ),
                    ),
                    directionArrowMarker: const MarkerIcon(
                      icon: Icon(
                        Icons.double_arrow,
                        size: 48,
                      ),
                    ),
                  ),
                  roadConfiguration: const RoadOption(
                    roadColor: Colors.yellowAccent,
                  ),
                  markerOption: MarkerOption(
                      defaultMarker: const MarkerIcon(
                    icon: Icon(
                      Icons.person_pin_circle,
                      color: Colors.blue,
                      size: 56,
                    ),
                  )),
                ),
          if (isMapOverlayVisible && isExpanded)
            GestureDetector(
              onTap: () {
                setState(() {
                  isMapOverlayVisible = false;
                  isExpanded = false;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.5),
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
                    onPressed: () {},
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
                        // mapController.move(currentPosition!, 17);
                        // setState(() {});
                        await mapController.currentLocation();
                        await mapController.enableTracking(
                          enableStopFollow: true,
                          disableUserMarkerRotation: true,
                        );
                        await mapController.zoomIn();
                      }
                    },
                  ),
                ),
                Container(
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
                        pointsRoad.add(await mapController.myLocation());

                        var p = await Navigator.pushNamed(context, "/search");
                        pointsRoad.add(p as GeoPoint);
                        //                     print(destination.toString());
                        // RoadInfo roadInformation =
                        // await mapController.drawRoad(
                        //   pointsRoad.first,
                        //   pointsRoad.last,
                        //   roadType: RoadType.car,
                        //   intersectPoint: pointsRoad
                        //       .getRange(1, pointsRoad.length - 1)
                        //       .toList(),
                        //   roadOption: RoadOption(
                        //     roadWidth: 2,
                        //     roadColor: Colors.red,
                        //     zoomInto: true,
                        //   ),
                        // // );
                        final getOSRMroutes = await fetchOSRMRoutePolylines(pointsRoad);
                        final getRoutes = await getDirections(
                            pointsRoad.first, pointsRoad.last);
                        
                        drawRoadManually(getRoutes, RoadOption(roadColor: Colors.red));
                         drawRoadManually(getOSRMroutes, RoadOption(roadColor: Colors.blue));

                        mapController.addMarker(p,
                            markerIcon: MarkerIcon(
                                icon: Icon(
                              Icons.pin_drop_rounded,
                              size: 100,
                              color: Colors.redAccent,
                            )));
                        pointsRoad.clear();
                        mapController.enableTracking(
                          enableStopFollow: true,
                          disableUserMarkerRotation: true,
                        );
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
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
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
                              flex: 3,
                              child: Column(
                                children: [
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    physics: BouncingScrollPhysics(),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 100,
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 5,
                                          ),
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 1,
                                              color: shiftGrayBorder,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                "Route 1",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: interFontFamily,
                                                  fontSize:
                                                      titleSubtitleFontSize,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                "via this street churva churva",
                                                style: TextStyle(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  color: shiftGrayBorder,
                                                  fontFamily: interFontFamily,
                                                  fontSize: defaultFontSize,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 100,
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 5,
                                          ),
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 1,
                                              color: shiftGrayBorder,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                "Route 2",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: interFontFamily,
                                                  fontSize:
                                                      titleSubtitleFontSize,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                "via this street churva churva",
                                                style: TextStyle(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  color: shiftGrayBorder,
                                                  fontFamily: interFontFamily,
                                                  fontSize: defaultFontSize,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 100,
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 5,
                                          ),
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 1,
                                              color: shiftGrayBorder,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                "Route 3",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: interFontFamily,
                                                  fontSize:
                                                      titleSubtitleFontSize,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                "via this street churva churva",
                                                style: TextStyle(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  color: shiftGrayBorder,
                                                  fontFamily: interFontFamily,
                                                  fontSize: defaultFontSize,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Container(
                                margin: EdgeInsets.only(left: 10),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: shiftBlue,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
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
                                      fontSize: titleSubtitleFontSize,
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
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     if (currentPosition != null) {
      //       mapController.move(currentPosition!, 17);
      //       setState(() {});
      //     }
      //   },
      //   child: const Icon(Icons.my_location),
      // ),
    );
  }

  void roadActionBt(BuildContext ctx, GeoPoint origin, destination) async {
    try {
      ///selection geoPoint

      // final bottomPersistant = scaffoldKey.currentState!.showBottomSheet(
      //   (ctx) {
      //     return PointerInterceptor(
      //       child: RoadTypeChoiceWidget(
      //         setValueCallback: (roadType) {
      //           notifierRoadType.value = roadType;
      //         },
      //       ),
      //     );
      //   },
      //   backgroundColor: Colors.transparent,
      //   elevation: 0.0,
      // );
      // await bottomPersistant.closed.then((roadType) async {

      // RoadInfo roadInformation = await mapController.drawRoad(
      //  origin,
      // destination,
      //   roadType: RoadType.car,
      //   intersectPoint: pointsRoad.getRange(1, pointsRoad.length - 1).toList(),
      //   roadOption: RoadOption(
      //     roadWidth: 2,
      //     roadColor: Colors.red,
      //     zoomInto: true,

      //   ),
      // );

      final getRoutes = await getDirections(origin, destination);
      drawRoadManually(getRoutes, RoadOption(roadColor: Colors.green));

      // debugPrint(
      //     "app duration:${Duration(seconds: roadInformation.duration!.toInt()).inMinutes}");
      // debugPrint("app distance:${roadInformation.distance}Km");
      // debugPrint("app road:" + roadInformation.toString());
      // final console = roadInformation.instructions
      //     .map((e) => e.toString())
      //     .reduce(
      //       (value, element) => "$value -> \n $element",
      //     )
      //     .toString();
      // debugPrint(
      //   console,
      //   wrapWidth: console.length,
      // );
      // final box = await BoundingBox.fromGeoPointsAsync(
      //     [pointsRoad.first, pointsRoad.last]);
      // mapController.zoomToBoundingBox(
      //   box,
      //   paddinInPixel: 64,
      // );
    } on RoadException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${e.errorMessage()}",
          ),
        ),
      );
    }
  }
}
