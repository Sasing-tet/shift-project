import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../user/typedef/user_id.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../constants/auth_constants.dart';
import '../models/auth_results.dart';

class Authenticator {
  const Authenticator();

  User? get currentUser => FirebaseAuth.instance.currentUser;

  UserId? get userId => currentUser?.uid;
  bool get isAlreadyLoggedIn => userId != null;
  String get displayName => currentUser?.displayName ?? '';
  String? get email => currentUser?.email;

  Future<void> logOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
  }

  Future<AuthResult> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
            // serverClientId: '133593667373-78drmtr2j427p8qd6p0t382vfhd5th1b.apps.googleusercontent.com',
      scopes: [
        Constants.emailScope,
      ],
    );
    final signInAccount = await googleSignIn.signIn();
    if (signInAccount == null) {
      return AuthResult.aborted;
    }

    final googleAuth = await signInAccount.authentication;
    final oauthCredentials = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    try {
      await FirebaseAuth.instance.signInWithCredential(
        oauthCredentials,
      );
      return AuthResult.success;
    } catch (e) {
      return AuthResult.failure;
    }
  }

  Future<AuthResult> signInWithGitHub() async {
    GithubAuthProvider githubProvider = GithubAuthProvider();

    // githubProvider.addScope(Constants.emailScope);
    githubProvider.addScope('user:email');

    try {
      await FirebaseAuth.instance.signInWithProvider(
        githubProvider,
      );

      return AuthResult.success;
    } catch (e) {
      return AuthResult.failure;
    }
  }
}
