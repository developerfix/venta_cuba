import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:country_list_pick/support/code_country.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as Http;
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

import '../Models/user_data.dart';
import '../Utils/funcations.dart';
import '../api/api_checker.dart';
import '../api/api_client.dart';
import '../view/Navigation bar/navigation_bar.dart';
import '../view/auth/login.dart';
import 'package:http/http.dart' as http;
import '../view/Chat/Controller/SupabaseChatController.dart';
import 'home_controller.dart';
// Firebase removed for Cuba compatibility
// import '../Services/Firebase/firebase_messaging_service.dart';
import '../Services/RealPush/supabase_push_service.dart';
import '../Services/RealPush/real_push_service.dart';
import '../Services/RealPush/platform_push_service.dart';
// FCM notifications are now handled directly in SupabaseChatController
import '../Services/Supabase/rls_helper.dart';
import '../Services/Supabase/supabase_service.dart';
import '../config/app_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

String deviceToken = '';

class AuthController extends GetxController {
  int currentIndexBottomAppBar = 0;
  RxBool hasUnreadMessages = false.obs;
  RxInt unreadMessageCount = 0.obs;
  RxBool isLoading = false.obs; // Add loading state for login button
  bool _savingDeviceToken =
      false; // Flag to prevent concurrent device token saves
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

  // Firebase removed for Cuba compatibility
  // final FirebaseMessagingService _firebaseMessagingService = FirebaseMessagingService();

  @override
  Future<void> onInit() async {
    super.onInit();
    emailCreateCont.clear();
    passCreateCont.clear();
    firstNameCont.clear();
    lastNameCont.clear();
    emailCont.clear();
    prefs = await SharedPreferences.getInstance();

    // Initialize tokenMain early to prevent null token issues
    tokenMain = prefs.getString('token');
    token = prefs.getString('token');
    print(
        '🔥 AuthController onInit: tokenMain initialized as: ${tokenMain ?? "NULL"}');

    // Update API client headers with the token if available
    if (tokenMain != null) {
      api.updateHeader(tokenMain!);
    }

    // Initialize unread message count
    unreadMessageCount.value = 0;
    hasUnreadMessages.value = false;
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

  // Method to manually refresh unread message count
  Future<void> refreshUnreadMessageCount() async {
    try {
      final chatCont = Get.find<SupabaseChatController>();
      await chatCont.updateUnreadMessageIndicators();
      print(
          '🔥 ✅ Manually refreshed unread message count: ${unreadMessageCount.value}');
    } catch (e) {
      print('🔥 ❌ Error refreshing unread message count: $e');
    }
  }

  final TwilioFlutter twilioFlutter = TwilioFlutter(
      accountSid:
          'AC31dcb3275f70cc16fc18c150bbf8a2f8', // replace with Account SID
      authToken: '8fbefb5674cd3aec7af1d13edf5acb0c', // replace with Auth Token
      twilioNumber:
          '+14349938118' // replace with Twilio Number(With country code)
      );

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
          'POST', Uri.parse('https://ventacuba.co/api/verify'));
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

