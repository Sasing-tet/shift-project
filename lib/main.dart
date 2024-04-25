import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shift_project/constants/constants.dart';
import 'package:shift_project/screens/choose_location/presentation/choose_location_view.dart';
import 'package:shift_project/screens/home/presentation/homepage.dart';
import 'package:shift_project/screens/login/presentation/login_screen.dart';
import 'package:shift_project/states/auth/providers/login_provider.dart';
import 'package:shift_project/states/loading/provider/isloading_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://qegghlcugbbvyuopfegq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFlZ2dobGN1Z2Jidnl1b3BmZWdxIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTQ5NTU3NjMsImV4cCI6MjAxMDUzMTc2M30.HJf-DFvWbqRWqTIUjdJkeuQalXEAvqPfi-GN7lYQ-PY',
    // authFlowType: AuthFlowType.pkce,
  );
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SHIFT',
      theme: ThemeData(
        dividerColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0XFF001c52)),
        useMaterial3: true,
        elevatedButtonTheme: constElevatedButtonTheme.elevatedButtonTheme,
      ),
      debugShowCheckedModeBanner: false,
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
        "/search": (ctx) => const SearchPage(),
        "/login": (ctx) => const LoginScreen(),
        "/home": (ctx) => const HomePage(),
      },
    );
  }
}
