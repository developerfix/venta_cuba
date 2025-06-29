import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../Controllers/auth_controller.dart';
import '../auth/login.dart';

class WhiteScreen extends StatefulWidget {
  const WhiteScreen({super.key});

  @override
  State<WhiteScreen> createState() => _WhiteScreenState();
}

class _WhiteScreenState extends State<WhiteScreen> {
  final authCont = Get.put(AuthController());
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      print('🔥 WhiteScreen: Starting app initialization...');

      // Add a small delay to ensure all services are ready
      await Future.delayed(const Duration(milliseconds: 500));

      // Initialize Firebase messaging token if not already done
      await _initializeFirebaseToken();

      // Check user login status with error handling and timeout
      await authCont.checkUserLoggedIn().timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          print('🔥 WhiteScreen: Login check timed out, navigating to login');
          Get.offAll(() => const Login());
        },
      );

      print('🔥 WhiteScreen: App initialization completed');
    } catch (e) {
      print('🔥 WhiteScreen: Error during initialization: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to initialize app. Please try again.';
      });

      // Retry after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          isLoading = true;
          errorMessage = null;
        });
        _initializeApp();
      });
    }
  }

  Future<void> _initializeFirebaseToken() async {
    try {
      print('🔥 WhiteScreen: Initializing Firebase token...');
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        // Update the global device token
        deviceToken = token;
        print('🔥 WhiteScreen: Firebase token initialized: $token');
      } else {
        print('🔥 WhiteScreen: Failed to get Firebase token');
      }
    } catch (e) {
      print('🔥 WhiteScreen: Error initializing Firebase token: $e');
      // Don't throw error here, just log it as it's not critical for login check
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              const CircularProgressIndicator(),
            ] else if (errorMessage != null) ...[
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
