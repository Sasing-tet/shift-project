// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shift_project/constants/constants.dart';
import 'package:shift_project/main.dart';
import 'package:shift_project/screens/home/presentation/homepage.dart';
import 'package:shift_project/screens/login/login_widgets/login_with_google.dart';
import 'package:shift_project/states/auth/backend/authenticator.dart';
import 'package:shift_project/states/auth/models/auth_results.dart';
import 'package:shift_project/states/auth/providers/auth_state_provider.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class LoginContainer extends StatelessWidget {
  final WidgetRef ref;
  const LoginContainer({super.key, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Builder(builder: (context) {
              return SupaEmailAuth(
                redirectTo: kIsWeb ? null : 'io.mydomain.myapp://callback',
                onSignInComplete: (response) async {
                  final result = await const Authenticator().signInAndSignUp();
                  debugPrint(supabase.auth.currentUser.toString());

                  if (result == AuthResult.success) {
                    await ref
                        .read(authStateProvider.notifier)
                        .signInAndSignUps(result);

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                    );
                  }
                },
                onSignUpComplete: (response) async {
                  final result = await const Authenticator().signInAndSignUp();
                  debugPrint(supabase.auth.currentUser.toString());

                  if (result == AuthResult.success) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Sign Up Complete'),
                          content: const Text(
                              'Please confirm email and proceed with login.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                metadataFields: [
                  MetaDataField(
                    prefixIcon: const Icon(Icons.person),
                    label: 'Username',
                    key: 'full_name',
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please enter something';
                      }
                      return null;
                    },
                  ),
                ],
              );
            }),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints.tightFor(width: double.infinity),
                child: const Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey,
                        height: 1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Or Login With",
                        style: TextStyle(
                          fontSize: defaultSubtitleFontSize,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            LoginWithGoogle(ref: ref),
          ],
        ),
      ),
    );
  }
}
