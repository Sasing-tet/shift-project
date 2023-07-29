import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shift_project/states/auth/providers/auth_state_provider.dart';

import '../models/auth_results.dart';

final isLoggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.result == AuthResult.success;
});