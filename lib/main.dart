import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:venta_cuba/Controllers/location_controller.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/Controllers/theme_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:venta_cuba/Services/Supabase/supabase_service.dart';
import 'package:venta_cuba/config/app_config.dart';
import 'package:venta_cuba/languages/languages.dart';
import 'package:venta_cuba/view/splash%20Screens/white_screen.dart';
import 'package:venta_cuba/view/Chat/Controller/SupabaseChatController.dart';
import 'package:venta_cuba/view/constants/theme_config.dart';
import 'package:venta_cuba/Notification/firebase_messaging.dart';

String? deviceToken;

// Background message handler - MUST be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Platform.isIOS) {
    await Firebase.initializeApp();
    print('🔥 Background message received: ${message.messageId}');
    await FCM.showBackgroundNotification(message);
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Register background handler for iOS only - non-blocking
  if (Platform.isIOS) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  
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
      _handleAppResume();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      try {
        final authCont = Get.find<AuthController>();
        if (authCont.user?.userId != null) {
          final chatCont = Get.put(SupabaseChatController());
          chatCont.setUserOffline(authCont.user!.userId.toString());
        }
      } catch (e) {
        print('Error setting user offline: $e');
      }
    }
  }

  Future<void> _handleAppResume() async {
    try {
      final authCont = Get.find<AuthController>();
      if (authCont.user?.userId != null) {
        final chatCont = Get.put(SupabaseChatController());
        await chatCont.setUserOnline(authCont.user!.userId.toString());
        await chatCont.updateUnreadMessageIndicators();
        await chatCont.updateBadgeCountFromChats();
        chatCont.startListeningForChatUpdates();
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
  final locationCont = Get.put(LocationController());
  late final ThemeController themeController;
  String languageCode = 'es';
  String countryCode = 'ES';
  Locale _locale = const Locale("es", "ES");

  @override
  void initState() {
    super.initState();
    
    themeController = Get.put(ThemeController());
    
    // Initialize services in background after app starts
    _initializeServicesInBackground();
    
    // Add lifecycle observer
    WidgetsBinding.instance.addObserver(AppLifecycleObserver());
    
    // Load locale in background
    _loadLocale();
  }
  
  void _initializeServicesInBackground() async {
    // Initialize Firebase for iOS only
    if (Platform.isIOS) {
      try {
        await Firebase.initializeApp();
        print('✅ Firebase initialized for iOS');
      } catch (e) {
        print('Firebase init error: $e');
      }
    }
    
    // Initialize SharedPreferences
    try {
      await SharedPreferences.getInstance();
      print('✅ SharedPreferences initialized');
    } catch (e) {
      print('SharedPreferences init error: $e');
    }
    
    // Initialize Supabase if configured
    if (AppConfig.isSupabaseConfigured) {
      try {
        await SupabaseService.initialize(
          url: AppConfig.supabaseUrl,
          anonKey: AppConfig.supabaseAnonKey,
        );
        print('✅ Supabase initialized');
      } catch (e) {
        print('Supabase init error: $e');
      }
    }
    
    // Check location preferences
    _checkLocationPreferences();
    
    // Initialize chat controller
    Get.lazyPut(() => SupabaseChatController());
  }
  
  void _checkLocationPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool isLocationOn = sharedPreferences.getBool('isLocationOn') ?? false;
    if (isLocationOn) {
      //locationCont.getLocation();
    }
  }
  
  void _loadLocale() async {
    var prefs = await SharedPreferences.getInstance();
    languageCode = prefs.getString('languageCode') ?? 'es';
    countryCode = prefs.getString('countryCode') ?? 'ES';
    setState(() {
      _locale = Locale(languageCode, countryCode);
    });
    Get.updateLocale(_locale);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Obx(() {
          return GetMaterialApp(
            theme: ThemeConfig.lightTheme,
            darkTheme: ThemeConfig.darkTheme,
            themeMode: themeController.isDarkMode.value
                ? ThemeMode.dark
                : ThemeMode.light,
            translations: Languages(),
            locale: _locale,
            fallbackLocale: const Locale('es', 'ES'),
            scaffoldMessengerKey: scaffoldMessengerKey,
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            home: const WhiteScreen(),
          );
        });
      },
    );
  }
}