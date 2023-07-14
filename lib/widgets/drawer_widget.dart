import 'package:flutter/material.dart';
import 'package:shift_project/constants/constants.dart';

class WeatherDrawer extends StatelessWidget {
  const WeatherDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: drawerBackground,
            child: Text(
              'Weather',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('Weather Item 1'),
            onTap: () {
              // Handle weather item 1 tap
            },
          ),
          ListTile(
            title: const Text('Weather Item 2'),
            onTap: () {
              // Handle weather item 2 tap
            },
          ),
          // Add more weather items as needed
        ],
      ),
    );
  }
}
