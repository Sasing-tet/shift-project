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

  Future<void> drawRoadManually(List<String> encodedPolylines) async {
    for (var encoded in encodedPolylines) {
      final list = await encoded.toListGeo();
      await mapController.drawRoadManually(
        list,
        RoadOption(
          zoomInto: true,
          roadColor: Colors.blueAccent,
        ),
      );
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

  Future<void> fetchWeatherData1(double latitude, double longitude) async {
    final dio = Dio();
    // final position = await Geolocator.getCurrentPosition(
    //   desiredAccuracy: LocationAccuracy.high,
    // );
    // final latitude = position.latitude;
    // final longitude = position.longitude;
    final response1 = await dio.get(
      'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&hourly=temperature_2m,rain,showers',
    );
    final response = await dio.get(
      'https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.419&hourly=temperature_2m,rain,showers',
    );

    if (response.statusCode == 200) {
      final data = response.data;
      // Process the weather forecast data

      final currentWeather = data['hourly']['temperature_2m'][0];
      final hourlyForecastTime = data['hourly']['time'];
      final hourlyForecastTemp = data['hourly']['temperature_2m'];
      final hourlyForecastRain = data['hourly']['rain'];

      // Process the current weather and hourly forecast data
      print(data);
      print('Current Weather: $currentWeather');
      print('Hourly Forecast Time: $hourlyForecastTime');
      print('Hourly Forecast Temperatures: $hourlyForecastTemp');
      print('Hourly Forecast Rain: $hourlyForecastRain');
    } else {
      print('Failed to fetch weather data: ${response.statusCode}');
    }
  }

  Future<String?> getAddressFromCoordinates(
      double latitude, double longitude) async {
    //USING NOMINATIM
    final url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResult = jsonDecode(response.body);
        final address = jsonResult['display_name'];
        return address;
      }
    } catch (e) {
      print('Failed to get address: $e');
    }

    //GEOCODER_BUDDY PLUGIN NOT WORKING IDK WHY
    // try {
    //   GBLatLng position = GBLatLng(lat: latitude, lng: longitude);
    //   GBData data = await GeocoderBuddy.findDetails(position);

    //   String road = data.address.road;
    //   String street = data.address.village;
    //   String county = data.address.county;

    //   String state = data.address.state;
    //   String stateDistrict = data.address.stateDistrict;
    //   String postalCode = data.address.postcode;
    //   String country = data.address.country;

    //   String formattedAddress =
    //       '$road, $street, $county, $state, $stateDistrict, $postalCode, $country';

    //   return formattedAddress;
    // } catch (e) {
    //   print('Failed to get address: $e');
    // }

    //USING GEOCODING PLUGIN
    // try {
    //   final List<Placemark> placemarks =
    //       await placemarkFromCoordinates(latitude, longitude);
    //   final Placemark placemark = placemarks.first;
    //   final address = placemark.street ?? '';
    //   final city = placemark.locality ?? '';
    //   final state = placemark.administrativeArea ?? '';
    //   final country = placemark.country ?? '';
    //   final postalCode = placemark.postalCode ?? '';

    //   return '$address, $city, $state, $country, $postalCode';
    // } catch (e) {
    //   print('Failed to get address: $e');
    // }
    return null;
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
                  child: GestureDetector(
                    onTap: () {
                      _toggleExpanded();
                    },
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.fastEaseInToSlowEaseOut,
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
                        child: FutureBuilder<WeatherData>(
                          future: fetchWeatherData(
                              currentPosition?.latitude ?? 0.0,
                              currentPosition?.longitude ?? 0.0),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Text('Failed to fetch weather data');
                            } else {
                              final weatherData = snapshot.data!;
                              return FutureBuilder<String?>(
                                future: getAddressFromCoordinates(
                                  currentPosition?.latitude ?? 0.0,
                                  currentPosition?.longitude ?? 0.0,
                                ),
                                builder: (context, addressSnapshot) {
                                  if (addressSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  } else if (addressSnapshot.hasError) {
                                    return Text('Failed to fetch address');
                                  } else {
                                    final address = addressSnapshot.data ??
                                        'Unknown Address';
                                    return Row(
                                      children: [
                                        Flexible(
                                          flex: 2,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 10,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${weatherData.currentTemperature}${weatherData.currentWeatherUnit}',
                                                  style: TextStyle(
                                                    fontSize: titleFontSize,
                                                    fontFamily: interFontFamily,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Container(
                                                  height: 20,
                                                  child: Marquee(
                                                    text: address,
                                                    style: TextStyle(
                                                      fontSize:
                                                          titleSubtitleFontSize,
                                                      fontFamily:
                                                          interFontFamily,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    scrollAxis: Axis.horizontal,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    blankSpace: 20.0,
                                                    velocity: 30.0,
                                                    pauseAfterRound:
                                                        Duration(seconds: 1),
                                                    startPadding: 10.0,
                                                    accelerationDuration:
                                                        Duration(seconds: 1),
                                                    accelerationCurve:
                                                        Curves.linear,
                                                    decelerationDuration:
                                                        Duration(seconds: 2),
                                                    decelerationCurve:
                                                        Curves.easeOut,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Flexible(
                                          flex: 1,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 10,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.thunderstorm,
                                                  size: 40,
                                                  color: Colors.blue,
                                                ),
                                                Container(
                                                  height: 18,
                                                  child: Marquee(
                                                    text: 'Heavy Rain',
                                                    style: TextStyle(
                                                      fontSize:
                                                          titleSubtitleFontSize,
                                                      fontFamily:
                                                          interFontFamily,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    scrollAxis: Axis.horizontal,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    blankSpace: 20.0,
                                                    velocity: 10.0,
                                                    pauseAfterRound:
                                                        Duration(seconds: 1),
                                                    startPadding: 10.0,
                                                    accelerationDuration:
                                                        Duration(seconds: 1),
                                                    accelerationCurve:
                                                        Curves.linear,
                                                    decelerationDuration:
                                                        Duration(seconds: 2),
                                                    decelerationCurve:
                                                        Curves.easeOut,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              );
                            }
                          },
                        ),
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
                  androidHotReloadSupport: true,
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
                      onPressed: () {
                        beginDrawRoad.value = true;
                        mapController.listenerMapSingleTapping
                            .addListener(() async {
                          if (mapController.listenerMapSingleTapping.value !=
                              null) {
                            print(mapController.listenerMapSingleTapping.value);
                            if (beginDrawRoad.value) {
                              pointsRoad.add(mapController
                                  .listenerMapSingleTapping.value!);
                              await mapController.addMarker(
                                mapController.listenerMapSingleTapping.value!,
                                markerIcon: MarkerIcon(
                                  icon: Icon(
                                    Icons.person_pin_circle,
                                    color: Colors.amber,
                                    size: 48,
                                  ),
                                ),
                              );

                              roadActionBt(context);
                            }
                          }
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_pin,
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

  void roadActionBt(BuildContext ctx) async {
    try {
      ///selection geoPoint

      showFab.value = false;
      pointsRoad.add(await mapController.myLocation());

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
      showFab.value = true;
      beginDrawRoad.value = false;
      RoadInfo roadInformation = await mapController.drawRoad(
        pointsRoad.first,
        pointsRoad.last,
        roadType: RoadType.car,
        intersectPoint: pointsRoad.getRange(1, pointsRoad.length - 1).toList(),
        roadOption: RoadOption(
          roadWidth: 15,
          roadColor: Colors.red,
          zoomInto: true,
          roadBorderWidth: 2,
          roadBorderColor: Colors.green,
        ),
      );

      final getRoutes = await getDirections(pointsRoad.first, pointsRoad.last);
      drawRoadManually(getRoutes);
      pointsRoad.clear();
      debugPrint(
          "app duration:${Duration(seconds: roadInformation.duration!.toInt()).inMinutes}");
      debugPrint("app distance:${roadInformation.distance}Km");
      debugPrint("app road:" + roadInformation.toString());
      final console = roadInformation.instructions
          .map((e) => e.toString())
          .reduce(
            (value, element) => "$value -> \n $element",
          )
          .toString();
      debugPrint(
        console,
        wrapWidth: console.length,
      );
      final box = await BoundingBox.fromGeoPointsAsync(
          [pointsRoad.first, pointsRoad.last]);
      mapController.zoomToBoundingBox(
        box,
        paddinInPixel: 64,
      );
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
