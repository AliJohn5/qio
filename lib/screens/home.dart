import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/instance_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qio/api/users.dart';

import 'package:qio/screens/add_offer.dart';
import 'package:qio/screens/explore_screen.dart';
import 'package:qio/screens/favorites_screen.dart';
import 'package:qio/screens/messages_screen.dart';
import 'package:qio/screens/profile_screen.dart';
import 'package:get/get.dart';
import 'package:qio/controllers/persons_controller.dart';

bool isPosition = false;

Future<void> requestPermission() async {
  await Permission.notification.request();
}

Future<void> requestLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.whileInUse ||
      permission == LocationPermission.always) {
    try {
      Position position = await Geolocator.getCurrentPosition();

      await DioClient.instance.post(
        "api/users/location/",
        data: {'latitude': position.latitude, 'longitude': position.longitude},
      );
    } catch (e) {
      return;
    }
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  void _getpermission() async {
    await requestPermission();
    await requestLocationPermission();
  }

  //late WebSocketController wsController;
  final PersonsController _personsController = Get.find<PersonsController>();
  bool isReadedAll = true;

  void _fetch() async {
    final res = await _personsController.fetch();
    if (res == true) {
      if (!mounted) return;

      setState(() {
        isReadedAll = _personsController.isReadedAll;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    //wsController = Get.put(WebSocketController());
    _fetch();

    if (!isPosition) {
      _getpermission();
      isPosition = true;
    }
  }

  @override
  void dispose() {
    // wsController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (!mounted) return;

    setState(() {
      _selectedIndex = index;
    });
  }

  void setIsReaded(bool value) {
    if (!mounted) return;

    setState(() {
      isReadedAll = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    isReadedAll = _personsController.isReadedAll;
    final widgetOptions = <Widget>[
      ExploreScreen(),
      FavoritesScreen(),
      AddOffer(),
      MessagesScreen(setIsReadedAll: setIsReaded),
      ProfileScreen(),
    ];

    return Scaffold(
      body: SafeArea(top: true, child: widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'استكشف'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'المفضلة'),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: 'العروض',
          ),
          BottomNavigationBarItem(
            icon:
                isReadedAll
                    ? Icon(Icons.article) // read: greyed out
                    : Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Icon(Icons.article), // base icon
                        Positioned(
                          right: 0,
                          child: Icon(
                            Icons.circle,
                            color: Colors.red,
                            size: 10,
                          ), // unread dot
                        ),
                      ],
                    ),
            label: 'الرسائل',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'الحساب'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface,
        onTap: _onItemTapped,
      ),
    );
  }
}
