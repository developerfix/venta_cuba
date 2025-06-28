import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:venta_cuba/util/my_button.dart';
import 'package:venta_cuba/view/Chat/custom_text.dart';
import 'package:venta_cuba/view/auth/login.dart';
import 'package:venta_cuba/view/constants/Colors.dart';
import '../../Controllers/auth_controller.dart';
import '../../Utils/funcations.dart';
import '../privacy_policy/privacy_policy_screen.dart';

class AccountDeletion extends StatefulWidget {
  const AccountDeletion({super.key});

  @override
  State<AccountDeletion> createState() => _AccountDeletionState();
}

class _AccountDeletionState extends State<AccountDeletion> {
  final authCont = Get.put(AuthController());
  int? selectedValue;
  bool isOther = false;
  String resonText = '';
  static final formKey = GlobalKey<FormState>();
  void _showAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
        content: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              Navigator.of(context).pop();
              toggleView(false);
            });
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
        Text(
          'Wants to Delete the Account?'.tr,
          style: TextStyle(
              fontSize: 18..sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge?.color),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 15..h,
        ),
        // Text(
        //   'Your account is unavailable to you'.tr,
        //   style: TextStyle(fontSize: 14..sp, fontWeight: FontWeight.w400, color: AppColors.k0xFF9F9F9F),
        //   textAlign: TextAlign.center,
        // ),
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
                  setState(() {
                    Navigator.of(context).pop();
                    toggleView(false);
                  });
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
                      'No'.tr,
                      style: TextStyle(
                          fontSize: 14..sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 5),
              GestureDetector(
                onTap: () {
                  _showBottomSheet(context);
                },
                child: Container(
                  height: 40..h,
                  width: MediaQuery.of(context).size.width * .3,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.k0xFF0254B8)),
                  child: Center(
                    child: Text(
                      'Yes'.tr,
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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: alert);
      },
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return GetBuilder<AuthController>(builder: (cont) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) => Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(height: 15),
                          Align(
                              alignment: Alignment.topRight,
                              child: GestureDetector(
                                  onTap: () => Get.back(),
                                  child: Icon(Icons.close))),
                          CustomText(
                            text: "Why do you want delete your account?".tr,
                            fontSize: 17..sp,
                            fontWeight: FontWeight.w700,
                          ),
                          CustomText(
                            text:
                                "Tell us what led you to want to delete your account"
                                    .tr,
                            fontSize: 12..sp,
                            fontColor: Colors.black54,
                          ),
                          ListTile(
                            onTap: () {
                              setState(() {
                                selectedValue = 1;
                              });
                            },
                            title: CustomText(
                              text: "Already have an account".tr,
                              fontSize: 16..sp,
                            ),
                            leading: Radio(
                              value: 1,
                              groupValue: selectedValue,
                              onChanged: (value) {
                                setState(() {
                                  selectedValue = value;
                                  resonText = 'Already have an accountv';
                                });
                              },
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              setState(() {
                                selectedValue = 2;
                              });
                            },
                            title: CustomText(
                              text:
                                  "I'm receiving too many emails From VentaCuba"
                                      .tr,
                              fontSize: 16..sp,
                            ),
                            leading: Radio(
                              value: 2,
                              groupValue: selectedValue,
                              onChanged: (value) {
                                setState(() {
                                  selectedValue = value;
                                  resonText =
                                      'Im receiving too many emails From VentaCuba';
                                });
                              },
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              setState(() {
                                selectedValue = 3;
                              });
                            },
                            title: CustomText(
                              text: "Subscription is too expensive".tr,
                              fontSize: 16..sp,
                            ),
                            leading: Radio(
                              value: 3,
                              groupValue: selectedValue,
                              onChanged: (value) {
                                setState(() {
                                  selectedValue = value;
                                  resonText = 'Subscription is too expensive';
                                });
                              },
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              setState(() {
                                selectedValue = 4;
                                isOther = true;
                              });
                              print(isOther);
                            },
                            title: CustomText(
                              text: "Other".tr,
                              fontSize: 16..sp,
                            ),
                            leading: Radio(
                              value: 4,
                              groupValue: selectedValue,
                              onChanged: (value) {
                                setState(() {
                                  selectedValue = value;
                                });
                              },
                            ),
                          ),
                          isOther == true || selectedValue == 4
                              ? Form(
                                  key: formKey,
                                  child: LayoutBuilder(builder:
                                      (BuildContext context,
                                          BoxConstraints constraints) {
                                    return Container(
                                      height: 60..h,
                                      width: MediaQuery.of(context).size.width,
                                      child: Center(
                                        child: TextFormField(
                                          onChanged: (value) {
                                            resonText =
                                                cont.deleteReson.text.trim();
                                            cont.update();
                                          },
                                          controller: cont.deleteReson,
                                          // controller: pc,
                                          // textAlignVertical: TextAlignVertical.center,
                                          cursorColor: Colors.black,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.fromLTRB(
                                                10, 20, 0, 10),
                                            // focusedBorder: InputBorder.none,
                                            hintText:
                                                'Please add your comment'.tr,
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
                                    );
                                  }),
                                )
                              : SizedBox(),
                          SizedBox(height: 10),
                          InkWell(
                            onTap: () {
                              if (selectedValue == null) {
                                errorAlertToast('Please select a reason'.tr);
                              } else {
                                log('data delete: $resonText');
                                authCont.deleteAccount(resonText);
                                errorAlertToast(
                                    'Account deleted successfully'.tr);
                                resonText = '';
                                Get.offAll(Login());
                              }
                            },
                            child: Container(
                              height: 50..h,
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: AppColors.k0xFF0254B8,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Center(
                                child: Text(
                                  'Continue deleting...'.tr,
                                  style: TextStyle(
                                      fontSize: 17..sp,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ));
        });
      },
    );
  }

  bool isListView = false;
  void toggleView(bool listView) {
    setState(() {
      isListView = listView;
    });
  }

  bool isPasswordVisible = false;

  TextEditingController? pc = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    isListView == true
                        ? setState(() {
                            isListView = false;
                          })
                        : Navigator.of(context).pop();
                  },
                  child: Icon(
                    Icons.close_rounded,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
                SizedBox(
                  height: 50..h,
                ),
                Row(
                  children: [
                    Container(
                      height: 20..h,
                      width: 20..w,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: AppColors.k0xFF0254B8),
                    ),
                    Container(
                      height: 6..h,
                      width: 50..w,
                      decoration: BoxDecoration(color: AppColors.k0xFF9F9F9F),
                    ),
                    Container(
                      height: 20..h,
                      width: 20..w,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isListView
                              ? AppColors.k0xFF0254B8
                              : AppColors.k0xFF9F9F9F),
                    ),
                  ],
                ),
                SizedBox(
                  height: 50..h,
                ),
                isListView
                    ? CustomText(
                        text: "Enter your password to submit this request".tr,
                        fontSize: 25..sp,
                        fontWeight: FontWeight.bold,
                      )
                    : Text(
                        'Are you sure you want to delete your account?'.tr,
                        style: TextStyle(
                            fontSize: 21..sp,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).textTheme.titleLarge?.color),
                      ),
                SizedBox(height: 25..h),
                isListView
                    // ? Container(
                    //     height: 60..h,
                    //     width: MediaQuery.of(context).size.width,
                    //     child: Center(
                    //       child: TextField(
                    //         controller: pc,
                    //         textAlignVertical: TextAlignVertical.center,
                    //         cursorColor: Colors.black,
                    //         decoration: InputDecoration(
                    //           border: InputBorder.none,
                    //           contentPadding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                    //           prefixIcon: Icon(
                    //             Icons.email,
                    //             color: Color(0xFFA9ABAC),
                    //           ),
                    //           hintText: 'Enter your Password'.tr,
                    //           hintStyle: TextStyle(color: Color(0xFFA9ABAC)),
                    //           focusedBorder: OutlineInputBorder(
                    //             borderRadius: BorderRadius.circular(10.0),
                    //             borderSide: BorderSide(),
                    //           ),
                    //           errorBorder: OutlineInputBorder(
                    //             borderRadius: BorderRadius.circular(10.0),
                    //             borderSide: BorderSide(),
                    //           ),
                    //           focusedErrorBorder: OutlineInputBorder(
                    //             borderRadius: BorderRadius.circular(10.0),
                    //             borderSide: BorderSide(),
                    //           ),
                    //           enabledBorder: OutlineInputBorder(
                    //             borderRadius: BorderRadius.circular(10.0),
                    //             borderSide: BorderSide(),
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   )
                    ? Container(
                        height: 60..h,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: TextField(
                            controller: pc,
                            obscureText: !isPasswordVisible,
                            textAlignVertical: TextAlignVertical.center,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  isPasswordVisible = !isPasswordVisible;
                                  setState(() {});
                                },
                              ),
                              contentPadding: EdgeInsets.fromLTRB(0, 20, 0, 10),
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
                      )
                    : Text(
                        'We are sorry to hear you want to leave us. Deleting your account will remove your profile,messages,ads and reviews form publicly accessible portions of VentaCuba. VentaCuba may retain any data that (i) it may be required to retain under application law or to preserve its right,(ii) may reasonably be required to deter and identify potential fraud,spam or suspicious behaviours,(iii) may reasonably be required to record your deletion or other requests.'
                            .tr,
                        style: TextStyle(
                            fontSize: 17..sp, fontWeight: FontWeight.w400),
                      ),
                SizedBox(height: 30),
                isListView
                    ? GestureDetector(
                        onTap: () async {
                          SharedPreferences shared =
                              await SharedPreferences.getInstance();
                          String? password = shared.getString("save_password");
                          print("pc.text.......${password}");
                          print("pc.text.......${pc?.text}");
                          pc!.text.isEmpty
                              ? errorAlertToast('Please enter your password'.tr)
                              : pc!.text != password
                                  ? errorAlertToast(
                                      'Please enter the correct password'.tr)
                                  : setState(() {
                                      _showAlertDialog(context);
                                    });
                        },
                        child: MyButton(text: 'Submit Request'.tr))
                    : Column(
                        children: [
                          GestureDetector(
                              onTap: () {
                                setState(() {
                                  toggleView(true);
                                });
                              },
                              child: MyButton(text: 'Confirm Deletion'.tr)),
                          SizedBox(height: 10),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyLarge,
                              children: [
                                TextSpan(
                                  text:
                                      "For more information, please refer to our "
                                          .tr,
                                ),
                                TextSpan(
                                  text: "privacy policy".tr,
                                  style: const TextStyle(
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Get.to(PrivacyPolicy());
                                    },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
