import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shift_project/screens/data_sources/presentation/data_source_screen.dart';
import 'package:shift_project/screens/login/presentation/login_screen.dart';
import 'package:shift_project/states/auth/providers/auth_state_provider.dart';
import '../../../constants/constants.dart';
import '../../../main.dart';

class WeatherDrawer extends ConsumerWidget {
  const WeatherDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user =
        supabase.auth.currentUser?.userMetadata?['full_name'] ?? 'Guest User';
    final avatar = supabase.auth.currentUser?.userMetadata?['avatar_url'] ??
        'https://www.gravatar.com/avatar/00000000000000000000000000000000?s=200&d=mp';
    Future<void> handleLogoutAndNavigateToLogin() async {
      final authNotifier = ref.read(authStateProvider.notifier);
      await authNotifier.logOut();
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: 250,
            child: DrawerHeader(
              decoration: drawerBackground,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const FaIcon(
                      FontAwesomeIcons.arrowLeft,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CircleAvatar(
                      radius: 40, backgroundImage: NetworkImage(avatar)),
                  Text(
                    user,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: titleFontSize,
                    ),
                  ),
                  const Text(
                    'SHIFT User',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleSubtitleFontSize,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ListTile(
          //   title: const Text('Feedback'),
          //   onTap: () {},
          //   shape: const Border(
          //     bottom: BorderSide(color: shiftGrayBorder, width: 1),
          //   ),
          // ),
          // ListTile(
          //   title: const Text('About Us'),
          //   onTap: () {},
          //   shape: const Border(
          //     bottom: BorderSide(color: shiftGrayBorder, width: 1),
          //   ),
          // ),
          // ListTile(
          //   title: const Text('Settings'),
          //   onTap: () {},
          //   shape: const Border(
          //     bottom: BorderSide(color: shiftGrayBorder, width: 1),
          //   ),
          // ),
          ListTile(
            title: const Text('Data Sources'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DataSourceScreen(),
                ),
              );
            },
            shape: const Border(
              bottom: BorderSide(color: shiftGrayBorder, width: 1),
            ),
          ),
          ListTile(
            title: const Text('Logout'),
            onTap: () {
              handleLogoutAndNavigateToLogin().then((_) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );
              });
            },
            shape: const Border(
              bottom: BorderSide(color: shiftGrayBorder, width: 1),
            ),
          ),
        ],
      ),
    );
  }
}
