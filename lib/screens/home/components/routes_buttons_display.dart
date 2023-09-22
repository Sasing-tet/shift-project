import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:shift_project/screens/home/components/buttons/route_button_widget.dart';
import 'package:shift_project/screens/home/model/routes_with_risk_points.dart';
import 'package:shift_project/screens/home/notifier/operation_notifier.dart';
import 'package:shift_project/screens/home/srvc.dart';

class RouteButtons extends StatelessWidget {
  const RouteButtons({
    super.key,
   
    required this.mapController, required this.routes, required this.opsNotifier,
  });
  final List<FloodMarkerRoute>? routes;
 
  final MapController mapController;
   final OpsNotifier opsNotifier;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: routes?.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: (){
            Srvc.removeAllMarkers(routes!, mapController);
            Srvc.addMarkersToMap(routes![index].markerPoints, mapController);
            mapController.clearAllRoads();
            mapController.drawRoadManually(
              routes![index].route,
               RoadOption(
                roadColor: Colors.blue,
                roadWidth: 15,
              ),);
               mapController.zoomOut();
                 opsNotifier.addChosenRoute(routes![index]);


                     },
          child: RouteOptionWidget(i: index),
        );
      },
    );
  }
}
