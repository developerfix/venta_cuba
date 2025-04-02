import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/Utils/funcations.dart';
import 'package:venta_cuba/view/Chat/custom_text.dart';
import 'package:venta_cuba/view/auth/sign_up.dart';

import '../constants/Colors.dart';
import 'forget_password_screen.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
 
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          backgroundColor: Colors.white,
          body: GetBuilder(
            init: AuthController(),
            builder: (cont) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  height: height,
                  child: Column(
                    children: [
                      SizedBox(height: 100..h),
                      // Text(
                      //   'First of all, enter your credentials to sign in'.tr,
                      //   style: TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
                      // ),
                      Image.asset(
                        "assets/images/watermark.png",
                        height: 130,
                        width: 130,
                      ),
                      SizedBox(height: 30..h),
                      // ClipRRect(
                      //   borderRadius: BorderRadius.circular(10),
                      //   child: Image.asset(
                      //     "assets/images/1024.png",
                      //     height: 90,
                      //     width: 90,
                      //   ),
                      // ),
                      Container(
                        height: 60..h,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10))),
                        child: Center(
                          child: TextField(
                            controller: cont.emailCont,
                            textAlignVertical: TextAlignVertical.center,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                              // focusedBorder: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.mail_outline,
                                color: Color(0xFFA9ABAC),
                              ),
                              hintText: 'Enter Email Address'.tr,
                              hintStyle: TextStyle(color: Color(0xFFA9ABAC), fontWeight: FontWeight.w400),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                    // color: AppColors.textFieldColor,
                                    ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                    // color: AppColors.red,
                                    ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                    // color: AppColors.red,
                                    ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                    // color: AppColors.textFieldColor,/
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15..h),
                      Container(
                        height: 60..h,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                            child: Obx(
                          () => TextField(
                            controller: cont.passCont,
                            obscureText: !cont.isPasswordVisible.value,
                            textAlignVertical: TextAlignVertical.center,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  cont.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  cont.togglePasswordVisibility();
                                },
                              ),
                              contentPadding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                              // focusedBorder: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Color(0xFFA9ABAC),
                              ),
                              hintText: 'Enter your Password'.tr,
                              hintStyle: TextStyle(color: Color(0xFFA9ABAC), fontWeight: FontWeight.w400),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                    // color: AppColors.textFieldColor,
                                    ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                    // color: AppColors.red,
                                    ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                    // color: AppColors.red,
                                    ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                    // color: AppColors.textFieldColor,/
                                    ),
                              ),
                            ),
                          ),
                        )),
                      ),
                      SizedBox(height: 15..h),
                      GestureDetector(
                          onTap: () async {
                            if (cont.emailCont.text.isEmpty || !GetUtils.isEmail(cont.emailCont.text)) {
                              errorAlertToast("Please Enter Correct Email".tr);
                            } else if (cont.passCont.text.isEmpty || cont.passCont.text.length < 8) {
                              errorAlertToast("Please Enter Correct Password".tr);
                            } else {
                              await cont.login();
                              SharedPreferences shared = await SharedPreferences.getInstance();
                              shared.setString("save_password", cont.passCont.text);
                            }
                          },
                          child: Container(
                            height: 50..h,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: AppColors.k0xFF0254B8,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Center(
                              child: Text(
                                'Sign in'.tr,
                                style: TextStyle(
                                    fontSize: 17..sp, fontWeight: FontWeight.w400, color: Colors.white),
                              ),
                            ),
                          )),
                      SizedBox(height: 15..h),

                      GestureDetector(
                        onTap: () {
                          cont.forgetPasswordCont.clear();
                          Get.to(ForgetPasswordScreen());
                        },
                        child: CustomText(
                          text: 'Forget Password?'.tr,
                          fontSize: 16,
                          fontColor: Color(0xFF0254B8),
                        ),
                      ),
                      // MyButton(text: )),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUp(),
                              ));
                        },
                        child: Container(
                          height: 50..h,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: AppColors.k0xFF0254B8)),
                          child: Center(
                            child: Text(
                              'Create an account'.tr,
                              style: TextStyle(
                                  fontSize: 17..sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.k0xFF0254B8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20..h),
                      GestureDetector(
                        onTap: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.setString("token", "");
                          cont.onLoginSuccess({
                            "status": true,
                            "access_token": "",
                            "token_type": "",
                            "user_id": null,
                            "first_name": "",
                            "last_name": "",
                            "phone_no": "",
                            "email": "",
                            "profile_image": "",
                            "role": "",
                            "device_token": "",
                            "business_logo": "",
                            "business_name": "",
                            "business_address": "",
                            "business_province": "",
                            "business_city": "",
                            "instagram_link": "",
                            "facebook_link": "",
                            "pinterest_link": "",
                            "twitter_link": "",
                            "linkedin_link": "",
                            "average_rating": "0",
                            "created_at": ""
                          });
                        },
                        child: Center(
                          child: Text(
                            'Skip'.tr,
                            style: TextStyle(
                                fontSize: 17..sp, fontWeight: FontWeight.w400, color: AppColors.k0xFF0254B8),
                          ),
                        ),
                      ),
                      SizedBox(height: 20..h),
                    ],
                  ),
                ),
              );
            },
          )),
    );
  }
}
