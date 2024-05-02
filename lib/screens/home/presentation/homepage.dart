// ignore_for_file: use_build_context_synchronously, overridden_fields, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:shift_project/screens/home/home_widgets/components/buttons/choose_destination.dart';
import 'package:shift_project/screens/home/home_widgets/components/buttons/clear_button.dart';
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
        child: MyAppBar(
          opsNotifier: opProvider,
        ),
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
                    directionArrowMarker: CustomMarkerIcon(
                      icon: const Icon(
                        Icons.navigation,
                        color: Colors.blueAccent,
                        size: 100,
                      ),
                      pulseAnimation: PulseAnimation(
                        color: Colors.blueAccent.withOpacity(0.6),
                        initialSize: 600.0,
                        finalSize: 800.0,
                        duration: const Duration(seconds: 2),
                      ),
                    ),

                    // directionArrowMarker:
                    // const MarkerIcon(
                    //   icon: Icon(
                    //     Icons.navigation,
                    //     color: Colors.blueAccent,
                    //     size: 100,
                    //   ),
                    // ),
                  ),
                ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 15,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                                            debugPrint(" tara : ${routeCHOSEN?.route.toString()}");
                                               if (routeCHOSEN?.route.isNotEmpty ?? false){
                                            // if (startAndDestination != null &&
                                            //     startAndDestination.length ==
                                            //         2) {
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
                                                  context,
                                                  '0');
                                            // }

                                            Srvc.sendSavedRoute(
                                                myRoute, driverId);
                                          } else {
                                               showDialog(
                                                context: context,
                                                barrierDismissible:
                                                    false, 
                                                builder: (BuildContext context) {
                                                  return const Center(
                                                    child: LoadingScreen(lotlot: 'assets/images/pick.json',text:  'Choose a route first!'),
                                                  );
                                                },
                                              );

                                       
                                        Future.delayed(const Duration(seconds: 3), () {
                                          Navigator.of(context).pop();
                                        });
                                          }
                                          
                                          }
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
                         
                              if(p != GeoPoint(latitude: 0.0, longitude: 0.0)){
                                operationsProvider
                              .addPointToRoad(await mapController.myLocation());
                               
                          operationsProvider.addPointToRoad(p as GeoPoint);

                          showDialog(
                            context: context,
                            barrierDismissible:
                                false, // Prevent dismissing dialog on tap outside
                            builder: (BuildContext context) {
                              return const Center(
                                child:  LoadingScreen(lotlot: 'assets/images/loading.json',text:  'Calculating the route',),
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
                        }},
                      );
              })
            ]),
          )
        ],
      ),
    );
  }
}

class CustomMarkerIcon extends MarkerIcon {
  @override
  final Icon icon;
  final Widget pulseAnimation;

  const CustomMarkerIcon({
    super.key,
    required this.icon,
    required this.pulseAnimation,
  }) : super(icon: icon);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        icon,
        Positioned.fill(
          child: pulseAnimation,
        ),
      ],
    );
  }
}

class PulseAnimation extends StatefulWidget {
  final Color color;
  final double initialSize;
  final double finalSize;
  final Duration duration;

  const PulseAnimation({
    Key? key,
    required this.color,
    required this.initialSize,
    required this.finalSize,
    required this.duration,
  }) : super(key: key);

  @override
  _PulseAnimationState createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(
      begin: widget.initialSize,
      end: widget.finalSize,
    ).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opacity = 0.5 *
            (1 -
                ((_animation.value - widget.initialSize) /
                    (widget.finalSize - widget.initialSize))) +
        0.5;

    return Opacity(
      opacity: opacity,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color,
        ),
        width: _animation.value,
        height: _animation.value,
      ),
    );
  }
}
