import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/Utils/funcations.dart';
import 'package:venta_cuba/view/constants/Colors.dart';

class PersonalDetails extends StatefulWidget {
  const PersonalDetails({super.key});

  @override
  State<PersonalDetails> createState() => _PersonalDetailsState();
}

class _PersonalDetailsState extends State<PersonalDetails> {
  bool _obscurePassword = true;
  final authCont = Get.put(AuthController());

  @override
  void initState() {
    // TODO: implement initState
    authCont.firstNameCont.text = authCont.user?.firstName ?? "";
    authCont.lastNameCont.text = authCont.user?.lastName ?? "";
    authCont.businessNameCont.text = authCont.user?.businessName ?? "";
    super.initState();
  }

  String password = '';
  int strength = 0;

  bool hasUppercase = false;
  bool hasLowercase = false;
  bool hasDigits = false;
  bool hasSymbols = false;

  void checkPasswordStrength(String value) {
    hasUppercase = value.contains(RegExp(r'[A-Z]'));
    hasLowercase = value.contains(RegExp(r'[a-z]'));
    hasDigits = value.contains(RegExp(r'[0-9]'));
    hasSymbols = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    int newStrength = 0;
    if (hasUppercase) newStrength++;
    if (hasLowercase) newStrength++;
    if (hasDigits) newStrength++;
    if (hasSymbols) newStrength++;
    if (password.length >= 7) newStrength++;
    // value != null && value.isNotEmpty ? null : ""

    setState(() {
      password = value;
      strength = newStrength;
    });
  }

  Color getColor(int barIndex) {
    return barIndex < strength ? Colors.green : Colors.grey;
  }

