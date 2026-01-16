import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../main.dart';

showSnackBar({Color? color, String? title}) {
  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
        padding: EdgeInsets.only(left: 10.w, top: 5.h, bottom: 5.h),
        duration: Duration(seconds: 3),
        content:
            Text(title ?? "Something went wrong. Please check and try again.",
                style: TextStyle(
                  color: Colors.white,
                ))),
  );
}

errorAlertToast(String error, {bool? isOnTop}) {
  final context = navigatorKey.currentContext;

  if (context != null) {
    FToast fToast = FToast();
    fToast.init(context);

    fToast.removeCustomToast();

    fToast.showToast(
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            color: Colors.black87,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              )
            ],
          ),
          child: Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      // Gravity ki jagah positionedToastBuilder use karein exact control ke liye
      positionedToastBuilder: (context, child, gravity) {
        return Positioned(
          child: child,
          // Top position set kar rahe hain
          top: isOnTop != null ? 20.0 : null,
          bottom: isOnTop != null ? null : 20.0,
          left: 0,
          right: 0,
        );
      },
      toastDuration: Duration(seconds: 2),
    );
  } else {
    // Fallback
    Fluttertoast.showToast(
      msg: error,
      gravity: isOnTop != null ? ToastGravity.TOP : ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }
}

showLoading() {
  showDialog(
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      context: navigatorKey.currentContext!,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
          backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
          shadowColor: Colors.black,
          elevation: 5,
          child: Container(
            height: 60.h,
            width: double.infinity,
            color: Theme.of(context).dialogTheme.backgroundColor,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: Row(
                children: [
                  SizedBox(
                      height: 30.h,
                      width: 30.w,
                      child: CircularProgressIndicator()),
                  SizedBox(width: 40.h),
                  Text(
                    'Loading...'.tr,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color ??
                            Colors.black),
                  ),
                ],
              ),
            ),
          ),
        );
      });
}

errorShowDialog({String? text}) {
  showDialog(
      barrierColor: Colors.transparent,
      context: navigatorKey.currentContext!,
      builder: (context) {
        return Dialog(
          // backgroundColor: Color(0x7F373535),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          shadowColor: Colors.black,
          elevation: 0,
          child: Container(
            width: 150.w,
            height: 150.h,
            decoration: ShapeDecoration(
              color:
                  Theme.of(context).dialogTheme.backgroundColor ?? Colors.white,
              shadows: [
                BoxShadow(color: Colors.black45, spreadRadius: 1, blurRadius: 5)
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 0.h),
              child: Column(
                children: [
                  Image.asset(
                    "assets/images/warning.webp",
                    width: 75.w,
                    height: 75.h,
                  ),
                  SizedBox(
                    height: 0.h,
                  ),
                  Text(text ?? "Something went wrong. Please try again.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ))
                ],
              ),
            ),
          ),
        );
      });
}
