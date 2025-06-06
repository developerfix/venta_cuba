import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChrome, SystemUiOverlayStyle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:venta_cuba/Controllers/location_controller.dart';
import 'package:venta_cuba/Services/Notfication/notficationservice.dart';
import 'package:venta_cuba/languages/languages.dart';
import 'package:venta_cuba/view/splash%20Screens/white_screen.dart';
import 'Notification/firebase_messaging.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  await Firebase.initializeApp();
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
  }

  locationCheck() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool isLocationOn = sharedPreferences.getBool('isLocationOn') ?? false;
    if (isLocationOn) {
      //locationCont.getLocation();
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
