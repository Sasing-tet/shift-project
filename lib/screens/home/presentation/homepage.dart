// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:shift_project/screens/home/home_widgets/components/buttons/choose_destination.dart';
import 'package:shift_project/screens/home/home_widgets/components/buttons/clear_button.dart';
import 'package:shift_project/screens/home/home_widgets/components/buttons/floodProne_button.dart';
import 'package:shift_project/screens/home/home_widgets/components/buttons/go_button.dart';
import 'package:shift_project/screens/home/home_widgets/components/buttons/stop_button.dart';
import 'package:shift_project/screens/home/home_widgets/components/buttons/user_location_button.dart';
import 'package:shift_project/screens/home/home_widgets/components/loadingscreen/loading_screen.dart';
import 'package:shift_project/screens/home/home_widgets/components/route_buttons_container.dart';
import 'package:shift_project/screens/home/home_widgets/components/routes_buttons_display.dart';
import 'package:shift_project/screens/home/home_widgets/appbar_widget.dart';
import 'package:shift_project/screens/home/home_provider/model/flood_marker_points.dart';
import 'package:shift_project/screens/home/home_provider/provider/operations_provider.dart';
import 'package:shift_project/screens/home/home_provider/service_utility/srvc.dart';
import 'package:shift_project/screens/home/home_widgets/drawer_widget.dart';

import '../../../states/auth/backend/authenticator.dart';

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
        preferredSize: const Size(double.infinity, 250),
        child: MyAppBar(opsNotifier: opProvider),
      ),
      extendBodyBehindAppBar: true,
      drawer: const SafeArea(
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
              // const FloodProneButton(),
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
                final weatherData = ref.watch(opsProvider).weatherData;
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
                    ? goNotifier
                        ? StopButton(
                            onTap: () async {
                              await Srvc.removeAllMarkers(
                                  routes!, mapController);
                              mapController.clearAllRoads();
                              operationsProvider.clearAllData();
                              String? driverId = _authenticator.userId;
                              await Srvc.sendSavedRoute(myRoute, driverId);
                              // await Srvc.fetchFloodPoints(driverId);
                              mapController.removeMarker(routes[0].route.last);
                            },
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClearButton(
                                onPressed: () async {
                                  await Srvc.removeAllMarkers(
                                      routes!, mapController);
                                  mapController
                                      .removeMarker(routes[0].route.last);
                                  mapController.clearAllRoads();

                                  operationsProvider.clearAllData();
                                },
                              ),
                              Row(
                                children: [
                                  Expanded(
                                      child: RouteButtonsContainer(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: RouteButtons(
                                            routes: routes!,
                                            mapController: mapController,
                                            opsNotifier: operationsProvider,
                                            weatherData: weatherData!,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        GoButton(
                                          onTap: () async {
                                            String? driverId =
                                                _authenticator.userId;
                                            if (startAndDestination != null &&
                                                startAndDestination.length ==
                                                    2) {
                                              operationsProvider
                                                  .stopButtonNotifier();
                                              operationsProvider.clearMyRoute();
                                              operationsProvider
                                                  .addNewPointToMyRoute(
                                                      await mapController
                                                          .myLocation());
                                              Srvc.updateLocation(
                                                  routeCHOSEN!,
                                                  mapController,
                                                  _animationController,
                                                  operationsProvider,
                                                  context, '0');
                                            }

                                            Srvc.sendSavedRoute(
                                                myRoute, driverId);
                                          },
                                        )
                                      ],
                                    ),
                                  ))
                                ],
                              )
                            ],
                          )
                    :ChooseDestinationButton(
                        onPressed: () async {
                          String? driverId = _authenticator.userId;
                          
              

                            var p = await Navigator.pushNamed(context, "/search");
                             operationsProvider.addPointToRoad(await mapController.myLocation());
                             operationsProvider.addPointToRoad(p as GeoPoint);

                          showDialog(
                              context: context,
                              barrierDismissible: false, // Prevent dismissing dialog on tap outside
                              builder: (BuildContext context) {
                                return const Center(
                                  child: LoadingScreen(),
                                );
                              },
                            );

                          try {
                            await operationsProvider.fetchAndDrawRoute(
                              driverId,
                              mapController,
                              weatherCose!,
                              await mapController.myLocation(),
                              p,
                            );
                          } finally {
                            // Hide loading screen
                            Navigator.of(context).pop();
                          }
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
