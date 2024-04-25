import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shift_project/screens/login/login_widgets/login_container.dart';
import 'package:shift_project/screens/login/login_widgets/login_logo.dart';
import '../../../constants/constants.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: scaffoldBackground,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const LoginLogo(),
                    LoginContainer(ref: ref),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
