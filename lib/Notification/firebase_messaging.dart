import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as meth;
import 'dart:typed_data';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:venta_cuba/Utils/global_variabel.dart';

import '../Controllers/auth_controller.dart';
import 'fcm_model.dart';
bool isOpenFile=false;
String filePathD="";
class FCM {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final streamCtrl = StreamController<String>.broadcast();

  // static SharedPreference sharedPreference = SharedPreference();
  // final NavigationService _navigationService = locator<NavigationService>();
  //
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings androidInitializationSettings =
      const AndroidInitializationSettings('@drawable/profits');
  late DarwinInitializationSettings iosInitializationSettings;
  late InitializationSettings initializationSettings;

  void initializing() async {
    await FirebaseMessaging.instance
        .setAutoInitEnabled(true); // later added for manifest.xml permission
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    )
        .catchError((onError) {
      print("this is firebase error::: ${onError.toString()}");
    });

    androidInitializationSettings =
        const AndroidInitializationSettings('@drawable/profits');
    iosInitializationSettings = const DarwinInitializationSettings();
    initializationSettings = InitializationSettings(
        iOS: iosInitializationSettings, android: androidInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveLocalNotification,
    );
  }

  static void _showNotifications(
      String body,
      String title,
      String channelDescription,
      String ticker,
      String payLoad,
      bool wakeUpScreen,
      bool autoCancel,
      AndroidNotificationCategory category) async {
    print("PayLoad>>>>>>>>>>>>>>>>>$payLoad");
    await notification(body, title, channelDescription, ticker, payLoad,
        wakeUpScreen, autoCancel, category);
    // }
  }


  static Future<void> notification(
      String body,
      String title,
      String channelDescription,
      String ticker,
      String payLoad,
      bool wakeUpScreen,
      bool autoCancel,
      AndroidNotificationCategory category) async {
    var vibrationPattern = Int64List(8);

    vibrationPattern[0] = 0;
    vibrationPattern[1] = 250;
    vibrationPattern[2] = 500;
    vibrationPattern[3] = 250;
    vibrationPattern[4] = 500;
    vibrationPattern[5] = 250;
    vibrationPattern[4] = 500;
    vibrationPattern[5] = 250;
    vibrationPattern[6] = 0;

    AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
        meth.Random().nextInt(1000).toString(), title,
        priority: Priority.high,
        largeIcon: const DrawableResourceAndroidBitmap('@drawable/profits'),
        vibrationPattern: vibrationPattern,
        channelDescription: channelDescription,
        fullScreenIntent: wakeUpScreen,
        category: category,
        autoCancel: autoCancel,
        importance: Importance.high,
        channelShowBadge: true,
        styleInformation:
        BigTextStyleInformation(body, htmlFormatSummaryText: true),
        ticker: ticker);

    DarwinNotificationDetails iosNotificationDetails =
    const DarwinNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
        meth.Random().nextInt(1000), title, body, notificationDetails,
        payload: payLoad);
  }


  Future<void> ios_permission() async {
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

    }
    _firebaseMessaging.requestPermission(sound: true, badge: true, alert: true);
  }




  void firebaseCloudMessagingListeners(BuildContext context) {
    if (Platform.isIOS) ios_permission();
    print('listening firebase');
    Future.delayed(const Duration(milliseconds: 500), () {
      FirebaseMessaging.onMessage.listen((RemoteMessage messages) {
        print('A new onMessage event was published! ${messages.data["body"]}');
        print('A new onMessage event was published! ${messages.data["body"]}');

        Map<String, dynamic> message = messages.data;
        if (Platform.isAndroid) {
          _showNotifications(
              message["body"],
              message["title"],
              'message_channel',
              'message',
              jsonEncode({
                'image': message["image"].toString(),
                'name': message["name"],
              }),
              false,
              false,
              AndroidNotificationCategory.message);
        } else {
          _showNotifications(
              messages.notification!.body!,
              messages.notification!.title!,
              'message_channel',
              'message',
              jsonEncode({
                'image': message["image"].toString(),
                'name': message["name"],
              }),
              false,
              false,
              AndroidNotificationCategory.message);
        }
      });
    });}

  setNotifications(BuildContext context) {
    initializing();
    firebaseCloudMessagingListeners(context);
    _firebaseMessaging.getToken().then((token) {
  deviceToken = token??"";
      debugPrint('device token_id:_______________$token _______________');
    });
  }
  Future<void> sendNotificationFCM(
      {
        String? userId,
        String? remoteId,
        String? name,
        String? profileImage,
        String? deviceToken,
        String? title,
        String? body,
        String? type,

      }) async {
    Data data = Data(
      userId: userId,
      remoteId: remoteId,
      name: name,
      profileImage: profileImage,
      title: title,
      body: body,
      type: type,
    );
    NotificationData notification =
    NotificationData(title: title, body: body);
    FCMModel fcmModel = FCMModel(
      data: data,
      token: deviceToken,
      notification: notification,
    );

    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/ventacuba-acf38/messages:send?access_token=$notificationAccessToken'));
    request.body = jsonEncode({"message": fcmModel});
    print(jsonEncode({"message": fcmModel}));

    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    print("StatusCode>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>${response.statusCode}");
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }
      void onDidReceiveLocalNotification(
          NotificationResponse notificationResponse) async {}
}
