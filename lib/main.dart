import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:venta_cuba/Controllers/location_controller.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/Controllers/theme_controller.dart';
import 'package:venta_cuba/Services/Supabase/supabase_service.dart';
import 'package:venta_cuba/config/app_config.dart';
import 'package:venta_cuba/languages/languages.dart';
import 'package:venta_cuba/view/splash%20Screens/white_screen.dart';
import 'package:venta_cuba/view/Chat/Controller/SupabaseChatController.dart';
import 'package:venta_cuba/view/constants/theme_config.dart';


String? deviceToken;


// Global SharedPreferences instance
SharedPreferences? globalPrefs;

// Initialize SharedPreferences with iOS-specific handling
Future<void> initializeSharedPreferences() async {
  if (globalPrefs != null) return;

  int maxRetries = 5;
  for (int i = 0; i < maxRetries; i++) {
    try {
      // Add platform-specific delay for iOS
      if (Platform.isIOS) {
        // Wait for platform channels to be fully established
        await Future.delayed(Duration(milliseconds: 100 * (i + 1)));

        // Ensure method channel is ready
        const platform = MethodChannel('plugins.flutter.io/shared_preferences');
        try {
          await platform.invokeMethod('getAll');
        } catch (e) {
          print('Platform channel not ready, attempt ${i + 1}/$maxRetries');
          if (i < maxRetries - 1) continue;
        }
      }

      globalPrefs = await SharedPreferences.getInstance();

      // Verify it's working
      await globalPrefs!.reload();

      print('✅ SharedPreferences initialized successfully on attempt ${i + 1}');
      return;
    } catch (e) {
      print('⚠️ SharedPreferences init attempt ${i + 1} failed: $e');
      if (i == maxRetries - 1) {
        print(
            '❌ Failed to initialize SharedPreferences after $maxRetries attempts');
        // Don't throw - allow app to continue with limited functionality
      }
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences before anything else
  await initializeSharedPreferences();


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

    // SharedPreferences already initialized in main()
    if (globalPrefs == null) {
      // Try one more time if it failed in main
      await initializeSharedPreferences();
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
    if (globalPrefs != null) {
      bool isLocationOn = globalPrefs!.getBool('isLocationOn') ?? false;
      if (isLocationOn) {
        //locationCont.getLocation();
      }
    }
  }

  void _loadLocale() async {
    if (globalPrefs != null) {
      languageCode = globalPrefs!.getString('languageCode') ?? 'es';
      countryCode = globalPrefs!.getString('countryCode') ?? 'ES';
      setState(() {
        _locale = Locale(languageCode, countryCode);
      });
      Get.updateLocale(_locale);
    }
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
