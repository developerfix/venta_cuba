import 'dart:convert';

import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:http/http.dart' as http;
import '../Controllers/auth_controller.dart';
import '../Utils/funcations.dart';
import '../view/auth/login.dart';
import 'package:flutter/material.dart';

import '../view/auth/sign_up.dart';

class ApiChecker {
  Future<Response> checkApi(
      {required http.Response respons,
      bool showUserError = true,
      bool showSystemError = true}) async {
    dynamic responseBody;
    try {
      // Try to parse as JSON first
      responseBody = jsonDecode(respons.body);
    } catch (e) {
      // If JSON parsing fails, use the raw body
      print("Response is not valid JSON, status code: ${respons.statusCode}");
      print("Response headers: ${respons.headers}");
      print(
          "Response body (first 500 chars): ${respons.body.length > 500 ? respons.body.substring(0, 500) + '...' : respons.body}");
      responseBody = respons.body;
    }

    dynamic response = Response(
      body: responseBody,
      bodyString: respons.body.toString(),
      request: Request(
          headers: respons.request!.headers,
          method: respons.request!.method,
          url: respons.request!.url),
      headers: respons.headers,
      statusCode: respons.statusCode,
      statusText: respons.reasonPhrase,
    );
    print(response.body);
    print("status code: ${response.statusCode}");
    if (response == null) {
      if (showSystemError) {
        errorAlertToast('Check your internet connection and try again');
      }
    } else if (response.statusCode == 200) {
      return response;
    } else if (response.statusCode! == 401 || response.statusCode! == 403) {
      if (showUserError) {
        Get.offAll(() => Login());
        // Handle cases where response.body might not be a Map (e.g., HTML error pages)
        if (response.body is Map && response.body['message'] != null) {
          errorAlertToast(response.body['message']);
        } else {
          errorAlertToast('Authentication failed. Please login again.'.tr);
        }
      }
    } else if (response.statusCode! >= 500) {
      if (showSystemError) {
        // Check if it's an authentication-related server error
        if (response.body != null &&
            response.body is Map &&
            response.body['message'] != null &&
            response.body['message']
                .toString()
                .toLowerCase()
                .contains('authenticate')) {
          errorAlertToast('Authentication error. Please login again.'.tr);
          // Navigate to login screen for authentication errors
          Get.offAll(() => Login());
        } else {
          errorAlertToast(
            'Server Error!\nPlease try again...'.tr,
          );
        }
      }
    } else if (response.statusCode! >= 400) {
      if (showUserError) {
        // Handle cases where response.body might not be a Map (e.g., HTML error pages)
        if (response.body is Map && response.body['message'] != null) {
          if (response.body['message'] == "Unauthorized") {
            _showCustomAlertDialog();
            errorAlertToast("wrong email or password".tr);
          } else {
            errorAlertToast("${response.body['message']}".tr);
          }
        } else {
          // If response body is not a Map or doesn't have a message, show generic error
          errorAlertToast('Request failed. Please try again.'.tr);
        }
      }
    }
    return Response(
        statusCode: response.statusCode, statusText: response.body.toString());
  }

  void _showCustomAlertDialog() {
    AuthController authController = Get.put(AuthController());
    Get.defaultDialog(
      title: "Can't find account".tr,
      titlePadding: EdgeInsets.only(top: 15),
      contentPadding: EdgeInsets.only(top: 15),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Text(
          "account not found"
              .tr
              .replaceAll('{email}', authController.emailCont.text),
          textAlign: TextAlign.center,
        ),
        // child: Text(
        //   "We can't find an account with ${authController.emailCont.text}. Try another email, or if you don't have an account, you can sign up."
        //       .trParams({"email": authController.emailCont.text}),
        //   textAlign: TextAlign.center,
        // ),
      ),
      actions: <Widget>[
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.blueGrey.shade300, Colors.blueGrey.shade50],
              ),
              // color: Colors.blue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              )),
          child: FittedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildAlertDialogButton('Sign up'.tr, Colors.white, () {
                  Get.to(SignUp())?.then((value) => Get.back());
                }),
                Container(
                  height: 25,
                  width: 1.0,
                  color: Colors.grey,
                ),
                _buildAlertDialogButton('Try again'.tr, Colors.white, () {
                  Get.back();
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertDialogButton(
      String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: 150,
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(color: color),
        ),
      ),
    );
  }
}
