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
  bool _rememberMe = false;
  SharedPreferences? _prefs;
  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  void _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = _prefs?.getBool('remember_me') ?? false;
    });
    if (_rememberMe) {
      final cont = Get.find<AuthController>();
      cont.emailCont.text = _prefs?.getString('saved_email') ?? "";
      cont.passCont.text = _prefs?.getString('saved_pass') ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: GetBuilder(
                init: AuthController(),
                builder: (cont) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: IntrinsicHeight(
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
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      child: Center(
                                        child: TextField(
                                          controller: cont.emailCont,
                                          textAlignVertical:
                                              TextAlignVertical.center,
                                          cursorColor: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color ??
                                              Colors.black,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.fromLTRB(
                                                0, 20, 0, 10),
                                            // focusedBorder: InputBorder.none,
                                            prefixIcon: Icon(
                                              Icons.mail_outline,
                                              color: Color(0xFFA9ABAC),
                                            ),
                                            hintText: 'Enter Email Address'.tr,
                                            hintStyle: TextStyle(
                                                color: Color(0xFFA9ABAC),
                                                fontWeight: FontWeight.w400),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              borderSide: BorderSide(
                                                  // color: AppColors.textFieldColor,
                                                  ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              borderSide: BorderSide(
                                                  // color: AppColors.red,
                                                  ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              borderSide: BorderSide(
                                                  // color: AppColors.red,
                                                  ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
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
                                          obscureText:
                                              !cont.isPasswordVisible.value,
                                          textAlignVertical:
                                              TextAlignVertical.center,
                                          cursorColor: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color ??
                                              Colors.black,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                cont.isPasswordVisible.value
                                                    ? Icons.visibility
                                                    : Icons.visibility_off,
                                              ),
                                              onPressed: () {
                                                cont.togglePasswordVisibility();
                                              },
                                            ),
                                            contentPadding: EdgeInsets.fromLTRB(
                                                0, 20, 0, 10),
                                            // focusedBorder: InputBorder.none,
                                            prefixIcon: Icon(
                                              Icons.lock,
                                              color: Color(0xFFA9ABAC),
                                            ),
                                            hintText: 'Enter your Password'.tr,
                                            hintStyle: TextStyle(
                                                color: Color(0xFFA9ABAC),
                                                fontWeight: FontWeight.w400),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              borderSide: BorderSide(
                                                  // color: AppColors.textFieldColor,
                                                  ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              borderSide: BorderSide(
                                                  // color: AppColors.red,
                                                  ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              borderSide: BorderSide(
                                                  // color: AppColors.red,
                                                  ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              borderSide: BorderSide(
                                                  // color: AppColors.textFieldColor,/
                                                  ),
                                            ),
                                          ),
                                        ),
                                      )),
                                    ),
                                    SizedBox(height: 10..h),
                                    Row(
                                      // mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Transform.scale(
                                          scale: 0.85, // Adjust size if needed
                                          child: Checkbox(
                                            value: _rememberMe,
                                            activeColor: AppColors.k0xFF0254B8,
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            visualDensity:
                                                VisualDensity.compact,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                _rememberMe = value!;
                                              });
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                            width:
                                                4), // optional spacing between box and text
                                        CustomText(
                                          text: 'Remember Me'.tr,
                                          fontSize: 15,
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 20..h),

                                    Obx(() => GestureDetector(
                                        onTap: cont.isLoading.value
                                            ? null
                                            : () async {
                                                if (cont.emailCont.text
                                                        .isEmpty ||
                                                    !GetUtils.isEmail(
                                                        cont.emailCont.text)) {
                                                  errorAlertToast(
                                                      "Please Enter Correct Email"
                                                          .tr);
                                                } else if (cont.passCont.text
                                                        .isEmpty ||
                                                    cont.passCont.text.length <
                                                        8) {
                                                  errorAlertToast(
                                                      "Please Enter Correct Password"
                                                          .tr);
                                                } else {
                                                  await cont.login();
                                                  SharedPreferences shared =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  shared.setString(
                                                      "save_password",
                                                      cont.passCont.text);
                                                }
                                                if (_rememberMe) {
                                                  await _prefs?.setBool(
                                                      'remember_me', true);
                                                  await _prefs?.setString(
                                                      'saved_email',
                                                      cont.emailCont.text);
                                                  await _prefs?.setString(
                                                      'saved_pass',
                                                      cont.passCont.text);
                                                } else {
                                                  await _prefs?.setBool(
                                                      'remember_me', false);
                                                  await _prefs
                                                      ?.remove('saved_email');
                                                  await _prefs
                                                      ?.remove('saved_pass');
                                                }
                                              },
                                        child: Container(
                                          height: 50..h,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            color: cont.isLoading.value
                                                ? AppColors.k0xFF0254B8
                                                    .withOpacity(0.7)
                                                : AppColors.k0xFF0254B8,
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                          child: Center(
                                            child: cont.isLoading.value
                                                ? SizedBox(
                                                    height: 25,
                                                    width: 25,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2.5,
                                                    ),
                                                  )
                                                : Text(
                                                    'Sign in'.tr,
                                                    style: TextStyle(
                                                        fontSize: 17..sp,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.white),
                                                  ),
                                          ),
                                        ))),
                                    SizedBox(height: 15..h),

                                    GestureDetector(
                                      onTap: () {
                                        cont.forgetPasswordCont.clear();
                                        Get.to(() => ForgetPasswordScreen());
                                      },
                                      child: CustomText(
                                        text: 'Forget Password?'.tr,
                                        fontSize: 16,
                                        fontColor: Color(0xFF0254B8),
                                      ),
                                    ),
                                    // MyButton(text: )),
                                    SizedBox(height: 60..h),
                                    Spacer(),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const SignUp(),
                                            ));
                                      },
                                      child: Container(
                                        height: 50..h,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            border: Border.all(
                                                color: AppColors.k0xFF0254B8)),
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
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
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
                                              fontSize: 17..sp,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.k0xFF0254B8),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20..h),
                                  ],
                                ),
                              )));
                    },
                  );
                })));
  }
}
