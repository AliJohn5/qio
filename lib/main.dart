import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';
import 'package:qio/api/users.dart';
import 'package:qio/controllers/message_controller.dart';
import 'package:qio/controllers/notification_controller.dart';
import 'package:qio/controllers/persons_controller.dart';
import 'package:qio/models/message.dart';
import 'package:qio/models/notification.dart' as mynoti;
import 'package:qio/screens/home.dart';
import 'package:qio/screens/login.dart';
import 'dart:io' show Platform;
import 'dart:async';
import 'package:pushy_flutter/pushy_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
late Size size;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  await DioClient.initialize();
  //await NotiService.initNotification();

  Get.put(MessagesController(), permanent: true);
  Get.put(PersonsController(), permanent: true);
  Get.put(NotificationsController(), permanent: true);

  final bool isLoggedInbool = await isLoggedIn();
  runApp(MyApp(isLoggedIn: isLoggedInbool));
}

bool isAndroid() {
  try {
    // Return whether the device is running on Android
    return Platform.isAndroid;
  } catch (e) {
    // If it fails, we're on Web
    return false;
  }
}

@pragma('vm:entry-point')
void backgroundNotificationListener(Map<String, dynamic> data) {
  // Print notification payload data
  String notificationTitle = 'MyApp';

  switch (data['message_type']) {
    case 'notification':
      notificationTitle = data['title'];
      try {
        Get.find<NotificationsController>().addNotification(
          mynoti.Notification.fromJson(data),
        );
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }

      break;
    case 'message':
      try {
        notificationTitle = 'Message from ${data['from']}';
        Get.find<MessagesController>().receiveMessage(
          Message.fromJsonReceive(data),
        );
        Get.find<PersonsController>().receiveMessage(
          Message.fromJsonReceive(data),
        );
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
      break;
  }

  // Attempt to extract the "message" property from the payload: {"message":"Hello World!"}
  String notificationText = data['content'] ?? 'Hello World!';

  // Android: Displays a system notification
  // iOS: Displays an alert dialog
  Pushy.notify(notificationTitle, notificationText, data);

  Pushy.clearBadge();
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    Pushy.listen();
    Pushy.setAppId('68111b3f394e9a7b1f5a4029');

    if (Platform.isAndroid) {
      await Permission.notification.request();
    }

    while (true) {
      try {
        String deviceToken = await Pushy.register();

        await DioClient.instance.post(
          "api/c/c/n/n/n/n/",
          data: {"token": deviceToken},
        );

        if (kDebugMode) {
          print('Pushy registered successfully: $deviceToken');
        }

        break; // Exit loop on success
      } catch (error) {
        if (kDebugMode) {
          print(
            'Pushy registration failed, retrying in 2 seconds... Error: $error',
          );
        }
        await Future.delayed(Duration(seconds: 2));
      }

      Pushy.toggleInAppBanner(true);

      Pushy.setNotificationListener(backgroundNotificationListener);

      Pushy.setNotificationClickListener((Map<String, dynamic> data) {
        Pushy.clearBadge();
      });
    }

    Pushy.toggleInAppBanner(true);

    Pushy.setNotificationListener(backgroundNotificationListener);

    // Listen for push notification clicked
    Pushy.setNotificationClickListener((Map<String, dynamic> data) {
      Pushy.clearBadge();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return GetMaterialApp(
      //getPages: [
      //  GetPage(name: '/message', page: () => OfferDeepScreen()),
      //  GetPage(name: '/offer', page: () => OfferScreen()),
      //  GetPage(name: '/profile', page: () => ProfileScreen()),
      //],
      navigatorKey: navigatorKey,
      title: 'Qio',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFFB5E841),
          primary: Color(0xFFB5E841),
          brightness: Brightness.dark,
        ),
      ),
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
      home: widget.isLoggedIn ? Home() : Login(),
    );
  }
}
