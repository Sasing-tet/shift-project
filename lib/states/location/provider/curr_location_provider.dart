import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../notifiers/curr_position_notifier.dart';

final currentPositionProvider = StateNotifierProvider<CurrentPositionNotifier, CurrentPosition>((_) {
  return CurrentPositionNotifier();
});