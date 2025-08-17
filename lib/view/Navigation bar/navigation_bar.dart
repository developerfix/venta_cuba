import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Controllers/home_controller.dart';
import 'package:venta_cuba/view/Navigation%20bar/listings.dart';
import 'package:venta_cuba/view/Navigation%20bar/profile.dart';
import 'package:venta_cuba/view/Navigation%20bar/selecct_category_post.dart';
import 'package:venta_cuba/view/auth/login.dart';
import 'package:venta_cuba/view/constants/Colors.dart';
import '../../Controllers/auth_controller.dart';
import '../Chat/Controller/SupabaseChatController.dart';
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
  final home = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (cont) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: _buildScreen(cont.currentIndexBottomAppBar),
          bottomNavigationBar: BottomNavigationBar(
            enableFeedback: false,
            backgroundColor:
                Theme.of(context).bottomNavigationBarTheme.backgroundColor,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.k0xFF0254B8,
            unselectedItemColor: Theme.of(context).unselectedWidgetColor,
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
                  // Update the actual badge count when switching to chat tab
                  if (index == 1) {
                    // Update unread count when entering chat screen
                    try {
                      final chatCont = Get.find<SupabaseChatController>();
                      // Update unread message indicators if methods exist
                      print('🔥 Switched to chat tab');
                    } catch (e) {
                      print(
                          '🔥 SupabaseChatController not found when switching to chat tab');
                    }
                  }

                  cont.currentIndexBottomAppBar = index;
                  cont.update();
                }
              }
            },
            items: [
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/icons/home.svg',
                  color: cont.currentIndexBottomAppBar == 0
                      ? AppColors.k0xFF0254B8
                      : Theme.of(context).unselectedWidgetColor,
                ),
                label: 'Home'.tr,
              ),
              BottomNavigationBarItem(
                icon: Obx(() => Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/messenger.svg',
                          color: cont.currentIndexBottomAppBar == 1
                              ? AppColors.k0xFF0254B8
                              : Theme.of(context).unselectedWidgetColor,
                        ),
                        if (cont.unreadMessageCount.value >
                            0) // Show badge with count if there are unread messages
                          Positioned(
                            right: -6,
                            top: -6,
                            child: Container(
                              constraints: BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    width: 1),
                              ),
                              child: Center(
                                child: Text(
                                  cont.unreadMessageCount.value > 99
                                      ? '99+'
                                      : cont.unreadMessageCount.value
                                          .toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                      ],
                    )),
                label: 'Chat'.tr,
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/icons/camera.svg',
                  color: cont.currentIndexBottomAppBar == 2
                      ? AppColors.k0xFF0254B8
                      : Theme.of(context).unselectedWidgetColor,
                ),
                label: 'Post'.tr,
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/icons/tag.svg',
                  color: cont.currentIndexBottomAppBar == 3
                      ? AppColors.k0xFF0254B8
                      : Theme.of(context).unselectedWidgetColor,
                ),
                label: 'Listings'.tr,
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/icons/profile.svg',
                  color: cont.currentIndexBottomAppBar == 4
                      ? AppColors.k0xFF0254B8
                      : Theme.of(context).unselectedWidgetColor,
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
