// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
    super.initState();
    mapController = MapController();
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
        imageProvider: const AssetImage('assets/images/low susceptibility res.png'),
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
