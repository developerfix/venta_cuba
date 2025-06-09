import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Controllers/home_controller.dart';
import 'package:venta_cuba/view/Navigation%20bar/listings.dart';
import 'package:venta_cuba/view/Navigation%20bar/profile.dart';
import 'package:venta_cuba/view/Navigation%20bar/selecct_category_post.dart';
import 'package:venta_cuba/view/auth/login.dart';
import 'package:venta_cuba/view/constants/Colors.dart';
import '../../Controllers/auth_controller.dart';
import '../Chat/pages/chats.dart';
import '../home screen/home_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

bool? isChatScreen = false;

class Navigation_Bar extends StatefulWidget {
  const Navigation_Bar({super.key});

  @override
  State<Navigation_Bar> createState() => _Navigation_BarState();
}

class _Navigation_BarState extends State<Navigation_Bar> {
  final authCont = Get.put(AuthController());
  final home = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (cont) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: _buildScreen(cont.currentIndexBottomAppBar),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.k0xFF0254B8,
            unselectedItemColor: Colors.grey,
            currentIndex: cont.currentIndexBottomAppBar,
            onTap: (index) {
              if (index == 2) {
                home.isType = 0;
              }
              if (index == 0) {
                cont.currentIndexBottomAppBar = index;
                cont.update();
              } else {
                if (authCont.user?.email == "") {
                  Get.to(Login());
                } else {
                  cont.currentIndexBottomAppBar = index;
                  cont.update();
                }
                ;
              }
            },
            items: [
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/icons/home.svg',
                  color: cont.currentIndexBottomAppBar == 0
                      ? AppColors.k0xFF0254B8
                      : Colors.grey,
                ),
                label: 'Home'.tr,
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/messenger.svg',
                      color: cont.currentIndexBottomAppBar == 1
                          ? AppColors.k0xFF0254B8
                          : Colors.grey,
                    ),
                    if (cont.hasUnreadMessages
                        .value) // Show badge if there are unread messages
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Chat'.tr,
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/icons/camera.svg',
                  color: cont.currentIndexBottomAppBar == 2
                      ? AppColors.k0xFF0254B8
                      : Colors.grey,
                ),
                label: 'Post'.tr,
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/icons/tag.svg',
                  color: cont.currentIndexBottomAppBar == 3
                      ? AppColors.k0xFF0254B8
                      : Colors.grey,
                ),
                label: 'Listings'.tr,
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/icons/profile.svg',
                  color: cont.currentIndexBottomAppBar == 4
                      ? AppColors.k0xFF0254B8
                      : Colors.grey,
                ),
                label: 'Profile'.tr,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return HomeScreen();
      case 1:
        return Chats();
      case 2:
        return SelectCategoriesPost();
      //   Post(
      //   isUpdate: false,
      // );
      case 3:
        return Listings();
      case 4:
        return Profile();
      default:
        return Container(); // Handle other cases as needed
    }
  }
}
