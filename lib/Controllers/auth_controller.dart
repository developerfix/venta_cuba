import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:country_list_pick/support/code_country.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as Http;
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

import '../Models/user_data.dart';
import '../Utils/funcations.dart';
import '../api/api_checker.dart';
import '../api/api_client.dart';
import '../view/Navigation bar/navigation_bar.dart';
import '../view/auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../view/auth/otp_verification2.dart';
import 'package:http/http.dart' as http;

String deviceToken = '';

class AuthController extends GetxController {
  int currentIndexBottomAppBar = 0;
  RxBool hasUnreadMessages = false.obs;
  late SharedPreferences prefs;
  TextEditingController firstNameCont = TextEditingController(text: "");
  TextEditingController lastNameCont = TextEditingController(text: "");
  // TextEditingController phoneCont = TextEditingController(text: "");
  TextEditingController emailCont = TextEditingController(text: "");
  TextEditingController emailCreateCont = TextEditingController(text: "");
  TextEditingController passCreateCont = TextEditingController(text: '');
  TextEditingController provinceCont = TextEditingController(text: "");
  TextEditingController cityCont = TextEditingController(text: "");
  TextEditingController passCont = TextEditingController(text: '');
  TextEditingController forgetPasswordCont = TextEditingController(text: '');
  TextEditingController otpCode = TextEditingController(text: '');
  TextEditingController confirmPassCont = TextEditingController(text: '');
  TextEditingController businessNameCont = TextEditingController(text: '');
  TextEditingController businessAddressCont = TextEditingController(text: '');
  TextEditingController businessCityCont = TextEditingController(text: '');
  TextEditingController businessProvinceCont = TextEditingController(text: '');
  TextEditingController deleteReson = TextEditingController(text: "");

//Social Media Links
  TextEditingController tiktokLinkCont = TextEditingController(text: '');
  TextEditingController youtubeLinkCont = TextEditingController(text: '');
  TextEditingController linkedinLinkCont = TextEditingController(text: '');
  TextEditingController twitterLinkCont = TextEditingController(text: '');
  TextEditingController pinterestLinkCont = TextEditingController(text: '');
  TextEditingController facebookLinkCont = TextEditingController(text: '');
  TextEditingController instagramLinkCont = TextEditingController(text: '');