  Widget _buildStrengthBar(int barIndex) {
    return Flexible(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 1),
        height: 3.0,
        color: getColor(barIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: GetBuilder<AuthController>(
          builder: (cont) {
            return SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                            'Personal Details'.tr,
                            style: TextStyle(
                                fontSize: 21..sp,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.color),
                          ),
                          Container(
                            height: 24..h,
                            width: 24..w,
                            color: Colors.transparent,
                          )
                        ],
                      ),
                      SizedBox(
                        height: 35..h,
                      ),
                      Text(
                        'This Information will be displayed on your public business profile page'
                            .tr,
                        style: TextStyle(
                            fontSize: 17..sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.k0xFF9F9F9F),
                      ),
                      SizedBox(
                        height: 30..h,
                      ),
                      Visibility(
                        visible: cont.isBusinessAccount,
                        child: TextField(
                          onChanged: (value) {
                            cont.update();
                          },
                          controller: cont.businessNameCont,
                          textAlignVertical: TextAlignVertical.center,
                          cursorColor:
                              Theme.of(context).textTheme.bodyLarge?.color,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 13, horizontal: 20),
                            label: Text('Business Name'.tr),
                            labelStyle: TextStyle(
                              color: AppColors.k0xFF9F9F9F,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              // Adjust the border radius as needed
                              borderSide: BorderSide(
                                color: AppColors.black.withOpacity(.2),
                                // Adjust the border color as needed
                                width: 1.0, // Adjust the border width as needed
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              // Adjust the border radius as needed
                              borderSide: BorderSide(
                                color: AppColors.black.withOpacity(.2),
                                // Adjust the border color as needed
                                width: 1.0, // Adjust the border width as needed
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: !cont.isBusinessAccount,
                        child: Column(
                          children: [
                            TextField(
                              onChanged: (value) {
                                cont.update();
                              },
                              controller: cont.firstNameCont,
                              textAlignVertical: TextAlignVertical.center,
                              cursorColor:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 13, horizontal: 20),
                                label: Text('First Name'.tr),
                                labelStyle: TextStyle(
                                  color: AppColors.k0xFF9F9F9F,
                                ),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  // Adjust the border radius as needed
                                  borderSide: BorderSide(
                                    color: AppColors.black.withOpacity(.2),
                                    // Adjust the border color as needed
                                    width:
                                        1.0, // Adjust the border width as needed
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  // Adjust the border radius as needed
                                  borderSide: BorderSide(
                                    color: AppColors.black.withOpacity(.2),
                                    // Adjust the border color as needed
                                    width:
                                        1.0, // Adjust the border width as needed
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 30..h,
                            ),
                            TextField(
                              onChanged: (value) {
                                cont.update();
                              },
                              controller: cont.lastNameCont,
                              textAlignVertical: TextAlignVertical.center,
                              cursorColor:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 13, horizontal: 20),
                                label: Text('Last Name'.tr),
                                labelStyle: TextStyle(
                                  color: AppColors.k0xFF9F9F9F,
                                ),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  // Adjust the border radius as needed
                                  borderSide: BorderSide(
                                    color: AppColors.black.withOpacity(.2),
                                    // Adjust the border color as needed
                                    width:
                                        1.0, // Adjust the border width as needed
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  // Adjust the border radius as needed
                                  borderSide: BorderSide(
                                    color: AppColors.black.withOpacity(.2),
                                    // Adjust the border color as needed
                                    width:
                                        1.0, // Adjust the border width as needed
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 45..h,
                      ),
                      InkWell(
                        onTap: () {
                          if (cont.isBusinessAccount) {
                            if (cont.businessNameCont.text.isEmpty) {
                              errorAlertToast("Please Enter Business Name".tr);
                            } else {
                              cont.updateBusiness();
                            }
                          } else {
                            if (cont.firstNameCont.text.isEmpty) {
                              errorAlertToast("Please Enter First Name".tr);
                            } else if (cont.lastNameCont.text.isEmpty) {
                              errorAlertToast("Please Enter Last Name".tr);
                            } else {
                              cont.editProfile(true);
                            }
                          }
                        },
                        child: Container(
                          height: 60..h,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: cont.firstNameCont.text.isNotEmpty &&
                                      cont.lastNameCont.text.isNotEmpty
                                  ? Color(0xFF0254B8)
                                  : AppColors.k0xFFA9ABAC,
                              borderRadius: BorderRadius.circular(10)),
                          child: Center(
                            child: Text(
                              'Save Changes'.tr,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 45..h,
                      ),
                      Text(
                        'Change Password'.tr,
                        style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w500,
                            color:
                                Theme.of(context).textTheme.titleLarge?.color),
                      ),
                      SizedBox(
                        height: 30..h,
                      ),
                      Container(
                        height: 50..h,
                        child: TextField(
                          onChanged: (value) {
                            cont.update();
                          },
                          controller: cont.passCont,
                          obscureText: _obscurePassword,
                          // This property hides or shows the password
                          decoration: InputDecoration(
                            hintText: "Current password".tr,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Theme.of(context).iconTheme.color,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword =
                                      !_obscurePassword; // Toggle the password visibility
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              // Adjust the border radius as needed
                              borderSide: BorderSide(
                                color: AppColors.black.withOpacity(.2),
                                // Adjust the border color as needed
                                width: 1.0, // Adjust the border width as needed
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              // Adjust the border radius as needed
                              borderSide: BorderSide(
                                color: AppColors.black.withOpacity(.2),
                                // Adjust the border color as needed
                                width: 1.0, // Adjust the border width as needed
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 13, horizontal: 20),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30..h,
                      ),
                      Container(
                        height: 50..h,
                        child: TextField(
                          controller: cont.confirmPassCont,
                          obscureText: _obscurePassword,
                          onChanged: (value) {
                            checkPasswordStrength(value);
                            cont.update();
                          },
                          // This property hides or shows the password
                          decoration: InputDecoration(
                            hintText: "New Password".tr,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Theme.of(context).iconTheme.color,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword =
                                      !_obscurePassword; // Toggle the password visibility
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              // Adjust the border radius as needed
                              borderSide: BorderSide(
                                color: AppColors.black.withOpacity(.2),
                                // Adjust the border color as needed
                                width: 1.0, // Adjust the border width as needed
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              // Adjust the border radius as needed
                              borderSide: BorderSide(
                                color: AppColors.black.withOpacity(.2),
                                // Adjust the border color as needed
                                width: 1.0, // Adjust the border width as needed
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 13, horizontal: 20),
                          ),
                        ),
                      ),
                      SizedBox(height: 5..h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStrengthBar(0),
                          _buildStrengthBar(1),
                          _buildStrengthBar(2),
                          _buildStrengthBar(3),
                          _buildStrengthBar(4),
                        ],
                      ),
                      SizedBox(height: 5..h),
                      Wrap(
                        spacing: 20,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 10..h,
                                width: 10..w,
                                decoration: BoxDecoration(
                                    color: password.length >= 8
                                        ? Colors.green
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                        width: 2,
                                        color: password.length >= 8
                                            ? Colors.green
                                            : Colors.grey)),
                              ),
                              SizedBox(width: 3),
                              Text(
                                "at least 8 characters".tr,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                          ValidationState(
                              value: hasDigits, text: "1 number".tr),
                          ValidationState(
                              value: hasUppercase, text: "1 uppercase".tr),
                          ValidationState(
                              value: hasLowercase, text: "1 lowercase".tr),
                          ValidationState(
                              value: hasSymbols, text: "1 symbol".tr),
                        ],
                      ),
                      SizedBox(
                        height: 45..h,
                      ),
                      InkWell(
                        onTap: () async {
                          SharedPreferences shared =
                              await SharedPreferences.getInstance();
                          String? password = shared.getString("save_password");
                          if (cont.passCont.text.isEmpty) {
                            errorAlertToast('Please enter your password'.tr);
                          } else if (cont.confirmPassCont.text.isEmpty) {
                            errorAlertToast('please enter new password'.tr);
                          } else if (cont.passCont.text != password) {
                            errorAlertToast(
                                'Please enter the correct password'.tr);
                          } else if (cont.confirmPassCont.length < 8 ||
                              hasSymbols == false ||
                              hasDigits == false ||
                              hasUppercase == false ||
                              hasLowercase == false) {
                            errorAlertToast(
                                "Please Enter a Strong Password".tr);
                          } else if (cont.passCont.text ==
                              cont.confirmPassCont.text) {
                            errorAlertToast('new pass cannot be same'.tr);
                          } else {
                            cont.changePassword();
                          }
                        },
                        child: Container(
                          height: 60..h,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: cont.passCont.length >= 8 &&
                                      cont.confirmPassCont.length >= 8
                                  ? Color(0xFF0254B8)
                                  : AppColors.k0xFFA9ABAC,
                              borderRadius: BorderRadius.circular(10)),
                          child: Center(
                            child: Text(
                              'Change Password'.tr,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ValidationState extends StatelessWidget {
  const ValidationState({
    super.key,
    required this.value,
    required this.text,
  });

  final bool value;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 10..h,
          width: 10..w,
          decoration: BoxDecoration(
              color: value ? Colors.green : Colors.transparent,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                  width: 2, color: value ? Colors.green : Colors.grey)),
        ),
        SizedBox(width: 3),
        Text(
          text.tr,
          style: TextStyle(
              fontSize: 12..sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey),
        ),
      ],
    );
  }
}
