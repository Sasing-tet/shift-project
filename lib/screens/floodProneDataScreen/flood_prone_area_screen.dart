// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

class FloodProneScreen extends StatefulWidget {
  const FloodProneScreen({super.key});

  @override
  State<FloodProneScreen> createState() => _FloodProneScreenState();
}

class _FloodProneScreenState extends State<FloodProneScreen> {
  LatLng? currentPosition;
  late MapController mapController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mapController = MapController();
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

  @override
  Widget build(BuildContext context) {
    // const topLeftCorner = LatLng(53.377, -2.999);
    // const bottomRightCorner = LatLng(53.475, 0.275);
    // const bottomLeftCorner = LatLng(52.503, -1.868);

    final overlayImages = <BaseOverlayImage>[
      OverlayImage(
        bounds: LatLngBounds(
          LatLng(9.412142820353925, 123.29640445531231),
          LatLng(11.522445302886247, 124.57101328478292),
        ),
        opacity: 1,
        imageProvider: AssetImage('assets/images/low susceptibility res.png'),
      ),
    ];

    return Scaffold(
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: currentPosition ?? LatLng(10.3157, 123.8854),
          zoom: 17,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
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
    );
  }
}