  String? businessLogo;
  String? profileImage;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? token;
  String verificationId = '';
  CountryCode? countryCode;
  UserData? user;
  ApiClient api = ApiClient(appBaseUrl: baseUrl);
  ApiChecker apichecker = ApiChecker();
  int allNotification = 0;
  int bumpUpNotification = 0;
  int saveSearchNotification = 0;
  int messageNotification = 0;
  int marketingNotification = 0;
  int reviewsNotification = 0;
  final isPasswordVisible = false.obs;
  final isPasswordVisible1 = false.obs;
  final isPasswordVisible2 = false.obs;
  final isChecked = false.obs;
  final isChecked1 = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    emailCreateCont.clear();
    passCreateCont.clear();
    firstNameCont.clear();
    lastNameCont.clear();
    emailCont.clear();
    prefs = await SharedPreferences.getInstance();
  }

  void toggleCheckbox() {
    isChecked.value = !isChecked.value;
  }

  void toggleCheckbox1() {
    isChecked1.value = !isChecked1.value;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void togglePasswordVisibility1() {
    isPasswordVisible1.value = !isPasswordVisible1.value;
  }

  void togglePasswordVisibility2() {
    isPasswordVisible2.value = !isPasswordVisible2.value;
  }

  final TwilioFlutter twilioFlutter = TwilioFlutter(
      accountSid:
          'AC31dcb3275f70cc16fc18c150bbf8a2f8', // replace with Account SID
      authToken: '8fbefb5674cd3aec7af1d13edf5acb0c', // replace with Auth Token
      twilioNumber:
          '+14349938118' // replace with Twilio Number(With country code)
      );
  // final TwilioFlutter twilioFlutter = TwilioFlutter(
  //     accountSid: 'ACfd0eee698f4eafe2dccf34de565dff74', // replace with Account SID
  //     authToken: '2042b4d20e5c70fe137b121fc694f9d7', // replace with Auth Token
  //     twilioNumber: '+16505499819' // replace with Twilio Number(With country code)
  // );
  Future getSmsCode() async {
    final res = await SmartAuth()
        .getSmsCode(useUserConsentApi: true, senderPhoneNumber: 'Secure');
    if (res.succeed && res.codeFound) {
      otpCode.text = res.code!;
    }
  }

  closeSmartAuth() {
    SmartAuth().removeSmsListener();
  }

  String generateOtpCode() {
    Random random = Random();
    int otp = 100000 + random.nextInt(900000); // Ensures a 6-digit number
    return otp.toString();
  }

  String otpCodeSaved = "";
  Future<void> validateEmailAndProceed(String province, String city) async {
    try {
      showLoading();

      var headers = {'Accept': 'application/json'};
      var request = http.MultipartRequest(
          'POST', Uri.parse('https://ventacuba.ca/api/verify'));
      request.fields.addAll({
        'email': emailCreateCont.text.trim(),
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      Get.back(); // Hide loading in both cases

      if (response.statusCode == 200) {
        errorAlertToast(
            "Email address already exists!. Please enter another one.".tr);
      } else {
        print('response.statusCode: ${response.statusCode}');
        await signUp(province, city);
      }
    } catch (e) {
      Get.back();
      print("validateEmailAndProceed error: $e");
      errorAlertToast("Something went wrong while verifying email.");
    }
  }

  // Future<void> verifyPhoneNumber(String province, String city) async {
  //   print("${countryCode?.dialCode ?? "+53"}${phoneCont.text.trim()}");

  //   showLoading();

  //   var headers = {'Accept': 'application/json'};
  //   var request = http.MultipartRequest(
  //       'POST', Uri.parse('https://ventacuba.ca/api/verify'));
  //   request.fields.addAll({
  //     'email': emailCreateCont.text.trim(),
  //   });
  //   request.headers.addAll(headers);
  //   http.StreamedResponse response = await request.send();
  //   // Get.log(response.stream.)
  //   if (response.statusCode == 200) {
  //     Get.back();
  //     errorAlertToast(
  //         "Email address already exists!. Please enter another one.".tr);
  //   } else {
  //     var headers = {'Accept': 'application/json'};
  //     var request = http.MultipartRequest(
  //         'POST', Uri.parse('https://ventacuba.ca/api/verify'));
  //     request.fields.addAll({
  //       'phone': "${countryCode?.dialCode ?? "+53"}${phoneCont.text.trim()}",
  //     });
  //     request.headers.addAll(headers);
  //   final response = await request.send();
  //     if (response.statusCode == 200) {
  //       Get.back();
  //       errorAlertToast("phone exists".tr);
  //     } else {
  //       try {
  //         final signature = await SmartAuth().getAppSignature();
  //         debugPrint('App Signature: $signature');
  //         otpCodeSaved = generateOtpCode();
  //         final statusCode = await twilioFlutter.sendSMS(
  //             toNumber:
  //                 "${countryCode?.dialCode ?? "+53"}${phoneCont.text.trim()}",
  //             messageBody:
  //                 '${"Your VentaCuba Otp code is".tr} ${otpCodeSaved}');
  //         if (statusCode.responseCode == 201) {
  //           Get.back();
  //           Get.to(OTPScreen(
  //             province: province,
  //             city: city,
  //           ));
  //         } else {
  //           errorAlertToast('Something went wrong\nPlease try again!'.tr);
  //           Get.back();
  //         }
  //       } catch (e) {
  //         Get.back();
  //         showSnackBar(title: 'enter valid phone'.tr);
  //       }
  //     }
  //   }
  // }

  Future<void> verifyOTP(String province, String city) async {
    try {
      showLoading();
      await Future.delayed(Duration(seconds: 1));

      if (otpCode.text.toString() == otpCodeSaved) {
        Get.back();
        await signUp(province, city);
        showSnackBar(title: "verified successfully".tr);
      } else {
        Get.back();
        errorShowDialog(
            text:
                "The Phone number or \nentered otp is invalid. \nPlease try again."
                    .tr);
      }
    } catch (e) {
      Get.back();
      showSnackBar(title: e.toString());
    }
  }

  // Future<void> verifyPhoneNumber(String province, String city) async {
  //   print("${countryCode?.dialCode ?? "+53"}${phoneCont.text.trim()}");
  //
  //   showLoading();
  //
  //   var headers = {
  //     'Accept': 'application/json'
  //   };
  //   var request = http.MultipartRequest('POST', Uri.parse('https://ventacuba.ca/api/verify'));
  //   request.fields.addAll({
  //     'email': emailCont.text.trim(),
  //   });
  //   request.headers.addAll(headers);
  //   http.StreamedResponse response = await request.send();
  //   if (response.statusCode == 200) {
  //     Get.back();
  //     errorAlertToast(
  //         "Email address already exists!. Please enter another one.");
  //   }
  //   else {
  //     var headers = {
  //       'Accept': 'application/json'
  //     };
  //     var request = http.MultipartRequest('POST', Uri.parse('https://ventacuba.ca/api/verify'));
  //     request.fields.addAll({
  //       'phone':"${countryCode?.dialCode ?? "+53"}${phoneCont.text.trim()}",
  //     });
  //     request.headers.addAll(headers);
  //     http.StreamedResponse response = await request.send();
  //     if (response.statusCode == 200) {
  //       Get.back();
  //       errorAlertToast(
  //           "Phone address already exists!. Please enter another one.");
  //     }
  //     else {
  //       await _auth.setSettings(
  //           appVerificationDisabledForTesting: false,
  //           forceRecaptchaFlow: false,
  //           phoneNumber:
  //           "${countryCode?.dialCode ?? "+53"}${phoneCont.text.trim()}",
  //           smsCode: "112233");
  //       try {
  //         await _auth.verifyPhoneNumber(
  //             phoneNumber:
  //             "${countryCode?.dialCode ?? "+53"}${phoneCont.text.trim()}",
  //             timeout: const Duration(seconds: 59),
  //             verificationCompleted: (_) {},
  //             verificationFailed: (e) {
  //               Get.back();
  //               String errorMessage = 'Phone verification failed: ';
  //               switch (e.code) {
  //                 case 'invalid-phone-number':
  //                   errorMessage += 'The provided phone number is not valid.';
  //                   break;
  //                 case 'quota-exceeded':
  //                   errorMessage += 'SMS quota exceeded. Please try again later.';
  //                   break;
  //                 case 'user-disabled':
  //                   errorMessage += 'Your account has been disabled.';
  //                   break;
  //                 case 'user-not-found':
  //                   errorMessage +=
  //                   'This phone number is not associated with any account.';
  //                   break;
  //                 default:
  //                   errorMessage += 'An unknown error occurred: ${e.code}';
  //               }
  //               showSnackBar(title: errorMessage);
  //             },
  //             codeSent: (String verificationI, int? code) {
  //               Get.back();
  //               verificationId = verificationI;
  //               const timeout = Duration(minutes: 5);
  //
  //               Timer(timeout, () {
  //                 verificationId = '';
  //                 print('OTP expired.');
  //                 update();
  //               });
  //               Get.to(OTPScreen(
  //                 province: province,
  //                 city: city,
  //               ));
  //             },
  //             codeAutoRetrievalTimeout: (e) {});
  //       } catch (e) {
  //         Get.back();
  //         showSnackBar(title: 'An error occurred: $e');
  //       }
  //     }
  //   }
  // }
  //
  // Future<void> verifyOTP(String province, String city) async {
  //   try {
  //     showLoading();
  //     PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
  //       verificationId: verificationId,
  //       smsCode: otpCode.text,
  //     );
  //
  //     UserCredential userCredential =
  //         await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
  //     User? user = userCredential.user;
  //     if (user != null) {
  //       Get.back();
  //       signUp(province, city);
  //     } else {
  //       Get.back();
  //       errorShowDialog(
  //           text:
  //               "The Phone number or \nentered otp is invalid. \nPlease try again."
  //                   .tr);
  //     }
  //   } catch (e) {
  //     Get.back();
  //     //  errorShowDialog(text: "The Phone number or \nentered otp is invalid. \nPlease try again.".tr);
  //   }
  // }

  Future getuserDetail() async {
    final SharedPreferences prefss = await SharedPreferences.getInstance();
    tokenMain = prefss.getString('token');
    token = prefss.getString('token');
    api.updateHeader(token ?? "");
    print(jsonDecode(prefss.getString("user_data")!));
    try {
      user = UserData.fromJson(jsonDecode(prefss.getString("user_data")!));
    } catch (e) {
      Get.offAll(const Login());
      print(e);
    }
    update();
  }

  Future checkUserLoggedIn() async {
    final SharedPreferences prefss = await SharedPreferences.getInstance();
    bool isLogin = (prefss.get("user_data") == null ? false : true);
    if (isLogin) {
      await getuserDetail();
      Get.offAll(Navigation_Bar());
    } else {
      Get.offAll(Login());
    }
  }

  Future<void> signUp(String province, String city) async {
    try {
      Response response = await api.postData(
        "api/signUp",
        {
          'first_name': firstNameCont.text.trim(),
          'last_name': lastNameCont.text.trim(),
          'email': emailCreateCont.text.trim(),
          'city': city,
          'province': province,
          'password': passCreateCont.text.trim(),
          'password_confirmation': confirmPassCont.text.trim(),
          'device_token': deviceToken,
        },
      );

      print("signUp statusCode: ${response.statusCode}");

      if (response.statusCode == 200) {
        firstNameCont.clear();
        lastNameCont.clear();
        emailCreateCont.clear();
        passCreateCont.clear();
        confirmPassCont.clear();

        Get.offAll(const Login());
      } else {
        print("signUp error body: ${response.body}");
        errorAlertToast('Signup failed. Please check your info and try again!');
      }
    } catch (e) {
      print("signUp exception: $e");
      errorAlertToast("Something went wrong while signing up.");
    }
  }

  Future login() async {
    Response response = await api.postData(
      "api/login",
      {
        'email': emailCont.text.trim(),
        'password': passCont.text.trim(),
        'device_token': deviceToken
      },
    );
    if (response.statusCode == 200) {
      await prefs.setString("token", response.body["access_token"]);

      onLoginSuccess(response.body);
      return response.statusCode;
    } else if (response.statusCode! >= 400) {
      // errorAlertToast('Your Email or Password is incorrect');
    } else if (response.statusCode == 500) {
      // errorAlertToast('Your Email or Password is incorrect');
    } else {
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
    }
    print(
        "........................................................${response.statusCode}");
  }

  Future forgetPassword() async {
    var prefs = await SharedPreferences.getInstance();
    String languageCode = prefs.getString('languageCode') ?? 'es';
    var headers = {'Accept': 'application/json'};
    var request = Http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://ventacuba.ca/api/forget-password?lang=$languageCode'));
    request.fields.addAll({'email': forgetPasswordCont.text.trim()});
    request.headers.addAll(headers);
    Http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      errorAlertToast("Email send successfully".tr);
    } else if (response.statusCode == 500) {
      print(await response.stream.bytesToString());
      errorAlertToast("Unable to send password reset email".tr);
    } else {
      errorAlertToast("An account doesn't exist with that email address".tr);
      print(response.reasonPhrase);
    }
  }

  // Future forgetPassword() async {
  //   Response response = await api.postData(
  //     "api/forget-password",
  //     {'email': forgetPasswordCont.text.trim()},
  //   );
  //   if (response == null) {
  //     errorAlertToast('Check your internet connection.');
  //   } else if (response.statusCode == 200) {
  //     errorAlertToast('Password reset link sent to your email');
  //   } else if (response.statusCode! >= 400) {
  //     errorAlertToast('Your Email or Password is incorrect');
  //   } else if (response.statusCode == 500) {
  //     errorAlertToast('Unable to send password reset link');
  //   } else {
  //     errorAlertToast('Something went wrong\nPlease try again!');
  //   }
  // }

  Future addBusiness(String province, String city) async {
    List<String>? image = [];
    image.add(businessLogo ?? "");
    print(jsonEncode(image));

    Response response = await api.postWithForm(
        "api/addBusiness",
        {
          'payment_id': '1',
          'business_name': businessNameCont.text.trim(),
          'business_address': '', //businessAddressCont.text.trim(),
          'business_province': province, //businessProvinceCont.text.trim(),
          'business_city': city //businessCityCont.text.trim()
        },
        imageKey: "business_logo",
        image: image);
    if (response.statusCode == 200) {
      businessNameCont.clear();
      businessAddressCont.clear();
      businessLogo = null;
      onUpdateUserData(response.body);
      Get.offAll(Navigation_Bar());
    } else {
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
    }
  }

  Future changePassword() async {
    Response response = await api.postWithForm(
      "api/changePassword",
      {
        'password': confirmPassCont.text.trim(),
        'password_confirmation': confirmPassCont.text.trim()
      },
    );
    if (response.statusCode == 200) {
      confirmPassCont.clear();
      passCont.clear();
      Get.back();
      errorAlertToast('Password Changed Successfully'.tr);
    } else {
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
    }
  }

  Future updateBusiness() async {
    List<String>? image = [];
    image.add(businessLogo ?? "");
    print(jsonEncode(image));

    Response response = await api.postWithForm(
        "api/addBusiness",
        {
          'payment_id': '1',
          'business_name': businessNameCont.text.trim(),
        },
        imageKey: "business_logo",
        image: image);
    if (response.statusCode == 200) {
      onUpdateUserData(response.body);
      Get.back();
    } else {
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
    }
  }

  Future updateBusinessImage() async {
    List<String> image = [];
    profileImage != null ? image.add(profileImage!) : null;
    Response response = await api.postWithForm(
        "api/addBusiness",
        {
          'payment_id': '1',
        },
        showdialog: false,
        imageKey: 'business_logo',
        image: image);
    if (response.statusCode == 200) {
      print("JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ");
      onUpdateUserData(response.body);
      errorAlertToast('Image Update Successfully'.tr);
    } else {
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
    }
  }

  Future editProfile(bool isBack, {String? city, String? province}) async {
    List<String> image = [];
    profileImage != null ? image.add(profileImage!) : null;
    Response response = await api.postWithForm(
        "api/edit-profile",
        {
          'first_name': firstNameCont.text,
          'city': city ?? user?.city,
          'province': province ?? user?.province,
          'last_name': lastNameCont.text
        },
        showdialog: isBack,
        imageKey: 'profile_picture',
        image: image);
    if (response.statusCode == 200) {
      profileImage = null;
      firstNameCont.clear();
      lastNameCont.clear();
      onUpdateUserData(response.body);

      isBack ? Get.back() : update();
      isBack
          ? errorAlertToast('Changed Successfully'.tr)
          : errorAlertToast('Image Update Successfully'.tr);
    } else {
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
    }
  }

  Future saveNotificationSettings() async {
    Response response = await api.postWithForm(
      "api/save-notification-settings",
      {
        'all_notifications': allNotification,
        'bump_up_notification': bumpUpNotification,
        'save_search_notification': saveSearchNotification,
        'message_notification': marketingNotification,
        'marketing_notification': marketingNotification,
        'reviews_notification': reviewsNotification
      },
    );
    if (response.statusCode == 200) {
      onUpdateUserData(response.body);
      Get.back();
      errorAlertToast('Notification Setting Update Successfully'.tr);
    } else {
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
    }
  }

  Future saveSocialMediaLink() async {
    Response response = await api.postWithForm(
      "api/save-social-media-link",
      {
        'instagram_link': instagramLinkCont.text.trim(),
        'facebook_link': facebookLinkCont.text.trim(),
        'pinterest_link': pinterestLinkCont.text.trim(),
        'twitter_link': twitterLinkCont.text.trim(),
        'linkedin_link': linkedinLinkCont.text.trim(),
        'tiktok_link': tiktokLinkCont.text.trim(),
        'youtube_link': youtubeLinkCont.text.trim()
      },
    );
    if (response.statusCode == 200) {
      onUpdateUserData(response.body);
      Get.back();
      errorAlertToast('Media links Added successfully'.tr);
    } else {
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
    }
  }

  Future saveSocialMediaLinkBusiness() async {
    Response response = await api.postWithForm(
      "api/save-business-social-media-link",
      {
        'business_instagram_link': instagramLinkCont.text.trim(),
        'business_facebook_link': facebookLinkCont.text.trim(),
        'business_pinterest_link': pinterestLinkCont.text.trim(),
        'business_twitter_link': twitterLinkCont.text.trim(),
        'business_linkedin_link': linkedinLinkCont.text.trim(),
        'business_tiktok_link': tiktokLinkCont.text.trim(),
        'business_youtube_link': youtubeLinkCont.text.trim()
      },
    );
    if (response.statusCode == 200) {
      onUpdateUserData(response.body);
      Get.back();
      errorAlertToast('Media links Added successfully'.tr);
    } else {
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
    }
  }

  void onLoginSuccess(Map<String, dynamic> value) async {
    await prefs.setString("user_data", jsonEncode(value));
    isBusinessAccount = false;
    changeAccountType();
    fetchAccountType();
    await getuserDetail();
    update();
    Get.offAll(Navigation_Bar());
  }

  void userMainProfileData(Map<String, dynamic> value) {}
  void onUpdateUserData(Map<String, dynamic> value) async {
    print("???????????????????????????");
    value.addAll({"access_token": user?.accessToken});
    await prefs.setString("user_data", jsonEncode(value));
    await getuserDetail();
    update();
  }

  Future<void> logout() async {
    Response response = await api.postWithForm(
      "api/logout",
      {},
    );
    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('token');
      prefs.remove('user_data');

      await prefs.remove('lastLat');
      await prefs.remove('lastLng');
      await prefs.remove('lastRadius');
      await prefs.remove('saveAddress');
      await prefs.remove('saveRadius');
      Get.offAll(() => const Login());
    } else {
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
    }
  }

  Future<void> deleteAccount(String resonText) async {
    Response response = await api.postWithForm(
      "api/deleteAccount",
      {
        'delete_reason': resonText,
      },
    );
    if (response.statusCode == 200) {
      emailCont.clear();
      passCont.clear();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('token');
      prefs.remove('user_data');
      Get.offAll(() => const Login());
    } else {
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
    }
  }

  changeAccountType() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool("accountType", isBusinessAccount);
  }

  bool isBusinessAccount = false;

  fetchAccountType() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    isBusinessAccount = sharedPreferences.getBool("accountType") ?? false;
    update();
  }
}



// flutter: https://ventacuba.ca/api/login
// flutter: body : {"email":"test1@test.com","password":"Abc@1234","device_token":""}
// flutter: headers : {"Content-Type":"application/json; charset=UTF-8","Accept":"application/json","Access-Control-Allow-Origin":"*","Authorization":"Bearer null"}
// flutter: {status: true, access_token: 689|gKxwGGprSCALNnd0mjiLtJ6KQ4rSxfj2wBISkWoqcd456217, token_type: Bearer, user_id: 123, first_name: Test, last_name: One, phone_no: +923094354985, province: Camagüey, city: Jimaguayú, email: test1@test.com, profile_image: , role: Normal User, device_token: , business_logo: , business_name: , business_address: , business_province: , business_city: , instagram_link: , facebook_link: , pinterest_link: , twitter_link: , linkedin_link: , youtube_link: , tiktok_link: , business_instagram_link: , business_facebook_link: , business_pinterest_link: , business_twitter_link: , business_linkedin_link: , business_youtube_link: , business_tiktok_link: , average_rating: 0, all_notifications: 0, bump_up_notification: 1, save_search_notification: 1, message_notification: 1, marketing_notification: 1, reviews_notification: 1, created_at: 2024-12-23T11:03:12.000000Z}