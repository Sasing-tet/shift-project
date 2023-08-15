import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shift_project/screens/chooselocation/choose_location_view.dart';
import 'package:shift_project/screens/floodProneDataScreen/flood_prone_area_screen.dart';
import 'package:shift_project/screens/home/homepage.dart';
import 'package:shift_project/screens/home/tobedeleted/home_screen.dart';
import 'package:shift_project/screens/login/login_screen.dart';
import 'package:shift_project/screens/logo/logo_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shift_project/states/auth/providers/login_provider.dart';
import 'package:shift_project/states/loading/provider/isloading_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        dividerColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      // home: const LogoScreen(),
      home: Consumer(
        builder: (context, ref, child) {
          ref.listen<bool?>(
            isLoadingProvider,
            (_, isLoading) {
              if (isLoading == true) {
                EasyLoading.show(status: 'loading...');
              } else {
                EasyLoading.dismiss();
              }
            },
          );

          final isLoggedIn = ref.watch(isLoggedInProvider);

          if (isLoggedIn) {
            return const HomePage();
          } else {
            return const LoginScreen();
          }
        },
      ),
      builder: EasyLoading.init(),
      routes: {
        "/search": (ctx) => SearchPage(),
      },
    );
  }
}
