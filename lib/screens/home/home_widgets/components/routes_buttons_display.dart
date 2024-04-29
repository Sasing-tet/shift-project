import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:shift_project/screens/home/home_widgets/components/buttons/route_button_widget.dart';
import 'package:shift_project/screens/home/home_provider/model/routes_with_risk_points.dart';
import 'package:shift_project/screens/home/home_provider/notifier/operation_notifier.dart';
import 'package:shift_project/screens/home/home_provider/service_utility/srvc.dart';

class RouteButtons extends StatelessWidget {
  const RouteButtons({
    super.key,
    required this.mapController,
    required this.routes,
    required this.opsNotifier, required this.weatherData,
  });
  final List<FloodMarkerRoute>? routes;

  final MapController mapController;
  final OpsNotifier opsNotifier;
  final int weatherData;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: routes?.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Srvc.removeAllMarkers(routes!, mapController);
            Srvc.addMarkersToMap(routes![index].markerPoints, mapController, weatherData);
            mapController.clearAllRoads();
            mapController.drawRoadManually(
              routes![index].route,
              const RoadOption(
                roadColor: Colors.blue,
                roadWidth: 15,
              ),
            );
            mapController.zoomOut();
            opsNotifier.addChosenRoute(routes![index]);
          },
          child: RouteOptionWidget(
              i: index,
              isAlternative: opsNotifier.isAlternativeRoute(index),
              score: opsNotifier.getTotalFloodscore(index).toString(), weatherBasedScore: opsNotifier.getTotalFloodscoreBasedOnWeather(index),),
        );
      },
    );
  }
}
