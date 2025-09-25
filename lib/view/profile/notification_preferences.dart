import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/view/constants/Colors.dart';

class NotificationPreferences extends StatefulWidget {
  const NotificationPreferences({super.key});

  @override
  State<NotificationPreferences> createState() =>
      _NotificationPreferencesState();
}

class _NotificationPreferencesState extends State<NotificationPreferences> {
  bool switchState1 = false;
  bool switchState2 = false;
  bool switchState3 = false;
  bool switchState4 = false;
  bool switchState5 = false;
  bool switchState6 = false;
  final authCont = Get.put(AuthController());

  @override
  void initState() {
    // getPrefs();
    if (authCont.user?.allNotifications != null) {
      switchState1 = authCont.user?.allNotifications.toString() == "1";
      print(switchState1);
    }
    if (authCont.user?.bumpUpNotification != null) {
      switchState2 = authCont.user?.bumpUpNotification.toString() == "1";
    }
    if (authCont.user?.messageNotification != null) {
      switchState4 = authCont.user?.messageNotification.toString() == "1";
    }
    if (authCont.user?.saveSearchNotification != null) {
      switchState3 = authCont.user?.saveSearchNotification.toString() == "1";
    }
    if (authCont.user?.marketingNotification != null) {
      switchState5 = authCont.user?.marketingNotification.toString() == "1";
    }
    if (authCont.user?.reviewsNotification != null) {
      switchState6 = authCont.user?.reviewsNotification.toString() == "1";
    }

    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SafeArea(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 20,
                      ),
                    ),
                    Text(
                      'Notifications Preferences'.tr,
                      style: TextStyle(
                          fontSize: 21..sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.titleLarge?.color),
                    ),
                    Container(
                      height: 24..h,
                      width: 4..w,
                      color: Colors.transparent,
                    )
                  ],
                ),
                SizedBox(
                  height: 50..h,
                ),
                Container(
                  padding: EdgeInsets.only(left: 13),
                  height: 74..h,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.k0xFFC4C4C4.withValues(alpha: 0.1)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 250,
                        child: Text(
                          'Allow all in-app notifications'.tr,
                          style: TextStyle(
                              fontSize: 17..sp,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.color),
                        ),
                      ),
                      Switch(
                        // enabledThumbColor: AppColors.k0xFF0254B8,
                        // enabledTrackColor: AppColors.k0xFF0254B8.withValues(alpha: 0.5),
                        value: switchState1,
                        onChanged: (newValue) {
                          setState(() {
                            switchState1 = newValue;
                            switchState2 = switchState1;
                            switchState3 = switchState1;
                            switchState4 = switchState1;
                            switchState4 = switchState1;
                            switchState5 = switchState1;
                            switchState6 = switchState1;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20..h,
                ),
                Container(
                  padding: EdgeInsets.only(left: 13),
                  height: 74..h,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.k0xFFC4C4C4.withValues(alpha: 0.1)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Bump up'.tr,
                            style: TextStyle(
                                fontSize: 17..sp,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.color),
                          ),
                          SizedBox(
                            height: 5..h,
                          ),
                          Text(
                            'If your listing loses visibility'.tr,
                            style: TextStyle(
                                fontSize: 11..sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.k0xFFA9ABAC),
                          ),
                        ],
                      ),
                      Switch(
                        // enabledThumbColor: AppColors.k0xFF0254B8,
                        // enabledTrackColor: AppColors.k0xFF0254B8.withValues(alpha: 0.5),
                        value: switchState2,
                        onChanged: (newValue) {
                          setState(() {
                            switchState2 = newValue;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20..h,
                ),
                Container(
                  padding: EdgeInsets.only(left: 13),
                  height: 74..h,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.k0xFFC4C4C4.withValues(alpha: 0.1)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Save Search'.tr,
                            style: TextStyle(
                                fontSize: 17..sp,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.color),
                          ),
                          SizedBox(
                            height: 5..h,
                          ),
                          Text(
                            'If there are new saves search results'.tr,
                            style: TextStyle(
                                fontSize: 11..sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.k0xFFA9ABAC),
                          ),
                        ],
                      ),
                      Switch(
                        // enabledThumbColor: AppColors.k0xFF0254B8,
                        // enabledTrackColor: AppColors.k0xFF0254B8.withValues(alpha: 0.5),
                        value: switchState3,
                        onChanged: (newValue) async {
                          setState(() {
                            switchState3 = newValue!;
                          });
                          // Add custom logic for Row 5 here.
                        },
                        // activeColor: AppColors.k0xFF0254B8,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20..h,
                ),
                Container(
                  padding: EdgeInsets.only(left: 13),
                  height: 74..h,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.k0xFFC4C4C4.withValues(alpha: 0.1)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Messages'.tr,
                            style: TextStyle(
                                fontSize: 17..sp,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.color),
                          ),
                          SizedBox(
                            height: 5..h,
                          ),
                          Text(
                            'Receive messages from seller and buyer'.tr,
                            style: TextStyle(
                                fontSize: 11..sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.k0xFFA9ABAC),
                          ),
                        ],
                      ),
                      Switch(
                        value: switchState4,
                        // enabledThumbColor: AppColors.k0xFF0254B8,
                        // enabledTrackColor: AppColors.k0xFF0254B8.withValues(alpha: 0.5),
                        onChanged: (newValue) async {
                          setState(() {
                            switchState4 = newValue!;
                          });
                          // Add custom logic for Row 5 here.
                        },
                        // activeColor: AppColors.k0xFF0254B8,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20..h,
                ),
                Container(
                  padding: EdgeInsets.only(left: 13),
                  height: 74..h,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.k0xFFC4C4C4.withValues(alpha: 0.1)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Marketing'.tr,
                            style: TextStyle(
                                fontSize: 17..sp,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.color),
                          ),
                          SizedBox(
                            height: 5..h,
                          ),
                          SizedBox(
                            width: 250,
                            child: Text(
                              'Keep up to date with promotions and products update from VentaCuba'
                                  .tr,
                              style: TextStyle(
                                  fontSize: 11..sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.k0xFFA9ABAC),
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: switchState5,
                        // enabledThumbColor: AppColors.k0xFF0254B8,
                        // enabledTrackColor: AppColors.k0xFF0254B8.withValues(alpha: 0.5),
                        onChanged: (newValue) async {
                          setState(() {
                            switchState5 = newValue!;
                          });
                          // Add custom logic for Row 5 here.
                        },
                        // activeColor: AppColors.k0xFF0254B8,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20..h,
                ),
                Container(
                  padding: EdgeInsets.only(left: 13),
                  height: 74..h,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.k0xFFC4C4C4.withValues(alpha: 0.1)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Reviews'.tr,
                            style: TextStyle(
                                fontSize: 17..sp,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.color),
                          ),
                          SizedBox(
                            height: 5..h,
                          ),
                          Text(
                            'If you have new or pending reviews'.tr,
                            style: TextStyle(
                                fontSize: 11..sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.k0xFFA9ABAC),
                          ),
                        ],
                      ),
                      Switch(
                        // enabledThumbColor: AppColors.k0xFF0254B8,
                        // enabledTrackColor: AppColors.k0xFF0254B8.withValues(alpha: 0.5),
                        value: switchState6,
                        // duration: Duration(milliseconds: 200),
                        onChanged: (newValue) async {
                          setState(() {
                            switchState6 = newValue!;
                          });
                          // Add custom logic for Row 5 here.
                        },
                        // activeColor: AppColors.k0xFF0254B8,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20..h,
                ),
                InkWell(
                  onTap: () {
                    authCont.allNotification = switchState1 ? 1 : 0;
                    authCont.bumpUpNotification = switchState2 ? 1 : 0;
                    authCont.saveSearchNotification = switchState3 ? 1 : 0;
                    authCont.messageNotification = switchState4 ? 1 : 0;
                    authCont.marketingNotification = switchState5 ? 1 : 0;
                    authCont.reviewsNotification = switchState6 ? 1 : 0;
                    authCont.saveNotificationSettings();
                  },
                  child: Container(
                    height: 60..h,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Color(0xFF0254B8),
                        borderRadius: BorderRadius.circular(10.r)),
                    child: Center(
                      child: SizedBox(
                        width: 240.w,
                        child: Center(
                          child: FittedBox(
                            child: Text(
                              'Save Notification Setting'.tr,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20..h,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GFToggle extends StatefulWidget {
  const GFToggle(
      {Key? key,
      required this.onChanged,
      required this.value,
      this.enabledText,
      this.disabledText,
      this.enabledTextStyle,
      this.enabledThumbColor,
      this.enabledTrackColor,
      this.disabledTextStyle,
      this.disabledTrackColor,
      this.disabledThumbColor,
      this.type,
      this.boxShape,
      this.borderRadius,
      this.duration = const Duration(milliseconds: 200)})
      : super(key: key);

  final String? enabledText;
  final String? disabledText;
  final TextStyle? enabledTextStyle;
  final TextStyle? disabledTextStyle;
  final Color? enabledThumbColor;
  final Color? disabledThumbColor;
  final Color? enabledTrackColor;
  final Color? disabledTrackColor;
  final BoxShape? boxShape;
  final BorderRadius? borderRadius;
  final Duration duration;
  final GFToggleType? type;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  _GFToggleState createState() => _GFToggleState();
}

class _GFToggleState extends State<GFToggle> with TickerProviderStateMixin {
  AnimationController? animationController;
  Animation<double>? animation;
  late AnimationController controller;
  late Animation<Offset> offset;
  late bool isOn;
  @override
  void initState() {
    isOn = widget.value;
    controller = AnimationController(duration: widget.duration, vsync: this);
    offset = (isOn
            ? Tween<Offset>(
                begin: const Offset(1.28, 0),
                end: Offset.zero,
              )
            : Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(1.28, 0),
              ))
        .animate(controller);
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    controller.dispose();
    super.dispose();
  }

  void onStatusChange() {
    setState(() {
      isOn = !isOn;
    });
    switch (controller.status) {
      case AnimationStatus.dismissed:
        controller.forward();
        break;
      case AnimationStatus.completed:
        controller.reverse();
        break;
      default:
    }
    widget.onChanged(isOn);
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: <Widget>[
          Container(
            height: widget.type == GFToggleType.android ? 25 : 30,
            width: widget.type == GFToggleType.android ? 46.5 : 55,
          ),
          Positioned(
            top: 5,
            child: InkWell(
              borderRadius: widget.type == GFToggleType.square
                  ? const BorderRadius.all(Radius.circular(0))
                  : widget.borderRadius ??
                      const BorderRadius.all(Radius.circular(20)),
              onTap: onStatusChange,
              child: Container(
                width: widget.type == GFToggleType.ios ? 54 : 46,
                height: widget.type == GFToggleType.ios ? 25 : 18,
                decoration: BoxDecoration(
                    color: isOn
                        ? widget.enabledTrackColor ?? Colors.lightGreen
                        : widget.disabledTrackColor ??
                            Theme.of(context).unselectedWidgetColor,
                    borderRadius: widget.type == GFToggleType.square
                        ? const BorderRadius.all(Radius.circular(0))
                        : widget.borderRadius ??
                            const BorderRadius.all(Radius.circular(20))),
                padding: widget.type == GFToggleType.ios
                    ? const EdgeInsets.only(
                        left: 3.5,
                        right: 3.5,
                      )
                    : const EdgeInsets.only(
                        left: 7,
                        right: 7,
                      ),
                child: isOn
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          (widget.enabledText != null &&
                                      widget.enabledText!.length > 4
                                  ? widget.enabledText?.substring(0, 4)
                                  : widget.enabledText) ??
                              (widget.type == GFToggleType.custom ? 'ON' : ''),
                          style: widget.enabledTextStyle ??
                              (widget.type == GFToggleType.ios
                                  ? const TextStyle(
                                      color: Colors.white, fontSize: 12)
                                  : const TextStyle(
                                      color: Colors.white, fontSize: 8)),
                        ))
                    : Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          (widget.disabledText != null &&
                                      widget.disabledText!.length > 4
                                  ? widget.disabledText?.substring(0, 4)
                                  : widget.disabledText) ??
                              (widget.type == GFToggleType.custom ? 'OFF' : ''),
                          style: widget.disabledTextStyle ??
                              (widget.type == GFToggleType.ios
                                  ? const TextStyle(
                                      color: Colors.white, fontSize: 12)
                                  : const TextStyle(
                                      color: Colors.white, fontSize: 8)),
                        )),
              ),
            ),
          ),
          Positioned(
            top: widget.type == GFToggleType.ios ? 6.5 : 3,
            left: widget.type == GFToggleType.ios ? 3 : 0,
            child: InkWell(
              onTap: onStatusChange,
              child: SlideTransition(
                position: offset,
                child: Container(
                  padding: const EdgeInsets.only(left: 10),
                  height: 22,
                  width: 22,
                  decoration: BoxDecoration(
                    shape: widget.type == GFToggleType.square
                        ? BoxShape.rectangle
                        : widget.boxShape ?? BoxShape.circle,
                    color: isOn
                        ? widget.enabledThumbColor ?? Colors.white
                        : widget.disabledThumbColor ?? Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.16),
                        blurRadius: 6,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
}

enum GFToggleType { android, custom, ios, square }
