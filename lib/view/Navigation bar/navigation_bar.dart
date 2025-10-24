import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Controllers/home_controller.dart';
import 'package:venta_cuba/view/Navigation%20bar/listings.dart';
import 'package:venta_cuba/view/Navigation%20bar/profile.dart';
import 'package:venta_cuba/view/Navigation%20bar/selecct_category_post.dart';
import 'package:venta_cuba/view/auth/login.dart';
import 'package:venta_cuba/view/constants/Colors.dart';
import 'package:venta_cuba/view/constants/premium_animations.dart';
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

class _Navigation_BarState extends State<Navigation_Bar>
    with TickerProviderStateMixin {
  final authCont = Get.put(AuthController());
  final home = Get.put(HomeController());

  // Pre-create screens for better performance
  late final List<Widget> _screens;

  // Animation controllers for premium transitions
  late AnimationController _iconAnimationController;
  late AnimationController _badgeAnimationController;
  late List<Animation<double>> _iconScaleAnimations;
  late Animation<double> _badgeScaleAnimation;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(),
      Chats(),
      SelectCategoriesPost(),
      Listings(),
      Profile(),
    ];

    // Initialize premium animations
    _setupAnimations();

    // Initialize unread message count when navigation bar loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUnreadCount();
    });
  }

  void _setupAnimations() {
    // Icon animation controller
    _iconAnimationController = AnimationController(
      duration: PremiumAnimations.fast,
      vsync: this,
    );

    // Badge animation controller
    _badgeAnimationController = AnimationController(
      duration: PremiumAnimations.medium,
      vsync: this,
    );

    // Create scale animations for each icon
    _iconScaleAnimations = List.generate(5, (index) {
      return Tween<double>(
        begin: 1.0,
        end: 1.1,
      ).animate(CurvedAnimation(
        parent: _iconAnimationController,
        curve: PremiumAnimations.smoothCurve,
      ));
    });

    // Badge scale animation
    _badgeScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _badgeAnimationController,
      curve: Curves.elasticOut,
    ));

    // Start badge animation when unread count changes
    authCont.unreadMessageCount.listen((count) {
      if (count > 0) {
        _badgeAnimationController.forward();
      } else {
        _badgeAnimationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    _badgeAnimationController.dispose();
    super.dispose();
  }

  void _initializeUnreadCount() async {
    try {
      if (authCont.user?.userId != null) {
        try {
          final chatController = Get.find<SupabaseChatController>();
          await chatController.updateUnreadMessageIndicators();
        } catch (e) {
          // Try to create it
          final chatController = Get.put(SupabaseChatController());
          await chatController.updateUnreadMessageIndicators();
        }
      }

      // Badge will update automatically based on real unread messages
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (cont) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: IndexedStack(
            index: cont.currentIndexBottomAppBar,
            children: _screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            enableFeedback: false,
            backgroundColor:
                Theme.of(context).bottomNavigationBarTheme.backgroundColor,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.k0xFF0254B8,
            unselectedItemColor: Theme.of(context).unselectedWidgetColor,
            currentIndex: cont.currentIndexBottomAppBar,
            onTap: (index) async {
              // Removed haptic feedback as requested

              // Animate icon press
              _iconAnimationController.forward().then((_) {
                _iconAnimationController.reverse();
              });

              if (index == 2) {
                home.isType = 0;
              }
              if (index == 0) {
                cont.currentIndexBottomAppBar = index;
                cont.update();
              } else {
                if (authCont.user?.email == "") {
                  // Navigate to login with premium transition
                  await Navigator.of(context)
                      .push(PremiumPageTransitions.slideFromRight(Login()));
                } else {
                  // Update the actual badge count when switching to chat tab
                  if (index == 1) {
                    // Update unread count when entering chat screen
                    try {
                      final chatController = Get.find<SupabaseChatController>();
                      chatController.updateUnreadMessageIndicators();
                      print(
                          '🔥 Switched to chat tab, current unread count: ${authCont.unreadMessageCount.value}');
                    } catch (e) {
                      print(
                          '🔥 SupabaseChatController not found when switching to chat tab');
                    }
                  }

                  // Debug: Print current unread count
                  print(
                      '🔥 Navigation - Current unread count: ${authCont.unreadMessageCount.value}');

                  cont.currentIndexBottomAppBar = index;
                  cont.update();
                }
              }
            },
            items: [
              BottomNavigationBarItem(
                icon: AnimatedBuilder(
                  animation: _iconScaleAnimations[0],
                  builder: (context, child) {
                    return Transform.scale(
                      scale: cont.currentIndexBottomAppBar == 0
                          ? _iconScaleAnimations[0].value
                          : 1.0,
                      child: SvgPicture.asset(
                        'assets/icons/home.svg',
                        colorFilter: ColorFilter.mode(
                          cont.currentIndexBottomAppBar == 0
                              ? AppColors.k0xFF0254B8
                              : Theme.of(context).unselectedWidgetColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    );
                  },
                ),
                label: 'Home'.tr,
              ),
              BottomNavigationBarItem(
                icon: AnimatedBuilder(
                  animation: _iconScaleAnimations[1],
                  builder: (context, child) {
                    return Transform.scale(
                      scale: cont.currentIndexBottomAppBar == 1
                          ? _iconScaleAnimations[1].value
                          : 1.0,
                      child: Obx(() {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/messenger.svg',
                              colorFilter: ColorFilter.mode(
                                cont.currentIndexBottomAppBar == 1
                                    ? AppColors.k0xFF0254B8
                                    : Theme.of(context).unselectedWidgetColor,
                                BlendMode.srcIn,
                              ),
                            ),
                            if (authCont.unreadMessageCount.value >
                                0) // Show badge with count if there are unread messages
                              Positioned(
                                right: -8,
                                top: -8,
                                child: ScaleTransition(
                                  scale: _badgeScaleAnimation,
                                  child: Container(
                                    constraints: BoxConstraints(
                                      minWidth: 18,
                                      minHeight: 18,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red[600],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.2),
                                          blurRadius: 3,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        authCont.unreadMessageCount.value > 99
                                            ? '99+'
                                            : authCont.unreadMessageCount.value
                                                .toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      }),
                    );
                  },
                ),
                label: 'Chat'.tr,
              ),
              BottomNavigationBarItem(
                icon: AnimatedBuilder(
                  animation: _iconScaleAnimations[2],
                  builder: (context, child) {
                    return Transform.scale(
                      scale: cont.currentIndexBottomAppBar == 2
                          ? _iconScaleAnimations[2].value
                          : 1.0,
                      child: SvgPicture.asset(
                        'assets/icons/camera.svg',
                        colorFilter: ColorFilter.mode(
                          cont.currentIndexBottomAppBar == 2
                              ? AppColors.k0xFF0254B8
                              : Theme.of(context).unselectedWidgetColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    );
                  },
                ),
                label: 'Post'.tr,
              ),
              BottomNavigationBarItem(
                icon: AnimatedBuilder(
                  animation: _iconScaleAnimations[3],
                  builder: (context, child) {
                    return Transform.scale(
                      scale: cont.currentIndexBottomAppBar == 3
                          ? _iconScaleAnimations[3].value
                          : 1.0,
                      child: SvgPicture.asset(
                        'assets/icons/tag.svg',
                        colorFilter: ColorFilter.mode(
                          cont.currentIndexBottomAppBar == 3
                              ? AppColors.k0xFF0254B8
                              : Theme.of(context).unselectedWidgetColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    );
                  },
                ),
                label: 'Listings'.tr,
              ),
              BottomNavigationBarItem(
                icon: AnimatedBuilder(
                  animation: _iconScaleAnimations[4],
                  builder: (context, child) {
                    return Transform.scale(
                      scale: cont.currentIndexBottomAppBar == 4
                          ? _iconScaleAnimations[4].value
                          : 1.0,
                      child: SvgPicture.asset(
                        'assets/icons/profile.svg',
                        colorFilter: ColorFilter.mode(
                          cont.currentIndexBottomAppBar == 4
                              ? AppColors.k0xFF0254B8
                              : Theme.of(context).unselectedWidgetColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    );
                  },
                ),
                label: 'Profile'.tr,
              ),
            ],
          ),
        );
      },
    );
  }
}
