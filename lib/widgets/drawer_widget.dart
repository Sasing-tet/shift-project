import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shift_project/constants/constants.dart';

class WeatherDrawer extends StatelessWidget {
  const WeatherDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage(
                      'assets/images/hu tao smol.jpg',
                    ),
                  ),
                  const Text(
                    'Guest#123',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleFontSize,
                    ),
                  ),
                  const Text(
                    'Guest User',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleSubtitleFontSize,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            title: const Text('Feedback'),
            onTap: () {},
            shape: const Border(
              bottom: BorderSide(color: shiftGrayBorder, width: 1),
            ),
          ),
          ListTile(
            title: const Text('About Us'),
            onTap: () {},
            shape: const Border(
              bottom: BorderSide(color: shiftGrayBorder, width: 1),
            ),
          ),
          ListTile(
            title: const Text('Settings'),
            onTap: () {},
            shape: const Border(
              bottom: BorderSide(color: shiftGrayBorder, width: 1),
            ),
          ),
          ListTile(
            title: const Text('Data Sources'),
            onTap: () {},
            shape: const Border(
              bottom: BorderSide(color: shiftGrayBorder, width: 1),
            ),
          ),
          ListTile(
            title: const Text('Logout'),
            onTap: () {},
            shape: const Border(
              bottom: BorderSide(color: shiftGrayBorder, width: 1),
            ),
          ),
        ],
      ),
    );
  }
}
