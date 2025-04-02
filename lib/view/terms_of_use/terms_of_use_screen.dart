import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/view/Chat/custom_text.dart';

class TermsOfUse extends StatelessWidget {
  const TermsOfUse({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        shadowColor: Colors.white,
         backgroundColor: Colors.white, // Set it explicitly
         scrolledUnderElevation: 0,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(
            Icons.arrow_back_ios,
            size: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SelectionArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15),
                Center(
                  child: CustomText(
                    text: "VentaCuba Terms of Use".tr,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 10),
                CustomText(
                  text:
                  "terms_of_use_privacy_policy".tr,
                ),
                CustomText(
                  text: "violate_any_laws".tr,
                ),
                CustomText(
                  text: "\n",
                ),
                Text.rich(
                  TextSpan(
                    text: 'Abusing VentaCuba Services.'.tr,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    // default text style
                    children: [
                      TextSpan(
                          text:
                          "abusing_ventaCuba_services".tr,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: 'Global Marketplace.'.tr,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    // default text style
                    children: [
                      TextSpan(
                          text:
                          "global_marketplace".tr,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: 'Fees and Services.'.tr,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    // default text style
                    children: [
                      TextSpan(
                          text:
                          "fees_and_services".tr,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: 'Content.'.tr,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    // default text style
                    children: [
                      TextSpan(
                          text:
                          "content".tr,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),



                Text.rich(
                  TextSpan(
                    text:
                        'Reporting Intellectual Property Infringements (Verified Rights Owners - VeRO). '
                            .tr,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    // default text style
                    children: [
                      TextSpan(
                          text:
                          "reporting_intellectual_property".tr,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: 'Reviews. '.tr,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    // default text style
                    children: [
                      TextSpan(
                          text:
                          "reviews_1".tr,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: '',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    // default text style
                    children: [
                      TextSpan(
                          text:
                          "reviews_2".tr,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: '',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    // default text style
                    children: [
                      TextSpan(
                          text:
                          "reviews_3".tr,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),





                Text.rich(
                  TextSpan(
                    text: 'Mobile Devices Terms'.tr,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    // default text style
                    children: [
                      TextSpan(
                          text:
                          "mobile_devices_terms".tr,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),







                Text.rich(
                  TextSpan(
                    text: 'Application Use. '.tr,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    // default text style
                    children: [
                      TextSpan(
                          text:
                          "application_use".tr,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),










                Text.rich(
                  TextSpan(
                    text: 'Intellectual Property – Applications. '.tr,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    // default text style
                    children: [
                      TextSpan(
                          text:
                          "intellectual_property_applications".tr,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: 'iOS – Apple'.tr,
                    style: TextStyle(fontSize: 16), // default text style
                    children: [
                      TextSpan(
                          text:
                          "iso_apple".tr,
                          style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: 'Android - Google',
                    style: TextStyle(fontSize: 16), // default text style
                    children: [
                      TextSpan(
                          text:
                          "android_google".tr,
                          style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
