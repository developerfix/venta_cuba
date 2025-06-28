import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/util/profile_list.dart';
import 'package:venta_cuba/view/constants/Colors.dart';
import 'package:venta_cuba/view/profile/request_account_deletion.dart';

import '../../Controllers/auth_controller.dart';
import '../auth/vendor_screen.dart';

class ManageAccount extends StatefulWidget {
  const ManageAccount({super.key});

  @override
  State<ManageAccount> createState() => _ManageAccountState();
}

class _ManageAccountState extends State<ManageAccount> {
  void _showAlertDialog(BuildContext context) {
    // Create an AlertDialog
    AlertDialog alert = AlertDialog(
        content: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(
            Icons.close_rounded,
            size: 15,
            color: AppColors.k0xFF9F9F9F,
          ),
        ),
        SizedBox(
          height: 10..h,
        ),
        SelectionArea(
          child: Text(
            authCont.user?.businessName == ""
                ? 'Want to Switch to Business Account'.tr
                : authCont.isBusinessAccount
                    ? 'Want to Switch to Personal Account'.tr
                    : 'Want to Switch to Business Account'.tr,
            style: TextStyle(
                fontSize: 18..sp,
                fontWeight: FontWeight.w600,
                color: AppColors.black),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          height: 15..h,
        ),
        Text(
          'Your account is switch to other one'.tr,
          style: TextStyle(
              fontSize: 14..sp,
              fontWeight: FontWeight.w400,
              color: AppColors.k0xFF9F9F9F),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 30..h,
        ),
        Container(
          height: 40..h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  height: 40..h,
                  width: MediaQuery.of(context).size.width * .3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.k0xFF0254B8,
                  ),
                  child: Center(
                    child: Text(
                      'Cancel'.tr,
                      style: TextStyle(
                          fontSize: 14..sp,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onPrimary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  if (authCont.user?.businessName == "") {
                    Navigator.of(context).pop();
                    Get.to(VendorScreen());
                  } else {
                    authCont.isBusinessAccount = !authCont.isBusinessAccount;
                    authCont.update();
                    authCont.changeAccountType();
                    Get.close(2);
                  }
                },
                child: Container(
                  height: 40..h,
                  width: MediaQuery.of(context).size.width * .3,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.k0xFF0254B8)),
                  child: Center(
                    child: Text(
                      'Yes Switch'.tr,
                      style: TextStyle(
                          fontSize: 14..sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.k0xFF0254B8),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    ));

    // Show the AlertDialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: alert);
      },
    );
  }

  final authCont = Get.put(AuthController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
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
                    'Manage Account'.tr,
                    style: TextStyle(
                        fontSize: 21..sp,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.titleLarge?.color),
                  ),
                  Container(
                    height: 24..h,
                    width: 24..w,
                    color: Colors.transparent,
                  )
                ],
              ),
              SizedBox(height: 40..h),
              GetBuilder<AuthController>(
                builder: (cont) {
                  return Column(
                    children: [
                      GestureDetector(
                          onTap: () {
                            _showAlertDialog(context);
                          },
                          child: ProfileList(
                              text: cont.user?.businessName == ""
                                  ? 'Switch to Business Account'.tr
                                  : cont.isBusinessAccount
                                      ? 'Switch to Personal Account'.tr
                                      : 'Switch to Business Account'.tr)),
                      SizedBox(height: 15..h),
                    ],
                  );
                },
              ),
              GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccountDeletion(),
                        ));
                  },
                  child: ProfileList(text: 'Request Account Deletion'.tr))
            ],
          ),
        ),
      ),
    );
  }
}
