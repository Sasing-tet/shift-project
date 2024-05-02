import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../main.dart';
import '../../user/typedef/user_id.dart';

import '../models/auth_results.dart';

class Authenticator {
  const Authenticator();

  User? get currentUser => supabase.auth.currentUser;

  UserId? get userId => currentUser?.id;
  bool get isAlreadyLoggedIn => userId != null;
  String get displayName => currentUser?.userMetadata?['full_name'] ?? '';
  String? get email => currentUser?.email;

  Future<void> logOut() async {
    await supabase.auth.signOut();
    await GoogleSignIn().signOut();
    
  }

  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
      return AuthResult.success;
    } catch (e) {
      return AuthResult.failure;
    }
  }

  Future<AuthResult> signInAndSignUp() async {
    try {
     
      return AuthResult.success;
    } catch (e) {
      return AuthResult.failure;
    }
  }


  Future<AuthResult> signInWithGoogle() async {
    ///
    /// Web Client ID that you registered with Google Cloud.
    const webClientId = '881978526053-vrd7m6c3mnohkn563a3imab6f377pmge.apps.googleusercontent.com';

    ///
    /// iOS Client ID that you registered with Google Cloud.
    const iosClientId = '881978526053-69huu0msrpjb7b6ot2prsblev6qsg4rb.apps.googleusercontent.com';

    // Google sign in on Android will work without providing the Android
    // Client ID registered on Google Cloud.

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId,
    );
    debugPrint("Googlesignin ${googleSignIn.toString()}");
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
       return AuthResult.aborted;
     }
     debugPrint("Googleuser ${googleUser.toString()}");
    final googleAuth = await googleUser.authentication;
    debugPrint("googAurh ${googleAuth.toString()}");
    final accessToken = googleAuth.accessToken;
    debugPrint("access ${accessToken.toString()}");
    final idToken = googleAuth.idToken;
    debugPrint("idToken ${idToken.toString()}");

    if (accessToken == null) {
      throw 'No Access Token found.';
    }
    if (idToken == null) {
      throw 'No ID Token found.';
    }

    
    try {
      await supabase.auth.signInWithIdToken(
        provider: Provider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      
      return AuthResult.success;
    } catch (e) {
      debugPrint("Supabaseauth ${e.toString()}");
      return AuthResult.failure;
    }
  }



  // Future<AuthResult> signInWithGoogle() async {
  //   final GoogleSignIn googleSignIn = GoogleSignIn(
  //           // serverClientId: '133593667373-78drmtr2j427p8qd6p0t382vfhd5th1b.apps.googleusercontent.com',
  //     scopes: [
  //       Constants.emailScope,
  //     ],
  //   );
  //   final signInAccount = await googleSignIn.signIn();
  //   if (signInAccount == null) {
  //     return AuthResult.aborted;
  //   }

  //   final googleAuth = await signInAccount.authentication;
  //   final oauthCredentials = GoogleAuthProvider.credential(
  //     accessToken: googleAuth.accessToken,
  //     idToken: googleAuth.idToken,
  //   );

  //   try {
  //     await FirebaseAuth.instance.signInWithCredential(
  //       oauthCredentials,
  //     );
  //     return AuthResult.success;
  //   } catch (e) {
  //     return AuthResult.failure;
  //   }
  // }

  Future<AuthResult> signInWithGitHub() async {
    // GithubAuthProvider githubProvider = GithubAuthProvider();

    // // githubProvider.addScope(Constants.emailScope);
    // githubProvider.addScope('user:email');

    try {
    await supabase.auth.signInWithOAuth(Provider.github);

      return AuthResult.success;
    } catch (e) {
      return AuthResult.failure;
    }
  }
}
