import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/view/Chat/custom_text.dart';
class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

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
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: SelectionArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15),
                Center(
                  child: CustomText(
                    text: "VentaCuba Privacy Policy".tr,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: CustomText(
                    text: "Table of contents".tr,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomText(text: "⦁", fontColor: Colors.green, fontSize: 17),
                        SizedBox(width: 5),
                        CustomText(text: "General".tr, fontColor: Colors.green, fontSize: 17),
                      ],
                    ),
                    Row(
                      children: [
                        CustomText(text: "⦁", fontColor: Colors.green, fontSize: 17),
                        SizedBox(width: 5),
                        CustomText(
                            text: "What personal information do we collect".tr,
                            fontColor: Colors.green,
                            fontSize: 17),
                      ],
                    ),
                    Row(
                      children: [
                        CustomText(text: "⦁", fontColor: Colors.green, fontSize: 17),
                        SizedBox(width: 5),
                        CustomText(
                            text: "How we use your personal information".tr,
                            fontColor: Colors.green,
                            fontSize: 17),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(text: "⦁", fontColor: Colors.green, fontSize: 17),
                        SizedBox(width: 5),
                        SizedBox(
                          width: 300.w,
                          child: CustomText(
                              text: "Transfers of your personal information to other jurisdictions".tr,
                              fontColor: Colors.green,
                              fontSize: 17),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        CustomText(text: "⦁", fontColor: Colors.green, fontSize: 17),
                        SizedBox(width: 5),
                        CustomText(text: "Marketing Purposes".tr, fontColor: Colors.green, fontSize: 17),
                      ],
                    ),
                    Row(
                      children: [
                        CustomText(text: "⦁", fontColor: Colors.green, fontSize: 17),
                        SizedBox(width: 5),
                        CustomText(text: "Advertising".tr, fontColor: Colors.green, fontSize: 17),
                      ],
                    ),
                    Row(
                      children: [
                        CustomText(text: "⦁", fontColor: Colors.green, fontSize: 17),
                        SizedBox(width: 5),
                        CustomText(text: "Cookies".tr, fontColor: Colors.green, fontSize: 17),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(text: "⦁", fontColor: Colors.green, fontSize: 17),
                        SizedBox(width: 5),
                        SizedBox(
                          width: 300.w,
                          child: CustomText(
                              text:
                                  "Data subject rights - accessing, rectifying, changing and deleting your personal information, and withdrawing consent"
                                      .tr,
                              fontColor: Colors.green,
                              fontSize: 17),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(text: "⦁", fontColor: Colors.green, fontSize: 17),
                        SizedBox(width: 5),
                        SizedBox(
                          width: 300,
                          child: CustomText(
                              text: "Protection and retention of your personal information".tr,
                              fontColor: Colors.green,
                              fontSize: 17),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        CustomText(text: "⦁", fontColor: Colors.green, fontSize: 17),
                        SizedBox(width: 5),
                        CustomText(text: "Other Information".tr, fontColor: Colors.green, fontSize: 17),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text.rich(
                  TextSpan(
                    text: '1. ${"general".tr}\n\n',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), // default text style
                    children: [
                      TextSpan(
                          text:
                              "privacy_policy".tr,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                      TextSpan(
                          text:
                          "\n\n",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                      TextSpan(
                          text:
                          "scope_and_consent".tr,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                      TextSpan(
                          text:
                          "by_using_ventacuba".tr,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                      TextSpan(
                          text:
                          "\n\n",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                      TextSpan(
                          text:
                          "changes_to_policy".tr,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                      TextSpan(
                          text:
                          "\n",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),










                Text.rich(
                  TextSpan(
                    text: '2. What personal information do we collect'.tr,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), // default text style
                    children: [
                      TextSpan(
                          text:
                              '''\n\nYou can visit our Website without registering for an account. When you decide to provide us with your personal information, you agree that such information is sent to and stored on our servers. We collect the following types of personal information:'''
                                  .tr,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: 'Information we collect automatically: '.tr,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), // default text style
                    children: [
                      TextSpan(
                          text:"visit_website".tr,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: 'Information you provide to us: '.tr,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), // default text style
                    children: [
                      TextSpan(
                          text:
                          "collect_information".tr,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: 'Information from other sources: '.tr,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), // default text style
                    children: [
                      TextSpan(
                          text:
                          "additional_information".tr,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: '3. How we use your personal information'.tr,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), // default text style
                    children: [
                      TextSpan(
                          text:
                          "use_your_personal_information".tr,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: 'Sharing information with and registration on social media sites: '.tr,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), // default text style
                    children: [
                      TextSpan(
                          text:
                          "sign_in_offer".tr,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: 'Transfer of your personal information to third parties: '.tr,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), // default text style
                    children: [
                      TextSpan(
                          text:
                          "transfer_personal_information_third_parties".tr,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: 'Application Use. '.tr,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), // default text style
                    children: [
                      TextSpan(
                          text:
                          "application_use".tr,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),






















                Text.rich(
                  TextSpan(
                    text: '4. Transfers of your personal information to other jurisdictions'.tr,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), // default text style
                    children: [
                      TextSpan(
                          text:
                          "transfers_personal_information".tr,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),






















                Text.rich(
                  TextSpan(
                    text: '5. Marketing Purposes'.tr,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), // default text style
                    children: [
                      TextSpan(
                          text:
                          "5_marketing_purposes".tr,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: '7. Cookies'.tr,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), // default text style
                    children: [
                      TextSpan(
                          text:
                          "7_cookies".tr,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text:
                        '8. Data subject rights – accessing, rectifying, changing and deleting your personal information, and withdrawing consent'
                            .tr,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), // default text style
                    children: [
                      TextSpan(text: '''
            ''', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: '\nAccessing or obtaining a copy of your information: '.tr,
                    style: TextStyle(fontSize: 16), // default text style
                    children: [
                      TextSpan(
                          text:"access_personal_information".tr,
                          style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: 'Rectifying your information:'.tr,
                    style: TextStyle(fontSize: 16), // default text style
                    children: [
                      TextSpan(
                          text:"rectifying_your_information".tr,
                          style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: 'Changing your information:'.tr,
                    style: TextStyle(fontSize: 16), // default text style
                    children: [
                      TextSpan(
                          text: "changing_your_information".tr,
                          style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: 'Deleting your information: '.tr,
                    style: TextStyle(fontSize: 16), // default text style
                    children: [
                      TextSpan(
                          text:
                          "deleting_your_information".tr,
                          style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: 'Withdrawing Consent:'.tr,
                    style: TextStyle(fontSize: 16), // default text style
                    children: [
                      TextSpan(
                          text:
                          "withdrawing_consent".tr,
                          style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
































                Text.rich(
                  TextSpan(
                    text: '9. Protection and retention of your personal information'.tr,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), // default text style
                    children: [
                      TextSpan(
                          text:
                          "protect_information".tr,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
               Text.rich(
                  TextSpan(
                    text: '10. Other information'.tr,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), // default text style
                    children: [
                      TextSpan(text: '''
                      
                      ''', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: 'Abuse and unsolicited commercial communications ("spam"):'.tr,
                    style: TextStyle(fontSize: 16), // default text style
                    children: [
                      TextSpan(
                          text:
                               "other_information".tr,
                          style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: 'Third Parties:'.tr,
                    style: TextStyle(fontSize: 16), // default text style
                    children: [
                      TextSpan(
                          text:  "third_parties".tr,
                          style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),

                SizedBox(height: 30,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
