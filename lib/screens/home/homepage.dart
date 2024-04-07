// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace


import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:shift_project/screens/home/components/buttons/choose_destination.dart';
import 'package:shift_project/screens/home/components/buttons/clear_button.dart';
import 'package:shift_project/screens/home/components/buttons/floodProne_button.dart';
import 'package:shift_project/screens/home/components/buttons/go_button.dart';
import 'package:shift_project/screens/home/components/buttons/stop_button.dart';
import 'package:shift_project/screens/home/components/buttons/user_location_button.dart';
import 'package:shift_project/screens/home/components/route_buttons_container.dart';
import 'package:shift_project/screens/home/components/routes_buttons_display.dart';
import 'package:shift_project/screens/home/home_widgets/appbar_widget.dart';
import 'package:shift_project/screens/home/model/flood_marker_points.dart';
import 'package:shift_project/screens/home/provider/operations_provider.dart';
import 'package:shift_project/screens/home/srvc.dart';
import 'package:shift_project/widgets/drawer_widget.dart';

import '../../states/auth/backend/authenticator.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePage();
}

class _HomePage extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late GlobalKey<ScaffoldState> scaffoldKey;
  LatLng? currentPosition;
  late MapController mapController;
  bool isExpanded = false;
  bool isMapOverlayVisible = true;
  late AnimationController _animationController;
  late final List<FloodMarkerPoint> markerPoints;
  final _authenticator = const Authenticator();

  @override
  initState() {
    super.initState();
    _userLoc();
    mapController = MapController.withUserPosition(
        trackUserLocation: const UserTrackingOption(
      enableTracking: true,
      unFollowUser: false,
    ));

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  void _userLoc() async {
    final position = await Srvc.determinePosition(context);
    setState(() {
      currentPosition = position;
    
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opProvider = ref.read(opsProvider.notifier);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 250),
        child: MyAppBar( opsNotifier: opProvider),
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
                ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 15,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              FloodProneButton(),
              UserLocationButton(
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
              Consumer(builder: (context, ref, child) {
                final startAndDestination = ref.watch(opsProvider).pointsRoad;
                final weatherCose = ref.watch(opsProvider).weatherData;
                final operationsProvider = ref.read(opsProvider.notifier);
                final polylinezzNotifierValue =
                    ref.watch(opsProvider).polylinezzNotifier;
                    final goNotifier = ref.watch(opsProvider).goNotifier;
                final routes = ref.watch(opsProvider).routes;
                final routeCHOSEN = ref.watch(opsProvider).routeCHOSEN;
                final myRoute = ref.watch(opsProvider).myRoute;
        
                
                return polylinezzNotifierValue
                    ?  goNotifier ? StopButton(
                                    onTap: () async {
                                      await Srvc.removeAllMarkers(
                                          routes!, mapController);
                                      mapController.clearAllRoads();
                                      operationsProvider.clearAllData();
                                      String? driverId = _authenticator.userId;
                                      await Srvc.sendSavedRoute(myRoute, driverId);
                                      await Srvc.fetchFloodPoints(driverId);
                                    },): Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClearButton(
                            onPressed: () async {
                              await Srvc.removeAllMarkers(
                                  routes!, mapController);
                              mapController.clearAllRoads();
                              operationsProvider.clearAllData();
                            },
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child:
                                   RouteButtonsContainer(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: RouteButtons(
                                        routes: routes!,
                                        mapController: mapController,
                                        opsNotifier: operationsProvider,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    GoButton(
                                      onTap: () async {
                                        if(startAndDestination != null &&startAndDestination.length == 2){
                                      operationsProvider.stopButtonNotifier();
                                      operationsProvider.clearMyRoute();
                                      operationsProvider.addNewPointToMyRoute( await mapController.myLocation());
                                        Srvc.updateLocation(
                                            routeCHOSEN!,
                                            mapController,
                                            _animationController,
                                            operationsProvider,
                                            context);

                                        }


                                        // Srvc.sendSavedRoute(myRoute, driverId)

                                           
                                      },
                                   
                                    )
                                  ],
                                ),
                              ))
                            ],
                          )
                        ],
                      )
                    : ChooseDestinationButton(
                        onPressed: () async {
                          String? driverId = _authenticator.userId;
                          var p = await Navigator.pushNamed(context, "/search");
                          operationsProvider
                              .addPointToRoad(await mapController.myLocation());
                          operationsProvider.addPointToRoad(p as GeoPoint);
                          operationsProvider.fetchAndDrawRoute(driverId,
                              mapController, weatherCose!);
                          operationsProvider.insertRideEntry(await mapController.myLocation(), p, driverId);
                        },
                      );
              })
            ]),
          )
        ],
      ),
    );
  }
}
