import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/auth_controller.dart';

class WhiteScreen extends StatefulWidget {
  const WhiteScreen({super.key});

  @override
  State<WhiteScreen> createState() => _WhiteScreenState();
}

class _WhiteScreenState extends State<WhiteScreen> {
  final authCont=Get.put(AuthController());
  @override
  void initState() {
    // TODO: implement initState
    authCont.checkUserLoggedIn();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
