import 'package:shift_project/states/auth/models/auth_results.dart';
import 'package:shift_project/states/user/backend/user_info_storage.dart';

import '../../user/typedef/user_id.dart';
import '../backend/authenticator.dart';
import '../models/auth_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AuthStateNotifier extends StateNotifier<AuthState> {
  final _authenticator = const Authenticator();
  final _userInfoStorage = const UserInfoStorage();

  AuthStateNotifier() : super(const AuthState.unknown()) {
    if (_authenticator.isAlreadyLoggedIn) {
      state = AuthState(
        result: AuthResult.success,
        isLoading: false,
        userId: _authenticator.userId,
      );
    }
  }

  Future<void> logOut() async {
    state = state.copiedWithIsLoading(true);
    await _authenticator.logOut();
    state = const AuthState.unknown();
  }

  Future<void> signInWithGoogle() async {
    state = state.copiedWithIsLoading(true);
    final result = await _authenticator.signInWithGoogle();
    final userId = _authenticator.userId;
    if (result == AuthResult.success && userId != null) {
      await saveUserInfo(
        userId: userId,
      );
    }
    state = AuthState(
      result: result,
      isLoading: false,
      userId: _authenticator.userId,
    );
  }

  Future<void> signInAndSignUps(AuthResult result) async {
     state = state.copiedWithIsLoading(true);
    
    final userId = _authenticator.userId;
    if (result == AuthResult.success && userId != null) {
      await saveUserInfo(
        userId: userId,
      );
    }
    state = AuthState(
      result: result,
      isLoading: false,
      userId: _authenticator.userId,
    );
  }

  Future<void> signInWithGithub() async {
    state = state.copiedWithIsLoading(true);
    final result = await _authenticator.signInWithGitHub();
    final userId = _authenticator.userId;
    if (result == AuthResult.success && userId != null) {
      await saveUserInfo(userId: userId);
    }
    state = AuthState(
      result: result,
      isLoading: false,
      userId: _authenticator.userId,
    );
  }

  Future<void> saveUserInfo({
    required UserId userId,
  }) =>
      _userInfoStorage.saveUserInfo(
        userId: userId,
        displayName: _authenticator.displayName,
        email: _authenticator.email,
      );
}
