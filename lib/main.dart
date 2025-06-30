import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChrome, SystemUiOverlayStyle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:venta_cuba/Controllers/location_controller.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';

import 'package:venta_cuba/Controllers/theme_controller.dart';
import 'package:venta_cuba/Services/Notfication/notficationservice.dart';
import 'package:venta_cuba/languages/languages.dart';
import 'package:venta_cuba/view/splash%20Screens/white_screen.dart';
import 'package:venta_cuba/view/Chat/Controller/ChatController.dart';
import 'package:venta_cuba/view/constants/theme_config.dart';
import 'Notification/firebase_messaging.dart';

// Background message handler - MUST be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('🔥 Background message received: ${message.messageId}');
  print('🔥 Background message data: ${message.data}');
  print(
      '🔥 Background notification: ${message.notification?.title} - ${message.notification?.body}');

  // Show local notification for background messages
  await FCM.showBackgroundNotification(message);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  await Firebase.initializeApp();

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await Future.delayed(Duration(seconds: 1));
// usage of any Firebase services.
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.debug,
  );
  runApp(const MyApp());
}

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // App came to foreground, refresh device token and update badge
      _handleAppResume();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // App went to background or was closed, set user as offline
      try {
        final authCont = Get.find<AuthController>();
        authCont.setUserOffline();
        print('🔥 User set as offline');
      } catch (e) {
        print('Error setting user offline: $e');
      }
    }
  }

  Future<void> _handleAppResume() async {
    try {
      print('🔥 App resumed - handling badge count and user status');

      // Handle app opened - reset badge count first
      await FCM.handleAppOpened();

      final authCont = Get.find<AuthController>();
      authCont.refreshDeviceToken();

      // Also update device tokens in all chat documents
      if (authCont.user?.userId != null) {
        authCont.updateDeviceTokenInAllChats(deviceToken);
      }

      // Set user as online when app becomes active
      authCont.setUserOnline();

      // Update unread message indicators and restart chat listener
      try {
        final chatCont = Get.find<ChatController>();
        await chatCont.updateUnreadMessageIndicators();
        await chatCont.updateBadgeCountFromChats();
        chatCont.startListeningForChatUpdates();
        print('🔥 Chat services restarted on app resume');
      } catch (e) {
        print('🔥 ChatController not found on app resume: $e');
      }

      // Notification functionality removed
    } catch (e) {
      print('🔥 Error handling app resume: $e');
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FCM firebaseMessaging = FCM();
  final locationCont = Get.put(LocationController());
  late final ThemeController themeController;
  NotificationService notificationService = NotificationService();

  @override
  void initState() {
    super.initState();

    // Initialize theme controller first
    themeController = Get.put(ThemeController());

    notificationService.obtainCredentials();
    locationCheck();
    firebaseMessaging.setNotifications(context);
    firebaseMessaging.streamCtrl.stream.listen((msgData) {
      debugPrint('messageData $msgData');
    });
    _fetchLocale().then((locale) {
      setState(() {
        _locale = locale;
        debugPrint("_locale...................$_locale");
      });
      Get.updateLocale(locale);
    });

    // Listen for app lifecycle changes to refresh token
    WidgetsBinding.instance.addObserver(AppLifecycleObserver());

    // Check notification permissions after a delay
    Future.delayed(Duration(seconds: 3), () {
      checkNotificationPermissions();
    });
    Get.lazyPut(() => ChatController());
  }

  locationCheck() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool isLocationOn = sharedPreferences.getBool('isLocationOn') ?? false;
    if (isLocationOn) {
      //locationCont.getLocation();
    }
  }

  checkNotificationPermissions() async {
    try {
      await firebaseMessaging.requestNotificationPermissions();
      print('Notification permissions checked');
    } catch (e) {
      print('Error checking notification permissions: $e');
    }
  }

  String languageCode = 'es';
  String countryCode = 'ES';
  Locale _locale = Locale("es", "ES");
  Future<Locale> _fetchLocale() async {
    var prefs = await SharedPreferences.getInstance();
    languageCode = prefs.getString('languageCode') ?? 'es';
    countryCode = prefs.getString('countryCode') ?? 'ES';
    print("language code'''''''''''$languageCode");
    print("country code'''''''''''$countryCode");
    return Locale(languageCode, countryCode);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Obx(() => GetMaterialApp(
              theme: ThemeConfig.lightTheme,
              darkTheme: ThemeConfig.darkTheme,
              themeMode: themeController.isDarkMode.value
                  ? ThemeMode.dark
                  : ThemeMode.light,
              translations: Languages(),
              locale: Locale(languageCode, countryCode),
              fallbackLocale: Locale(languageCode, countryCode),
              scaffoldMessengerKey: scaffoldMessengerKey,
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              home: WhiteScreen(),
            ));
      },
    );
  }
}