  Future getuserDetail() async {
    try {
      print('🔥 AuthController: Getting user details...');

      final SharedPreferences prefss = await SharedPreferences.getInstance();
      tokenMain = prefss.getString('token');
      token = prefss.getString('token');

      print('🔥 AuthController: Token retrieved: ${token ?? "NULL"}');
      print('🔥 AuthController: tokenMain set to: ${tokenMain ?? "NULL"}');

      api.updateHeader(token ?? "");

      String? userDataString = prefss.getString("user_data");
      if (userDataString == null) {
        print('🔥 AuthController: No user data found in preferences');
        throw Exception('No user data found');
      }

      print('🔥 AuthController: User data found, parsing...');
      Map<String, dynamic> userData = jsonDecode(userDataString);
      print('🔥 AuthController: User data parsed successfully');

      user = UserData.fromJson(userData);
      print(
          '🔥 AuthController: User object created: ${user?.firstName} ${user?.lastName}');

      // Sync device token with current Firebase FCM token
      // Firebase removed for Cuba compatibility
      // final fcmToken = await _firebaseMessagingService.getToken();
      final fcmToken = 'cuba-friendly-token';
      if (fcmToken != null && user != null && user!.deviceToken != fcmToken) {
        user!.deviceToken = fcmToken;
        await prefss.setString("user_data", jsonEncode(user!.toJson()));
        print('🔥 AuthController: Device token synced with Firebase');
      }

      // Set user as online when they log in (with timeout to prevent hanging)
      if (user?.userId != null) {
        try {
          print('🔥 AuthController: Setting user online...');
          final chatCont = Get.put(SupabaseChatController());

          // Add timeout to prevent hanging
          await chatCont.setUserOnline(user!.userId.toString()).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print(
                  '🔥 AuthController: setUserOnline timed out, continuing...');
            },
          );

          // Set RLS user context for secure Supabase access
          await RLSHelper.setUserContext(user!.userId.toString());
          print(
              '🔥 AuthController: RLS user context set for user: ${user!.userId}');

          // Initialize Supabase Push Service for this user
          await SupabasePushService.initialize(user!.userId.toString());
          print(
              '🔥 AuthController: Supabase Push Service initialized for user: ${user!.userId}');

          // Save device token to Supabase after user data is loaded
          try {
            if (user?.userId != null) {
              await saveDeviceTokenWithPlatform(user!.userId.toString());
            }
            print('🔥 Device token association completed');
          } catch (e) {
            print('🔥 AuthController: Error with device token setup: $e');
          }
        } catch (e) {
          print('🔥 AuthController: Error setting user online: $e');
          // Don't let this block the login process
        }
      }

      print('🔥 AuthController: User initialization completed');

