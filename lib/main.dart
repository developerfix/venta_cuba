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
import 'package:venta_cuba/Services/Notfication/notficationservice.dart';
import 'package:venta_cuba/languages/languages.dart';
import 'package:venta_cuba/view/splash%20Screens/white_screen.dart';
import 'package:venta_cuba/view/Chat/Controller/ChatController.dart';
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
      final authCont = Get.find<AuthController>();
      authCont.refreshDeviceToken();
      // Also update device tokens in all chat documents
      if (authCont.user?.userId != null) {
        authCont.updateDeviceTokenInAllChats(deviceToken);
      }

      // Set user as online when app becomes active
      authCont.setUserOnline();

      // Update badge count based on actual unread messages when app becomes active
      try {
        final chatCont = Get.find<ChatController>();
        await chatCont.updateBadgeCountFromChats();
        print('🔥 Badge count updated on app resume');
      } catch (e) {
        // If ChatController is not initialized, just clear the badge
        FCM.clearBadgeCount();
        print('🔥 Badge cleared on app resume (ChatController not found)');
      }
    } catch (e) {
      print('Error refreshing token on app resume: $e');
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
  NotificationService notificationService = NotificationService();

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

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
        return GetMaterialApp(
            theme: ThemeData(
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.white,
              ),
              scaffoldBackgroundColor: Colors.white,
              cardColor: Colors.white, // Set scaffold background color to white
            ),
            translations: Languages(),
            locale: Locale(languageCode, countryCode),
            //Locale(languageCode, countryCode),
            fallbackLocale: Locale(languageCode, countryCode),
            //Locale(languageCode, countryCode),
            scaffoldMessengerKey: scaffoldMessengerKey,
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            //home: SubscriptionScreen()
            home: WhiteScreen()
            // home: PaymentNext(fromCuba: false,)

            );
      },
    );
  }
}
