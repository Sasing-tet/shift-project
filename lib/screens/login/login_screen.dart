// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shift_project/screens/home/homepage.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import 'package:shift_project/states/auth/models/auth_results.dart';

import '../../constants/constants.dart';
import '../../main.dart';
import '../../states/auth/backend/authenticator.dart';
import '../../states/auth/providers/auth_state_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final userController = TextEditingController();
    // final passController = TextEditingController();


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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 125,
                            child: logo,
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan( 
                                  text: 'SH',
                                  style: TextStyle(
                                    fontFamily: interFontFamily,
                                    fontSize: loginScreenTitleSize,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 10,
                                  ),
                                ),
                                TextSpan(
                                  text: 'I',
                                  style: TextStyle(
                                    fontFamily: interFontFamily,
                                    fontSize: loginScreenTitleSize,
                                    color: shiftRed,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 10,
                                  ),
                                ),
                                TextSpan(
                                  text: 'FT',
                                  style: TextStyle(
                                    fontFamily: interFontFamily,
                                    fontSize: loginScreenTitleSize,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
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
                            SupaEmailAuth(
                            redirectTo: kIsWeb ? null : 'io.mydomain.myapp://callback',
                            onSignInComplete: (response) async {
                                final result = await Authenticator()
                                          .signInAndSignUp();
                                      debugPrint(supabase.auth.currentUser.toString());

                                      if (result == AuthResult.success) {

                                    
                                        await ref
                                            .read(authStateProvider.notifier)
                                            .signInAndSignUps(result);

                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                              builder: (context) => HomePage(),
                                            ),
                                          );
                                            

                                      }
                                    
                            },
                            onSignUpComplete: (response) async{
                                final result = await Authenticator()
                                          .signInAndSignUp();
                                      debugPrint(supabase.auth.currentUser.toString());

                                      if (result == AuthResult.success) {
                                          // ignore: use_build_context_synchronously
                                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Sign Up Complete'),
                                  content: Text('Please confirm email and proceed with login.'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('OK'),
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
                          ),
                            // TextField(
                            //   decoration: InputDecoration(
                            //     hintText: 'Username...',
                            //   ),
                            //   controller: userController,
                            // ),
                            // TextField(
                            //   decoration: InputDecoration(
                            //     hintText: 'Password...',
                            //   ),
                            //   obscureText: true,
                            //   controller: passController,
                            // ),
                            // Container(
                            //   margin: EdgeInsets.only(
                            //     top: 20,
                            //     bottom: 10,
                            //   ),
                            //   decoration: BoxDecoration(
                            //     color: shiftBlack,
                            //     borderRadius: BorderRadius.circular(8),
                            //   ),
                            //   child: TextButton(
                            //     style: chooseDestination,
                            //     onPressed: () {
                            //       Navigator.of(context).push(
                            //         MaterialPageRoute(
                            //           builder: (context) => HomePage(),
                            //         ),
                            //       );
                            //     },
                            //     child: Text(
                            //       'Login',
                            //       style: TextStyle(
                            //         fontFamily: interFontFamily,
                            //         fontSize: titleSubtitleFontSize,
                            //         color: Colors.white,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: ConstrainedBox(
                                constraints: BoxConstraints.tightFor(
                                    width: double.infinity),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey,
                                        height: 1,
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
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
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Expanded(
                                //   child: Container(
                                //     decoration: BoxDecoration(
                                //       border: Border.all(
                                //         width: 1,
                                //         color: shiftGrayBorder,
                                //       ),
                                //       borderRadius: BorderRadius.circular(8),
                                //     ),
                                //     padding: EdgeInsets.all(8),
                                //     child: SizedBox(
                                //       height: 40,
                                //       child: facebookLogo,
                                //     ),
                                //   ),
                                // ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      final result = await Authenticator()
                                          .signInWithGoogle();
                                      debugPrint(supabase.auth.currentUser.toString());

                                      if (result == AuthResult.success) {
                                        ref
                                            .read(authStateProvider.notifier)
                                            .signInWithGoogle();
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 1,
                                          color: shiftGrayBorder,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: EdgeInsets.all(8),
                                      child: SizedBox(
                                        height: 40,
                                        child: googleLogo,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                // Expanded(
                                //   child: GestureDetector(
                                //     onTap: () async {
                                //       final result = await Authenticator()
                                //           .signInWithGitHub();
                                //       if (result == AuthResult.success) {
                                //         ref
                                //             .read(authStateProvider.notifier)
                                //             .signInWithGithub;
                                //           // Navigator.of(context).push(
                                //           //     MaterialPageRoute(
                                //           //     builder: (context) => HomePage(),
                                //           //   ),
                                //           // );
                                //       }
                                //     },
                                //     child: Container(
                                //       decoration: BoxDecoration(
                                //         border: Border.all(
                                //           width: 1,
                                //           color: shiftGrayBorder,
                                //         ),
                                //         borderRadius: BorderRadius.circular(8),
                                //       ),
                                //       padding: EdgeInsets.all(8),
                                //       child: SizedBox(
                                //         height: 40,
                                //         child: githubLogo,
                                //       ),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Container(
                    //   margin: EdgeInsets.symmetric(vertical: 20),
                    //   decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.circular(8),
                    //   ),
                    //   child: TextButton(
                    //     style: chooseDestination,
                    //     onPressed: () {
                    //       Navigator.of(context).push(
                    //         MaterialPageRoute(
                    //           builder: (context) => RegisterScreen(),
                    //         ),
                    //       );
                    //     },
                    //     child: Text(
                    //       'Login as Guest',
                    //       style: TextStyle(
                    //         fontFamily: interFontFamily,
                    //         fontSize: titleSubtitleFontSize,
                    //         color: Colors.black87,
                    //       ),
                    //     ),
                    //   ),
                    // ),
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
