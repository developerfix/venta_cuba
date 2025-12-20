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
import '../Services/push_service.dart';
import '../Services/RealPush/android_background_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
// FCM notifications are now handled directly in SupabaseChatController
import '../Services/Supabase/rls_helper.dart';
import '../Services/Supabase/supabase_service.dart';

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

  // Initialize push notifications with permission handling
  Future<void> initializePushNotifications(String userId) async {
    try {
      // Ensure device token is properly set and saved before initializing push
      if (deviceToken.isEmpty || !deviceToken.contains(userId)) {
        await refreshDeviceToken();
        await saveDeviceTokenWithPlatform(userId);
      }

      // Request notification permissions first
      bool permissionsGranted = await requestNotificationPermissions();
      if (!permissionsGranted) {
        // Snackbar removed - let users decide if they want notifications
      }

      // Initialize enhanced push service (works for both Android and iOS)
      await PushService.initialize(
        userId: userId,
      );

      // On Android, also start the background service for persistent notifications
      if (Platform.isAndroid) {
        bool serviceStarted = await AndroidBackgroundService.startService(
          userId: userId,
          customServerUrl: null,
        );

        if (serviceStarted) {
        } else {}
      }
    } catch (e) {
      // Don't throw - allow app to continue without notifications
    }
  }

  // Request notification permissions with proper handling
  Future<bool> requestNotificationPermissions() async {
    try {
      // For Android 13+ (API 33+)
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          // Request POST_NOTIFICATIONS permission for Android 13+
          final status = await Permission.notification.request();

          if (status.isGranted) {
            return true;
          } else if (status.isPermanentlyDenied) {
            // Dialog removed - let users enable notifications on their own
            return false;
          } else {
            return false;
          }
        } else {
          // For Android < 13, notifications are allowed by default
          return true;
        }
      }

      // For iOS
      if (Platform.isIOS) {
        final status = await Permission.notification.request();

        if (status.isGranted) {
          return true;
        } else if (status.isPermanentlyDenied) {
          // Dialog removed - let users enable notifications on their own
          return false;
        } else {
          return false;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // Stop push notifications on logout
  Future<void> stopPushNotifications() async {
    try {
      // Stop Android background service
      if (Platform.isAndroid) {
        await AndroidBackgroundService.stopService();
      }

      // Stop push service
      await PushService.dispose();
    } catch (e) {}
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    emailCreateCont.clear();
    passCreateCont.clear();
    firstNameCont.clear();
    lastNameCont.clear();
    emailCont.clear();

    // Safe SharedPreferences initialization with retry logic
    await _initializeSharedPreferences();

    // Initialize tokenMain early to prevent null token issues
    tokenMain = prefs.getString('token');
    token = prefs.getString('token');

    // Update API client headers with the token if available
    if (tokenMain != null) {
      api.updateHeader(tokenMain!);
    }

    // Initialize unread message count
    unreadMessageCount.value = 0;
    hasUnreadMessages.value = false;
  }

  // Safe SharedPreferences initialization method
  Future<void> _initializeSharedPreferences() async {
    int retries = 3;
    while (retries > 0) {
      try {
        prefs = await SharedPreferences.getInstance().timeout(
          Duration(seconds: 10),
          onTimeout: () => throw TimeoutException(
              'SharedPreferences initialization timed out',
              Duration(seconds: 10)),
        );

        // Test the connection with a simple operation
        try {
          await prefs.getString('test');
        } catch (e) {
          // If getString fails, try a simple operation
          await prefs.setBool('init_test', true);
          await prefs.remove('init_test');
        }

        return;
      } catch (e) {
        retries--;
        if (retries > 0) {
          // Exponential backoff with longer delays
          await Future.delayed(Duration(milliseconds: 1000 * (4 - retries)));
        } else {
          throw Exception(
              'Failed to initialize SharedPreferences after 3 attempts: $e');
        }
      }
    }
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
    } catch (e) {}
  }

  // Test method to manually set unread count (for debugging)
  void setTestUnreadCount(int count) {
    unreadMessageCount.value = count;
    hasUnreadMessages.value = count > 0;
    update(); // Trigger UI update
  }

  // Force show badge for immediate testing
  void showBadgeNow() {
    unreadMessageCount.value = 5;
    hasUnreadMessages.value = true;
    update();
  }

  // Test push notification to yourself
  void testPushNotification() {
    try {
      PushService.sendTestNotification();
    } catch (e) {}
  }

  // Test badge functionality
  void testBadge({int count = 5}) {
    try {
      PushService.testBadge(count: count);
    } catch (e) {}
  }

  // Clear test notifications
  void clearTestNotifications() {
    try {
      PushService.clearTestNotifications();
    } catch (e) {}
  }

  // Force reset stuck badge (for Android debugging)
  void forceResetBadge() {
    try {
      PushService.forceResetBadge();
    } catch (e) {}
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
        // Email address already exists
      } else {
        await signUp(province, city);
      }
    } catch (e) {
      Get.back();
      // Something went wrong while verifying email
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
      final SharedPreferences prefss = await SharedPreferences.getInstance();
      tokenMain = prefss.getString('token');
      token = prefss.getString('token');

      api.updateHeader(token ?? "");

      String? userDataString = prefss.getString("user_data");
      if (userDataString == null) {
        throw Exception('No user data found');
      }

      Map<String, dynamic> userData = jsonDecode(userDataString);

      user = UserData.fromJson(userData);

      // Sync device token (no longer using Firebase for Cuba compatibility)
      // Generate a proper device token if not already set
      if (user != null) {
        final expectedToken = 'venta_cuba_user_${user!.userId}';
        if (user!.deviceToken != expectedToken) {
          user!.deviceToken = expectedToken;
          deviceToken = expectedToken; // Update global device token
          await prefss.setString("user_data", jsonEncode(user!.toJson()));

          // Save to Supabase if not already saved
          await saveDeviceTokenWithPlatform(user!.userId.toString());
        }
      }

      // Set user as online when they log in (with timeout to prevent hanging)
      if (user?.userId != null) {
        try {
          final chatCont = Get.put(SupabaseChatController());

          // Add timeout to prevent hanging
          await chatCont.setUserOnline(user!.userId.toString()).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              //
            },
          );
        } catch (e) {
          //
        }

        // Set RLS user context for secure Supabase access
        await RLSHelper.setUserContext(user!.userId.toString());

        // Initialize PREMIUM push notifications with enhanced service
        await PushService.initialize(
          userId: user!.userId.toString(),
        );
      }

      // Start chat listener (with timeout and error handling)
      try {
        // Safe get with fallback
        final chatCont = Get.isRegistered<SupabaseChatController>()
            ? Get.find<SupabaseChatController>()
            : Get.put(SupabaseChatController(), permanent: true);
        chatCont
            .startListeningForChatUpdates(); // Will skip if already initialized

        // Update unread message indicators with timeout
        try {
          await chatCont.updateUnreadMessageIndicators().timeout(
                const Duration(seconds: 5),
                onTimeout: () {},
              );
        } catch (e) {}
      } catch (e) {}
    } catch (e) {
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
        getuserDetail().then((_) async {
          // After user details are loaded, initialize notifications
          if (user?.userId != null) {
            // Refresh and save device token for returning users
            await refreshDeviceToken();
            await saveDeviceTokenWithPlatform(user!.userId.toString());

            await initializePushNotifications(user!.userId.toString());
          }
        }).catchError((e) {});
      } else {
        Get.offAll(() => const Login());
      }
    } catch (e) {
      Get.offAll(() => const Login());
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

      if (response.statusCode == 200) {
        // Extract user ID from response and save device token to Supabase
        try {
          if (response.body != null && response.body['user_id'] != null) {
            String userId = response.body['user_id'].toString();
            await saveDeviceTokenWithPlatform(userId);
          } else {}
        } catch (e) {
          // Don't block the signup process if Supabase fails
        }

        firstNameCont.clear();
        lastNameCont.clear();
        emailCreateCont.clear();
        passCreateCont.clear();
        confirmPassCont.clear();

        Get.offAll(const Login());
      } else {
        // Signup failed
      }
    } catch (e) {
      // Something went wrong while signing up
    }
  }

  Future login() async {
    try {
      // Set loading state to true
      isLoading.value = true;
      update();

      // Ensure SharedPreferences is initialized before using it
      try {
        // Test if prefs is initialized by attempting to access it
        prefs.getString('test');
      } catch (e) {
        try {
          await _initializeSharedPreferences();
        } catch (initError) {
          return;
        }
      }

      // Don't generate device token here - it will be done after login when we have user ID
      // Just use a placeholder for the API call
      if (deviceToken.isEmpty) {
        deviceToken = 'pending_token';
      }

      // Add timeout to API call to prevent hanging
      Response response = await api.postData(
        "api/login",
        {
          'email': emailCont.text.trim(),
          'password': passCont.text.trim(),
          'device_token': deviceToken
        },
        showdialog: false, // Don't show loading dialog, button progress indicator is enough
      ).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw Exception(
              'Login API call timed out after 10 seconds. Please check your internet connection.');
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

        // Handle login success

        await onLoginSuccess(response.body);
        return response.statusCode;
      } else if (response.statusCode! >= 400) {
      } else if (response.statusCode == 500) {
      } else {}
    } catch (e) {
    } finally {
      // Always set loading state to false when done
      isLoading.value = false;
      update();
    }
  }

  Future<void> refreshDeviceToken() async {
    try {
      String? token;

      // Generate a unique device token for this user
      // If user is not yet logged in, create a temporary token
      final userId =
          user?.userId ?? 'temp_${DateTime.now().millisecondsSinceEpoch}';
      token = 'venta_cuba_user_$userId';
      deviceToken = token;
    } catch (e) {}
  }

  /// Helper method to save device token with platform detection
  Future<void> saveDeviceTokenWithPlatform(String userId) async {
    // Prevent concurrent device token saves
    if (_savingDeviceToken) {
      return;
    }

    _savingDeviceToken = true;

    try {
      final supabaseService = SupabaseService.instance;

      String token = 'venta_cuba_user_$userId';

      bool success = await supabaseService.saveDeviceTokenWithPlatform(
        userId: userId,
        token: token,
      );

      if (success) {
        deviceToken = token; // Update local token
      } else {}
    } catch (e) {
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
      // Email send successfully
    } else if (response.statusCode == 500) {
      // Unable to send password reset email
    } else {
      // An account doesn't exist with that email address
    }
  }

  Future addBusiness(String province, String city) async {
    List<String>? image = [];
    image.add(businessLogo ?? "");

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
      // Something went wrong
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
      // Password Changed Successfully
    } else {
      // Something went wrong
    }
  }

  Future updateBusiness() async {
    List<String>? image = [];
    image.add(businessLogo ?? "");

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
      // Something went wrong
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
      onUpdateUserData(response.body);
      // Image Update Successfully
    } else {
      // Something went wrong
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
      // Profile updated successfully
    } else {
      // Something went wrong
    }
  }

  Future saveNotificationSettings() async {
    Response response = await api.postWithForm(
      "api/save-notification-settings",
      {
        'all_notifications': allNotification,
        'bump_up_notification': bumpUpNotification,
        'save_search_notification': saveSearchNotification,
        'message_notification': messageNotification,
        'marketing_notification': marketingNotification,
        'reviews_notification': reviewsNotification
      },
    );
    if (response.statusCode == 200) {
      onUpdateUserData(response.body);
      Get.back();
      // Notification Setting Update Successfully
    } else {
      // Something went wrong
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
    } catch (e) {}
  }

  // Set user as online
  Future<void> setUserOnline() async {
    try {
      if (user?.userId != null) {
        final chatController = Get.find<SupabaseChatController>();
        await chatController.setUserOnline(user!.userId.toString());
      }
    } catch (e) {}
  }

  // Set user as offline
  Future<void> setUserOffline() async {
    try {
      if (user?.userId != null) {
        final chatController = Get.find<SupabaseChatController>();
        await chatController.setUserOffline(user!.userId.toString());

        // Stop push notification services when going offline
        await stopPushNotifications();
      }
    } catch (e) {}
  }

  // Update device token in all chat documents where this user participates
  Future<void> updateDeviceTokenInAllChats(String newToken) async {
    try {
      if (user?.userId == null) return;

      final chatController = Get.find<SupabaseChatController>();
      final supabase = chatController.getSupabaseClient();
      String currentUserId = user!.userId.toString();

      // Get all chats where this user is either sender or recipient
      final chats = await supabase
          .from('chats')
          .select('id, sender_id, send_to_id')
          .or('sender_id.eq.$currentUserId,send_to_id.eq.$currentUserId');

      // Update device token in each chat
      for (var _ in chats) {
        await chatController.updateDeviceTokenInChat(
          currentUserId,
          newToken,
        );
      }
    } catch (e) {}
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
      return null;
    } catch (e) {
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
      // Media links Added successfully
    } else {
      // Something went wrong
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
      // Media links Added successfully
    } else {
      // Something went wrong
    }
  }

  onLoginSuccess(Map<String, dynamic> value) async {
    await prefs.setString("user_data", jsonEncode(value));

    // Extract user_id directly from the response
    String? loginUserId = value['user_id']?.toString();

    if (loginUserId != null &&
        loginUserId.isNotEmpty &&
        loginUserId != 'null') {
      // Generate and save device token IMMEDIATELY with the user_id from login
      deviceToken = 'venta_cuba_user_$loginUserId';

      // Save to Supabase immediately
      await saveDeviceTokenWithPlatform(loginUserId);
    } else {}

    isBusinessAccount = false;
    changeAccountType();
    fetchAccountType();
    await getuserDetail();

    // Initialize services
    try {
      if (user?.userId != null) {
        final userId = user!.userId.toString();

        // Set RLS user context for secure Supabase access
        await RLSHelper.setUserContext(userId);

        // Initialize push notifications properly
        await initializePushNotifications(userId);
      }
    } catch (e) {
      // Don't block login if services fail
    }

    update();
    Get.offAll(Navigation_Bar());
  }

  void userMainProfileData(Map<String, dynamic> value) {}
  void onUpdateUserData(Map<String, dynamic> value) async {
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
      } catch (e) {}

      // Clear device token from Supabase for all platforms
      if (user?.userId != null) {
        try {
          // Remove all tokens for this user (both iOS and Android)
          await SupabaseService.client
              .from('device_tokens')
              .delete()
              .eq('user_id', user!.userId.toString());
        } catch (e) {}
      }

      // Stop all push notification services
      await stopPushNotifications();

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
      } catch (e) {}

      // Navigate to login regardless of server response
      Get.offAll(() => const Login());

      if (response.statusCode != 200) {}
    } catch (e) {
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
        } catch (e) {}

        Get.offAll(() => const Login());
      } catch (clearError) {
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
      } catch (e) {}

      Get.offAll(() => const Login());
    } else {
      // Something went wrong
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
