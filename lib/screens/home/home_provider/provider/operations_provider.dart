import 'package:hooks_riverpod/hooks_riverpod.dart' show StateNotifierProvider;
import 'package:shift_project/screens/home/home_provider/model/operation_state.dart';
import 'package:shift_project/screens/home/home_provider/notifier/operation_notifier.dart';

final opsProvider = StateNotifierProvider<OpsNotifier, OpsState>((ref) {
  return OpsNotifier();
});
