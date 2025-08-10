import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:venta_cuba/Controllers/location_controller.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/Controllers/theme_controller.dart';

// Firebase removed for Cuba compatibility
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:venta_cuba/Services/Supabase/supabase_service.dart';
import 'package:venta_cuba/config/app_config.dart';
import 'package:venta_cuba/languages/languages.dart';
import 'package:venta_cuba/view/splash%20Screens/white_screen.dart';
import 'package:venta_cuba/view/Chat/Controller/SupabaseChatController.dart';
import 'package:venta_cuba/view/constants/theme_config.dart';

String? deviceToken;

// Firebase background handler removed for Cuba compatibility

Future<void> main() async {
  try {
    print('🔥 Starting app initialization...');

    WidgetsFlutterBinding.ensureInitialized();
    print('🔥 WidgetsFlutterBinding initialized');

    // Initialize Real Push Service instead of Firebase
    // Note: User ID will be set after login
    print('🔥 Real Push Service ready (will initialize after login)');

    await SharedPreferences.getInstance();
    print('🔥 SharedPreferences initialized');

    // Initialize Supabase only if properly configured
    if (AppConfig.isSupabaseConfigured) {
      try {
        await SupabaseService.initialize(
          url: AppConfig.supabaseUrl,
          anonKey: AppConfig.supabaseAnonKey,
        );
        print('✅ Supabase initialized successfully');
      } catch (e) {
        print('❌ Error initializing Supabase: $e');
        print('💡 Chat functionality will be disabled');
      }
    } else {
      print('⚠️ Supabase not configured - Chat functionality will be disabled');
      print('💡 Please update AppConfig with your Supabase credentials');
    }

    // Firebase removed for Cuba compatibility
    // Real Push Service will be initialized after user login
    try {
      print('✅ Real Push Service ready for initialization after login');
    } catch (e) {
      print('❌ Error with push service: $e');
    }

    print('🔥 About to run app...');

    runApp(const MyApp());
  } catch (e, stackTrace) {
    print('🔥 CRITICAL ERROR in main(): $e');
    print('🔥 Stack trace: $stackTrace');

    // Run a minimal app to show error
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('App initialization failed', style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Text('Error: $e', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    ));
  }
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
        if (authCont.user?.userId != null) {
          final chatCont = Get.put(SupabaseChatController());
          chatCont.setUserOffline(authCont.user!.userId.toString());
          print('🔥 User set as offline');
        }
      } catch (e) {
        print('Error setting user offline: $e');
      }
    }
  }

  Future<void> _handleAppResume() async {
    try {
      print('🔥 App resumed - handling badge count and user status');

      // Handle app opened - reset badge count first
      // Firebase removed for Cuba compatibility
      // await FirebaseMessagingService.handleAppOpened();

      final authCont = Get.find<AuthController>();

      // Firebase removed for Cuba compatibility
      // Real Push Service is handled in auth controller
      if (authCont.user?.userId != null) {
        print('🔥 User active - push service ready');
      }

      // Set user as online when app becomes active
      if (authCont.user?.userId != null) {
        final chatCont = Get.put(SupabaseChatController());
        await chatCont.setUserOnline(authCont.user!.userId.toString());
      }

      // Update unread message indicators and restart chat listener
      try {
        final chatCont = Get.put(SupabaseChatController());
        await chatCont.updateUnreadMessageIndicators();
        await chatCont.updateBadgeCountFromChats();
        chatCont.startListeningForChatUpdates();
        print('🔥 Chat services restarted on app resume');
      } catch (e) {
        print('🔥 SupabaseChatController not found on app resume: $e');
      }
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
  // Firebase removed for Cuba compatibility
  // final firebaseMessagingService = FirebaseMessagingService();
  final locationCont = Get.put(LocationController());
  late final ThemeController themeController;

  @override
  void initState() {
    super.initState();

    print('🔥 MyApp: initState() called');

    // Initialize theme controller first
    print('🔥 MyApp: Initializing ThemeController...');
    themeController = Get.put(ThemeController());
    print('🔥 MyApp: ThemeController initialized');

    // Location and notification setup
    locationCheck();

    // Firebase removed for Cuba compatibility
    // Notifications are handled by RealPushService
    print('🔥 Push notifications ready via RealPushService');

    _fetchLocale().then((locale) {
      print('🔥 MyApp: Locale fetched: $locale');
      setState(() {
        _locale = locale;
        debugPrint("_locale...................$_locale");
      });
      Get.updateLocale(locale);
    });

    // Listen for app lifecycle changes
    WidgetsBinding.instance.addObserver(AppLifecycleObserver());

    // Check notification permissions after a delay
    Future.delayed(Duration(seconds: 3), () {
      checkNotificationPermissions();
    });

    Get.lazyPut(() => SupabaseChatController());

    print('🔥 MyApp: initState() completed');
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
      // Firebase removed for Cuba compatibility
      // await firebaseMessagingService.requestPermission();
      print('Notification permissions ready (using local notifications)');
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
    print('🔥 MyApp: build() called');

    try {
      return ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          print('🔥 MyApp: ScreenUtilInit builder called');

          try {
            return Obx(() {
              print(
                  '🔥 MyApp: Obx builder called, isDarkMode: ${themeController.isDarkMode.value}');

              return GetMaterialApp(
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
                home: Builder(
                  builder: (context) {
                    print(
                        '🔥 MyApp: Home Builder called, navigating to WhiteScreen');
                    return WhiteScreen();
                  },
                ),
              );
            });
          } catch (e) {
            print('🔥 Error in Obx builder: $e');
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Theme initialization failed',
                          style: TextStyle(fontSize: 18)),
                      SizedBox(height: 8),
                      Text('Error: $e', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      );
    } catch (e) {
      print('🔥 Error in MyApp build: $e');
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text('App build failed', style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text('Error: $e', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      );
    }
  }
}
