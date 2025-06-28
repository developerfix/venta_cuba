import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/view/Chat/custom_text.dart';

import '../../Controllers/auth_controller.dart';
import '../../Utils/funcations.dart';
import '../../util/my_button.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: GetBuilder(
            init: AuthController(),
            builder: (con) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0..w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 70..h),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Icon(Icons.arrow_back_ios),
                      ),
                      SizedBox(height: 30..h),
                      // Center(child: Image.asset("assets/images/f.png", height: 150, width: 150)),
                      SizedBox(height: 30..h),
                      CustomText(
                        text: "Forgot Password".tr,
                        fontSize: 25..sp,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 20..h),
                      CustomText(
                          text:
                              "Please enter your email address below and we will send you an email to change your password."
                                  .tr),
                      SizedBox(height: 40..h),
                      Container(
                        height: 60..h,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: TextField(
                            controller: con.forgetPasswordCont,
                            textAlignVertical: TextAlignVertical.center,
                            cursorColor:
                                Theme.of(context).textTheme.bodyLarge?.color ??
                                    Colors.black,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                              prefixIcon: Icon(
                                Icons.email,
                                color: Color(0xFFA9ABAC),
                              ),
                              hintText: 'Enter your Email'.tr,
                              hintStyle: TextStyle(color: Color(0xFFA9ABAC)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 280.h,
                      ),
                      GestureDetector(
                          onTap: () async {
                            loading = true;
                            setState(() {});
                            if (loading) {
                              showLoading();
                            }
                            await con.forgetPassword();
                            loading = false;
                            setState(() {});
                            if (loading == false) {
                              Get.back();
                            }
                          },
                          child: MyButton(text: 'Send Email'.tr)),
                      SizedBox(height: 10..h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomText(text: "Remember it?   ".tr),
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: CustomText(
                                text: "Log in".tr, fontColor: Colors.green),
                          ),
                        ],
                      ),
                      SizedBox(height: 80..h),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}
