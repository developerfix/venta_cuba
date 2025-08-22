import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/auth_controller.dart';

class WhiteScreen extends StatefulWidget {
  const WhiteScreen({super.key});

  @override
  State<WhiteScreen> createState() => _WhiteScreenState();
}

class _WhiteScreenState extends State<WhiteScreen> {
  late final AuthController authCont;

  @override
  void initState() {
    super.initState();
    
    // Initialize AuthController
    authCont = Get.put(AuthController());
    
    // Check login immediately
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      // Check user login status immediately - no delays
      await authCont.checkUserLoggedIn();
    } catch (e) {
      print('Error during auth check: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Image.asset(
          "assets/images/watermark.png",
          height: 130,
          width: 130,
        ),
      ),
    );
  }
}