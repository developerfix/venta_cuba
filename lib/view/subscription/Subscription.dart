import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/Controllers/home_controller.dart';
import 'package:venta_cuba/Utils/funcations.dart';
import 'package:venta_cuba/util/my_button.dart';
import 'package:venta_cuba/view/Chat/custom_text.dart';
import 'package:venta_cuba/view/Navigation%20bar/navigation_bar.dart';
import 'package:venta_cuba/view/constants/Colors.dart';
import '../payment/payment_next.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool fromCuba = true;
  final authCont = Get.find<AuthController>();
  final homeCon = Get.find<HomeController>();

  @override
  void initState() {
    homeCon.promoCode.clear();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          authCont.currentIndexBottomAppBar = 0;
          authCont.update();
          Get.offAll(Navigation_Bar());
        }
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: GetBuilder<HomeController>(
              builder: (cont) {
                return SelectionArea(
                  child: SafeArea(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 20..h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    authCont.currentIndexBottomAppBar = 0;
                                    authCont.update();

                                    Get.offAll(Navigation_Bar());

                                    // Get.back();
                                  },
                                  child: Icon(
                                    Icons.arrow_back_ios,
                                    size: 18,
                                  ),
                                ),
                                Text(
                                  'Subscription'.tr,
                                  style: TextStyle(
                                      fontSize: 20..sp,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color ??
                                          Colors.black),
                                ),
                                Container(
                                  width: 10..w,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10..h,
                            ),
                            Column(
                              children: [
                                Text(
                                  'Subscribe to our Monthly Subscription Plans and enjoy ton of benefits'
                                      .tr,
                                  style: TextStyle(
                                      fontSize: 16..sp,
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.color),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 20.h),
                                Container(
                                  width: 300,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: Theme.of(context).cardColor,
                                      border: Border.all(
                                        color: AppColors.k0xFF0254B8
                                            .withValues(alpha: 0.5),
                                      )),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          fromCuba = true;
                                          homeCon.promoCode.clear();
                                          cont.type = "Other";
                                          print(cont.type);
                                          setState(() {});
                                        },
                                        child: Container(
                                          width: 148,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color: fromCuba
                                                ? AppColors.k0xFF0254B8
                                                : Colors.grey.shade200,
                                          ),
                                          child: Center(
                                            child: CustomText(
                                              text: 'From Cuba'.tr,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              fontColor: fromCuba
                                                  ? Colors.white
                                                  : AppColors.k0xFF0254B8,
                                            ),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          homeCon.promoCode.clear();
                                          fromCuba = false;
                                          cont.type = "Stripe";
                                          cont.videoPath = "";
                                          print(cont.type);
                                          setState(() {});
                                        },
                                        child: Container(
                                          width: 148,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color: fromCuba == false
                                                ? AppColors.k0xFF0254B8
                                                : Colors.grey.shade200,
                                          ),
                                          child: Center(
                                            child: CustomText(
                                              text: 'Out of Cuba'.tr,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              fontColor: fromCuba == false
                                                  ? Colors.white
                                                  : AppColors.k0xFF0254B8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 50..h),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 17),
                                  // height: 500..h,
                                  width: 283..w,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: AppColors.k0xFF0254B8),
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(40),
                                        bottomLeft: Radius.circular(40)),
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 50.h,
                                      ),
                                      Text(
                                        textAlign: TextAlign.center,
                                        fromCuba
                                            ? 'For Cuban Citizen'.tr
                                            : "For Cubans Outside Cuba".tr,
                                        style: TextStyle(
                                            fontSize: 20..sp,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black),
                                      ),
                                      SizedBox(
                                        height: 14..h,
                                      ),
                                      SizedBox(
                                        height: 20..h,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            fromCuba
                                                ? '1'
                                                // ? '${cont.allPackagesModel?.data?.first.price}'
                                                : "${cont.allPackagesModel?.data?.last.price}",
                                            style: TextStyle(
                                                height: 1,
                                                fontSize: 30..sp,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.k0xFF403C3C),
                                          ),
                                          Text(
                                            fromCuba ? 'MLC'.tr : "USD",
                                            //fromCuba ? 'CUP'.tr : "USD",
                                            style: TextStyle(
                                              height: 1.2,
                                              fontSize: 13..sp,
                                              fontWeight: FontWeight.w400,
                                              // color: AppColors.k0xFF848484,
                                            ),
                                          ),
                                          Text(
                                            fromCuba
                                                ? '/2 Monthly'.tr
                                                : '/ Monthly'.tr,
                                            style: TextStyle(
                                              // height: 1.2,
                                              fontSize: 12..sp,
                                              fontWeight: FontWeight.w400,
                                              // color: AppColors.k0xFF848484,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 25..h,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          cont.packageData =
                                              cont.allPackagesModel?.data?[0];
                                          setState(() {});
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PaymentNext(
                                                  fromCuba: fromCuba,
                                                ),
                                              ));
                                        },
                                        child: Container(
                                          height: 32..h,
                                          width: 122..w,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color: AppColors.k0xFF0254B8),
                                          child: Center(
                                            child: Text(
                                              'SUBSCRIBE NOW'.tr,
                                              style: TextStyle(
                                                  fontSize: 11..sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20..h,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 14),
                                        child: Column(
                                          children: [
                                            Text(fromCuba
                                                ? "This subscription will grant you access to the app for 3 months.\n\nIf you received a promotional code from someone, you can enter it in the field below."
                                                    .tr
                                                : "This price plan is available for Cubans that live outside Cuba and  who want to have full access to the app.\n\nWith this plan, you also have the option to pay for friends and families residing in Cuba.\n\nAfter payment, you will receive a unique promotional code that they can enter on the app and that will grant them full access for 1 month."
                                                    .tr),
                                            SizedBox(height: 30),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: true,
                                  //visible:fromCuba,
                                  child: Column(
                                    children: [
                                      SizedBox(height: 20..h),
                                      CustomText(
                                        text:
                                            "Please enter your promotional code here if you have one."
                                                .tr,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      SizedBox(height: 10..h),
                                      Container(
                                        height: 50..h,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 2),
                                        decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Theme.of(context)
                                                      .shadowColor
                                                      .withValues(alpha: .25),
                                                  blurRadius: 2)
                                            ]),
                                        child: Center(
                                          child: TextField(
                                            controller: cont.promoCode,
                                            cursorColor: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.color,
                                            textAlignVertical:
                                                TextAlignVertical.top,
                                            decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 15),
                                                border: InputBorder.none,
                                                hintText: 'Promo Code'.tr),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 20..h),
                                      InkWell(
                                        onTap: () {
                                          cont.isEnterPromoCode = true;
                                          if (cont.promoCode.text.isNotEmpty) {
                                            cont.buyPackage();
                                          } else {
                                            errorAlertToast(
                                                "Please Enter Promo Code.".tr);
                                          }
                                        },
                                        child: MyButton(
                                          text: 'Submit'.tr,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 50..h,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            )),
      ),
    );
  }
}
