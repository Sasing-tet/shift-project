import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../notifiers/curr_position_notifier.dart';

final currentPositionProvider = StateNotifierProvider<CurrentPositionNotifier, CurrentPosition>((_) {
  return CurrentPositionNotifier();
});