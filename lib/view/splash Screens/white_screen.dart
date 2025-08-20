import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Firebase removed for Cuba compatibility
// import '../../Services/Firebase/firebase_messaging_service.dart';
import '../../Controllers/auth_controller.dart';

class WhiteScreen extends StatefulWidget {
  const WhiteScreen({super.key});

  @override
  State<WhiteScreen> createState() => _WhiteScreenState();
}

class _WhiteScreenState extends State<WhiteScreen> {
  late final AuthController authCont;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    print('🔥 WhiteScreen: initState() called');

    // Initialize AuthController safely
    try {
      print('🔥 WhiteScreen: Initializing AuthController...');
      authCont = Get.put(AuthController());
      print('🔥 WhiteScreen: AuthController initialized successfully');
    } catch (e) {
      print('🔥 WhiteScreen: Error initializing AuthController: $e');
    }

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      print('🔥 WhiteScreen: Starting app initialization...');

      // Add a small delay to ensure all services are ready
      await Future.delayed(const Duration(milliseconds: 800));

      // Initialize notification service if not already done
      await _initializeNotificationService();

      print('🔥 WhiteScreen: About to check user login status...');

      // Check user login status - let AuthController handle all navigation
      // Don't catch errors here, let AuthController handle everything
      await authCont.checkUserLoggedIn();

      print('🔥 WhiteScreen: App initialization completed');
    } catch (e) {
      print('🔥 WhiteScreen: Error during initialization: $e');
      // AuthController should have handled navigation, so just update loading state
      setState(() {
        isLoading = false;
        errorMessage = 'Initialization failed. Redirecting...';
      });
    }
  }

  Future<void> _initializeNotificationService() async {
    try {
      print('🔥 WhiteScreen: Push notification service ready');
      // Firebase removed for Cuba compatibility
      // Real Push Service will be initialized after user login
      print('🔥 WhiteScreen: RealPushService will be initialized after login');
    } catch (e) {
      print('🔥 WhiteScreen: Error with notification service: $e');
      // Don't throw error here, just log it as it's not critical for login check
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
        '🔥 WhiteScreen: build() called - isLoading: $isLoading, errorMessage: $errorMessage');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Image.asset(
              "assets/images/watermark.png",
              height: 130,
              width: 130,
            ),
            const SizedBox(height: 40),

            if (errorMessage != null) ...[
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    errorMessage = null;
                  });
                  _initializeApp();
                },
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
