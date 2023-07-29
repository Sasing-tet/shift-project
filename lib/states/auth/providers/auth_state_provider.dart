import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shift_project/states/auth/models/auth_state.dart';
import 'package:shift_project/states/auth/notifiers/auth_state_notifier.dart';

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>(
  (_) => AuthStateNotifier(),
);
