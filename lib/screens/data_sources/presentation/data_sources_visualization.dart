import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:shift_project/screens/data_sources/data_source_widgets/return_flood_prone_button.dart';
import 'package:shift_project/screens/home/home_widgets/components/buttons/user_location_button.dart';
import 'package:shift_project/screens/home/home_widgets/appbar_widget.dart';
import 'package:shift_project/screens/home/home_provider/model/flood_marker_points.dart';
import 'package:shift_project/screens/home/home_provider/provider/operations_provider.dart';
import 'package:shift_project/screens/home/home_provider/service_utility/srvc.dart';
import 'package:shift_project/screens/home/home_widgets/drawer_widget.dart';

class DataSourceVisualization extends ConsumerStatefulWidget {
  const DataSourceVisualization({Key? key}) : super(key: key);

  @override
  ConsumerState<DataSourceVisualization> createState() =>
      _DataSourceVisualization();
}

class _DataSourceVisualization extends ConsumerState<DataSourceVisualization>
    with SingleTickerProviderStateMixin {
  late GlobalKey<ScaffoldState> scaffoldKey;
  LatLng? currentPosition;
  late MapController mapController;
  bool isExpanded = false;
  bool isMapOverlayVisible = true;
  late AnimationController _animationController;
  late final List<FloodMarkerPoint> markerPoints;

  @override
  void initState() {
    super.initState();
    _userLoc();
    mapController = MapController();
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

  void _refreshAppBar() {
    // Call setState to trigger a rebuild of the MyAppBar widget
    setState(() {});
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

    final overlayImages = <BaseOverlayImage>[
      OverlayImage(
          bounds: LatLngBounds(
            LatLng(9.412142820353925, 123.29640445531231),
            LatLng(11.3, 124.05),
          ),
          opacity: 1,
          imageProvider:
              const AssetImage('assets/images/1_Low_Flood_Routes.png')
          // Svg(
          //   'assets/images/1_Low_Flood_Routes.svg',
          //   size: Size(600, 600), // Adjust width as needed
          // ),
          ),
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 250),
        child: MyAppBar(
          opsNotifier: opProvider,
          //onRefreshPressed: _refreshAppBar,
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
              : FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    center: currentPosition ?? LatLng(10.3157, 123.8854),
                    zoom: 17,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    OverlayImageLayer(overlayImages: overlayImages),
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: currentPosition ?? LatLng(0, 0),
                          color: Colors.blue,
                          radius: 8,
                        ),
                      ],
                    ),
                  ],
                ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ReturnFloodProneButton(),
                UserLocationButton(
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
