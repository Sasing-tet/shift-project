import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shift_project/constants/constants.dart';
import 'package:shift_project/main.dart';
import 'package:shift_project/states/auth/backend/authenticator.dart';
import 'package:shift_project/states/auth/models/auth_results.dart';
import 'package:shift_project/states/auth/providers/auth_state_provider.dart';

class LoginWithGoogle extends StatelessWidget {
  final WidgetRef ref;
  const LoginWithGoogle({super.key, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final result = await const Authenticator().signInWithGoogle();
              debugPrint(supabase.auth.currentUser.toString());

              if (result == AuthResult.success) {
                ref.read(authStateProvider.notifier).signInWithGoogle();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: shiftGrayBorder,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(8),
              child: SizedBox(
                height: 40,
                child: googleLogo,
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
      ],
    );
  }
}
