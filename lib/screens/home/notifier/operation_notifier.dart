  import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
  import 'package:hooks_riverpod/hooks_riverpod.dart';
  import 'package:shift_project/screens/home/dataTemp/highflodd.dart';
  import 'package:shift_project/screens/home/dataTemp/lowflood.dart';
  import 'package:shift_project/screens/home/dataTemp/mediumflood.dart';
  import 'package:shift_project/screens/home/model/flood_marker_points.dart';
  import 'package:shift_project/screens/home/model/operation_state.dart';
  import 'package:shift_project/screens/home/model/routes_with_risk_points.dart';
  import 'package:shift_project/screens/home/tobedeleted/services.dart';
import 'package:shift_project/screens/home/srvc.dart';

  class OpsNotifier extends StateNotifier<OpsState> {
    OpsNotifier() : super(OpsState());

   void addChosenRoute(FloodMarkerRoute newRoute) {
  state = state.copyWith(routeCHOSEN: newRoute);
}

    void toggleExpansion() {
      state = state.copyWith(isExpanded: !state.isExpanded, isMapOverlayVisible: !state.isMapOverlayVisible);
    }

  void isPolylinesGenerated() {
      state = state.copyWith(polylinezzNotifier: !state.polylinezzNotifier);
    }

    
    void clearChosenRoute() {
      state = state.copyWith(routeCHOSEN: null);
    }


    void addRoute(FloodMarkerRoute newRoute) {
      state = state.copyWith(
        routes: [...state.routes ?? [], newRoute],
      );
    }

    void addPointToRoad(GeoPoint newPoint) {
      state = state.copyWith(
        pointsRoad: [...state.pointsRoad ?? [], newPoint],
      );
    }


Future<void> fetchAndDrawRoute(MapController mapController, List<FloodMarkerPoint> markerPoints) async {
  final coordinates = state.pointsRoad;

  try {
    final polylines = await Srvc.fetchOSRMRoutePolylines(coordinates!, mapController);

    final routes = await Srvc.getRoutesOnPolylines(
      polylines,
      markerPoints, 
      mapController,
    );

    state = state.copyWith(
      routes: [...state.routes ?? [], ...routes], // Adding the new routes to the existing routes list
      polylinezzNotifier: true,
    );

    await Srvc.drawRoadManually(routes, mapController);

  } catch (e) {
  print("Error fetching or drawing route: $e");
}
  }
    

    void clearData() {
    state = state.copyWith(
      pointsRoad: [],       // Clear points road
      routes: [],           // Clear routes
      polylinezzNotifier: false, // Set polylinezzNotifier to false
    );
  }

  void clearAllData() {
    state = state.copyWith(
      pointsRoad: [],       // Clear points road
      routes: [],
      routeCHOSEN: null,           // Clear routes
      polylinezzNotifier: false, // Set polylinezzNotifier to false
    );
  }


  }