      // Start chat listener (with timeout and error handling)
      try {
        print('🔥 AuthController: Starting chat services...');
        final chatCont = Get.put(SupabaseChatController());
        chatCont.startListeningForChatUpdates();

        // Add timeout for unread message indicators
        await chatCont.updateUnreadMessageIndicators().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            print('🔥 AuthController: updateUnreadMessageIndicators timed out');
          },
        );
        print('🔥 AuthController: Chat services initialized');
      } catch (e) {
        print('🔥 AuthController: Error initializing chat services: $e');
        // Don't let this block the login process
      }
    } catch (e) {
      print('🔥 AuthController: Error in getuserDetail: $e');
      Get.offAll(() => const Login());
      rethrow; // Re-throw to let calling method handle the error
    }

    update();
  }

  Future checkUserLoggedIn() async {
    try {
      final SharedPreferences prefss = await SharedPreferences.getInstance();
      bool isLogin = (prefss.get("user_data") != null);

      if (isLogin) {
        // Navigate immediately, load user details in background
        Get.offAll(() => Navigation_Bar());

        // Load user details after navigation (non-blocking)
        getuserDetail().catchError((e) {
          print('Error loading user details: $e');
        });
      } else {
        Get.offAll(() => const Login());
      }
    } catch (e) {
      print('Error in checkUserLoggedIn: $e');
      Get.offAll(() => const Login());
    }
  }

  Future<void> signUp(String province, String city) async {
    try {
      // Get Firebase FCM token before signup
      await refreshDeviceToken();

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
        // Extract user ID from response and save device token to Supabase
        try {
          if (response.body != null && response.body['user_id'] != null) {
            String userId = response.body['user_id'].toString();
            await saveDeviceTokenWithPlatform(userId);
            print(
                '✅ Device token saved to Supabase during registration for user: $userId');
          } else {
            print(
                '⚠️ No user_id found in signup response, skipping Supabase token save');
          }
        } catch (e) {
          print('❌ Error saving device token to Supabase during signup: $e');
          // Don't block the signup process if Supabase fails
        }

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
    try {
      // Set loading state to true
      isLoading.value = true;
      update();
      
      // Get fresh device token before login
      await refreshDeviceToken();

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

        // Update tokenMain immediately after login
        tokenMain = response.body["access_token"];
        api.updateHeader(tokenMain ?? "");

        // Reset shuffle session for new login to ensure proper shuffling
        try {
          final homeController = Get.find<HomeController>();
          await homeController.resetShuffleSession();
        } catch (e) {
          // HomeController might not be initialized yet, that's ok
        }

        onLoginSuccess(response.body);
        return response.statusCode;
      } else if (response.statusCode! >= 400) {
        errorAlertToast('Your Email or Password is incorrect');
      } else if (response.statusCode == 500) {
        errorAlertToast('Your Email or Password is incorrect');
      } else {
        errorAlertToast('Something went wrong\nPlease try again!'.tr);
      }
      print(
          "........................................................${response.statusCode}");
    } catch (e) {
      print('🔥 Login error: $e');
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
    } finally {
      // Always set loading state to false when done
      isLoading.value = false;
      update();
    }
  }

  Future<void> refreshDeviceToken() async {
    try {
      String? fcmToken;

      if (Platform.isIOS) {
        // Get real FCM token for iOS
        fcmToken = await PlatformPushService.getFCMToken();
        if (fcmToken == null) {
          // Try to get token directly from Firebase
          try {
            fcmToken = await FirebaseMessaging.instance.getToken();
          } catch (e) {
            print('Error getting FCM token directly: $e');
          }
        }
        print(
            'Refreshed device token (iOS FCM Token): ${fcmToken?.substring(0, 20)}...');

        // Store FCM token in Supabase for iOS
        if (fcmToken != null && user?.userId != null) {
          try {
            final supabaseService = SupabaseService.instance;
            await supabaseService.associateTokenWithUser(
                user!.userId.toString(), fcmToken,
                platform: 'ios');
            print('✅ FCM token stored in Supabase for iOS user');
          } catch (e) {
            print('❌ Error storing FCM token in Supabase: $e');
          }
        }
      } else {
        // Use cuba-friendly token for Android (ntfy.sh compatibility)
        fcmToken = 'cuba-friendly-token';
        print('Refreshed device token (Android Cuba Token): $fcmToken');

        // Store Android platform info in Supabase
        if (user?.userId != null) {
          try {
            final supabaseService = SupabaseService.instance;
            await supabaseService.associateTokenWithUser(
                user!.userId.toString(), fcmToken,
                platform: 'android');
            print('✅ Android platform info stored in Supabase');
          } catch (e) {
            print('❌ Error storing Android platform info: $e');
          }
        }
      }

      if (fcmToken != null) {
        deviceToken = fcmToken;
      }
    } catch (e) {
      print('Error refreshing device token: $e');
    }
  }

  /// Helper method to save device token with platform detection
  Future<void> saveDeviceTokenWithPlatform(String userId) async {
    // Prevent concurrent device token saves
    if (_savingDeviceToken) {
      print(
          'ℹ️ Device token save already in progress for user $userId, skipping');
      return;
    }

    _savingDeviceToken = true;

    try {
      if (deviceToken.isNotEmpty) {
        final supabaseService = SupabaseService.instance;
        String platform = Platform.isIOS ? 'ios' : 'android';

        // Use associateTokenWithUser which already handles upsert internally
        bool success = await supabaseService
            .associateTokenWithUser(userId, deviceToken, platform: platform);

        if (success) {
          print(
              '✅ Device token saved to Supabase for user $userId on $platform platform');
        } else {
          print('⚠️ Failed to save device token to Supabase for user $userId');
        }
      } else {
        print('⚠️ Device token is empty, cannot save to Supabase');
      }
    } catch (e) {
      // Handle duplicate key constraint error gracefully
      if (e
          .toString()
          .contains('duplicate key value violates unique constraint')) {
        print(
            'ℹ️ Device token already exists for user $userId - this is normal during login');
      } else {
        print('❌ Error saving device token to Supabase: $e');
      }
    } finally {
      _savingDeviceToken = false;
    }
  }

  Future forgetPassword() async {
    var prefs = await SharedPreferences.getInstance();
    String languageCode = prefs.getString('languageCode') ?? 'es';
    var headers = {'Accept': 'application/json'};
    var request = Http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://ventacuba.co/api/forget-password?lang=$languageCode'));
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
        headers: {
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': "*",
          'Authorization': 'Bearer ${user?.accessToken}'
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
      headers: {
        'Accept': 'application/json',
        'Access-Control-Allow-Origin': "*",
        'Authorization': 'Bearer ${user?.accessToken}'
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
        headers: {
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': "*",
          'Authorization': 'Bearer ${user?.accessToken}'
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
        headers: {
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': "*",
          'Authorization': 'Bearer ${user?.accessToken}'
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
        headers: {
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': "*",
          'Authorization': 'Bearer ${user?.accessToken}'
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

  Future<void> updateDeviceToken(String newToken) async {
    try {
      deviceToken = newToken;
      // Update the user data model with the new device token
      if (user != null) {
        user!.deviceToken = newToken;
        // Save updated user data to local storage
        await prefs.setString("user_data", jsonEncode(user!.toJson()));

        // Also update device token in all chat documents for this user
        await updateDeviceTokenInAllChats(newToken);

        // Update user presence as online when token is updated
        await setUserOnline();
      }
      print('🔥 Device token updated locally: $newToken');
    } catch (e) {
      print('🔥 Error updating device token: $e');
    }
  }

  // Set user as online
  Future<void> setUserOnline() async {
    try {
      if (user?.userId != null) {
        final chatController = Get.find<SupabaseChatController>();
        await chatController.setUserOnline(user!.userId.toString());
      }
    } catch (e) {
      print('🔥 Error setting user online: $e');
    }
  }

  // Set user as offline
  Future<void> setUserOffline() async {
    try {
      if (user?.userId != null) {
        final chatController = Get.find<SupabaseChatController>();
        await chatController.setUserOffline(user!.userId.toString());

        // Stop push notification service
        SupabasePushService.stopListening();
        print(
            '🔥 AuthController: Supabase Push service stopped for offline user');
      }
    } catch (e) {
      print('🔥 Error setting user offline: $e');
    }
  }

  // Update device token in all chat documents where this user participates
  Future<void> updateDeviceTokenInAllChats(String newToken) async {
    try {
      if (user?.userId == null) return;

      print('🔥 Updating device token in all chat documents...');

      final chatController = Get.find<SupabaseChatController>();
      final supabase = chatController.getSupabaseClient();
      String currentUserId = user!.userId.toString();

      // Get all chats where this user is either sender or recipient
      final chats = await supabase
          .from('chats')
          .select('id, sender_id, send_to_id')
          .or('sender_id.eq.$currentUserId,send_to_id.eq.$currentUserId');

      // Update device token in each chat
      for (var chat in chats) {
        await chatController.updateDeviceTokenInChat(
          chat['id'],
          currentUserId,
          newToken,
        );
      }

      print('🔥 ✅ Device token updated in ${chats.length} chat documents');
    } catch (e) {
      print('🔥 Error updating device token in chats: $e');
    }
  }

  // Get current device token for a specific user (for notifications)
  Future<String?> getCurrentDeviceTokenForUser(String userId) async {
    try {
      // If it's the current user, return their current device token
      if (user?.userId == userId) {
        return user?.deviceToken;
      }

      // For other users, you would typically call an API to get their current device token
      // Since we don't have that API, we'll return null and rely on the stored token
      print('🔥 Cannot get device token for user $userId - no API available');
      return null;
    } catch (e) {
      print('🔥 Error getting device token for user $userId: $e');
      return null;
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

    // Initialize services
    try {
      if (user?.userId != null) {
        final userId = user!.userId.toString();
        print('🚀 Initializing services for user: $userId');

        // Set RLS user context for secure Supabase access
        await RLSHelper.setUserContext(userId);
        print('✅ RLS user context set for secure chat access');

        // Initialize push notifications
        if (Platform.isIOS) {
          // Initialize FCM service and store token
          try {
            // FCM service will be initialized from UI with BuildContext
            // Token association will happen automatically in FCM.updateTokenOnServer
            print('🍎 FCM service ready for iOS');
          } catch (e) {
            print('❌ Error setting up FCM: $e');
          }
        } else {
          // Initialize Android push service
          await RealPushService.initialize(
            userId: userId,
            customServerUrl: AppConfig.ntfyServerUrl,
          );
          print('🤖 Android push service initialized');
        }

        print('✅ All services initialized successfully');
      }
    } catch (e) {
      print('❌ Error initializing services: $e');
      // Don't block login if services fail
    }

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
    try {
      // Set user as offline before logout
      await setUserOffline();

      // Stop chat listener before logout
      try {
        final chatCont = Get.find<SupabaseChatController>();
        chatCont.stopListeningForChatUpdates();
        print('🔥 ✅ Chat listener stopped on logout');
      } catch (e) {
        print('🔥 SupabaseChatController not found on logout: $e');
      }

      // Clear FCM token from Supabase for iOS
      if (Platform.isIOS &&
          deviceToken.isNotEmpty &&
          deviceToken != 'cuba-friendly-token') {
        try {
          final supabaseService = SupabaseService.instance;
          await supabaseService.removeDeviceToken(deviceToken);
          print('🍎 FCM token cleared from Supabase for iOS user');
        } catch (e) {
          print('❌ Error clearing FCM token from Supabase: $e');
        }
      }

      // Stop push service
      SupabasePushService.stopListening();
      print('🔥 AuthController: Push service stopped on logout');

      // Clear local device token
      deviceToken = "";

      Response response = await api.postWithForm(
        "api/logout",
        {},
      );

      // Always clear local data regardless of server response
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('token');
      prefs.remove('user_data');

      await prefs.remove('lastLat');
      await prefs.remove('lastLng');
      await prefs.remove('lastRadius');
      await prefs.remove('saveAddress');
      await prefs.remove('saveRadius');

      // Reset unread message count
      unreadMessageCount.value = 0;
      hasUnreadMessages.value = false;

      // Clear RLS user context for security
      try {
        await RLSHelper.clearUserContext();
        print('✅ RLS user context cleared on logout');
      } catch (e) {
        print('⚠️ Error clearing RLS context: $e');
      }

      // Navigate to login regardless of server response
      Get.offAll(() => const Login());

      if (response.statusCode != 200) {
        print(
            '🔥 Logout API failed but local data cleared: ${response.statusCode}');
      }
    } catch (e) {
      print('🔥 Error during logout: $e');
      // Even if there's an error, clear local data and navigate to login
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.remove('token');
        prefs.remove('user_data');

        // Reset unread message count
        unreadMessageCount.value = 0;
        hasUnreadMessages.value = false;

        // Clear RLS user context for security
        try {
          await RLSHelper.clearUserContext();
          print('✅ RLS user context cleared on logout (error path)');
        } catch (e) {
          print('⚠️ Error clearing RLS context (error path): $e');
        }

        Get.offAll(() => const Login());
      } catch (clearError) {
        print('🔥 Error clearing local data: $clearError');
        Get.offAll(() => const Login());
      }
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

      // Clear RLS user context for security
      try {
        await RLSHelper.clearUserContext();
        print('✅ RLS user context cleared on account deletion');
      } catch (e) {
        print('⚠️ Error clearing RLS context on deletion: $e');
      }

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

// Extension to add getSupabaseClient method to SupabaseChatController
extension SupabaseChatControllerExtension on SupabaseChatController {
  SupabaseClient getSupabaseClient() => Supabase.instance.client;
}
