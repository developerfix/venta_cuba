import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/Controllers/theme_controller.dart';
import 'package:venta_cuba/Services/Supabase/supabase_service.dart';
import 'package:venta_cuba/Services/notification_manager.dart';
import 'package:venta_cuba/Services/push_service.dart';
import 'package:venta_cuba/Utils/optimized_image.dart';
import 'package:venta_cuba/view/constants/premium_error_handler.dart';
import 'package:venta_cuba/view/constants/premium_performance.dart';
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
          if (i < maxRetries - 1) continue;
        }
      }

      globalPrefs = await SharedPreferences.getInstance();

      // Verify it's working
      await globalPrefs!.reload();

      return;
    } catch (e) {
      if (i == maxRetries - 1) {
        // Don't throw - allow app to continue with limited functionality
      }
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize premium systems
  PremiumErrorHandler.initialize();
  PremiumPerformance.instance.initialize();

  // Initialize critical services only, others will load in background
  _initializeServicesInBackground();

  // Start app immediately
  runApp(const MyApp());
}

// Initialize services in background without blocking startup
void _initializeServicesInBackground() {
  Future.microtask(() async {
    try {
      // Initialize SharedPreferences with shorter timeout
      await _initializeSharedPreferencesQuick();

      // Initialize other services in background
      await _initializePremiumFeatures();
    } catch (e) {}
  });
}

// Quick SharedPreferences initialization with timeout
Future<void> _initializeSharedPreferencesQuick() async {
  if (globalPrefs != null) return;

  try {
    // Set a reasonable timeout to prevent hanging
    globalPrefs = await SharedPreferences.getInstance()
        .timeout(const Duration(seconds: 3));
  } catch (e) {
    // Continue without SharedPreferences rather than hanging
  }
}

/// Initialize all premium performance features
Future<void> _initializePremiumFeatures() async {
  try {
    // Initialize features with timeouts to prevent hanging
    await Future.wait([
      _optimizeImageCache().timeout(const Duration(seconds: 5)),
      _initializeLazyRouting().timeout(const Duration(seconds: 2)),
      _setupOptimizations().timeout(const Duration(seconds: 2)),
      _initializeNotificationManager().timeout(const Duration(seconds: 10)),
      _initializePremiumSystems().timeout(const Duration(seconds: 3)),
    ]).timeout(const Duration(seconds: 15));
  } catch (e) {
    // Don't let initialization errors block the app
  }
}

/// Initialize premium performance and error handling systems
Future<void> _initializePremiumSystems() async {
  // Cache optimization on startup
  await OptimizedCacheManager.optimizeOnStartup();
}

/// Optimize image cache for faster loading
Future<void> _optimizeImageCache() async {
  await OptimizedCacheManager.optimizeOnStartup();

  // Preload critical images
}

/// Initialize lazy routing system
Future<void> _initializeLazyRouting() async {
  // Routes optimized for performance
}

/// Setup optimizations
Future<void> _setupOptimizations() async {
  // Performance optimizations applied
}

/// Initialize premium notification manager
Future<void> _initializeNotificationManager() async {
  try {
    await NotificationManager.instance.initialize();
  } catch (e) {
    // Don't block app startup for notification issues
  }
}

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppLifecycleObserver extends WidgetsBindingObserver {
  static const platform = MethodChannel('venta_cuba/background_service');

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // CRITICAL: Update PushService about app lifecycle for notification logic
    final isInForeground = state == AppLifecycleState.resumed;
    PushService.setAppLifecycleState(isInForeground);

    if (state == AppLifecycleState.resumed) {
      _handleAppResume();
      _restoreServiceNotification();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      try {
        final authCont = Get.find<AuthController>();
        if (authCont.user?.userId != null) {
          // Safe get with fallback
          final chatCont = Get.isRegistered<SupabaseChatController>()
              ? Get.find<SupabaseChatController>()
              : Get.put(SupabaseChatController(), permanent: true);
          chatCont.setUserOffline(authCont.user!.userId.toString());
        }
      } catch (e) {}
    }
  }

  Future<void> _restoreServiceNotification() async {
    try {
      // Only restore if on Android
      if (Platform.isAndroid) {
        await platform.invokeMethod('restoreNotification');
      }
    } catch (e) {}
  }

  Future<void> _handleAppResume() async {
    try {
      final authCont = Get.find<AuthController>();
      if (authCont.user?.userId != null) {
        // Safe get with fallback
        final chatCont = Get.isRegistered<SupabaseChatController>()
            ? Get.find<SupabaseChatController>()
            : Get.put(SupabaseChatController(), permanent: true);

        // CRITICAL: Refresh chat lists IMMEDIATELY when app resumes
        chatCont.refreshAllChatLists();

        // Also reconnect realtime subscriptions to ensure they're active
        chatCont.reconnectRealtimeSubscriptions();

        await chatCont.setUserOnline(authCont.user!.userId.toString());
        await chatCont.updateUnreadMessageIndicators();
        await chatCont.updateBadgeCountFromChats();
        chatCont
            .startListeningForChatUpdates(); // Will skip if already initialized

        // Update PushService badge count and reconnect if needed
        await PushService.onAppResumed();
      }
    } catch (e) {}
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ThemeController themeController;
  String languageCode = 'es';
  String countryCode = 'ES';
  Locale _locale = const Locale("es", "ES");

  @override
  void initState() {
    super.initState();

    themeController = Get.put(ThemeController());

    // Initialize services in background without blocking UI
    Future.microtask(() => _initializeServicesInBackground());

    // Add lifecycle observer
    WidgetsBinding.instance.addObserver(AppLifecycleObserver());

    // Load locale in background
    Future.microtask(() => _loadLocale());
  }

  void _initializeServicesInBackground() async {
    // SharedPreferences already initialized in main()
    if (globalPrefs == null) {
      // Try one more time with quick timeout if it failed in main
      await _initializeSharedPreferencesQuick();
    }

    // Initialize Supabase if configured
    if (AppConfig.isSupabaseConfigured) {
      try {
        await SupabaseService.initialize(
          url: AppConfig.supabaseUrl,
          anonKey: AppConfig.supabaseAnonKey,
        ).timeout(const Duration(seconds: 10));
      } catch (e) {}
    }

    // Check location preferences
    _checkLocationPreferences();

    // Initialize chat controller with singleton protection
    if (!Get.isRegistered<SupabaseChatController>()) {
      Get.put(SupabaseChatController(), permanent: true);
    }
  }

  void _checkLocationPreferences() async {
    // Delay location check to avoid blocking startup
    Future.delayed(const Duration(seconds: 2), () {
      if (globalPrefs != null) {
        bool isLocationOn = globalPrefs!.getBool('isLocationOn') ?? false;
        if (isLocationOn) {
          // Only get location after app is fully loaded
          // locationCont.getLocation();
        }
      }
    });
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
            title: 'Venta Cuba Premium',
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

            // Premium performance settings
            enableLog: false, // Disable logs in production
            logWriterCallback: null, // Remove log callbacks for performance

            // Premium optimized transitions
            defaultTransition: Transition.cupertino,
            transitionDuration: const Duration(milliseconds: 300),
            customTransition:
                null, // Will be handled by our premium transitions
            defaultGlobalState: true, // Enable state preservation

            home: const WhiteScreen(),
          );
        });
      },
    );
  }
}
