// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:pinput/pinput.dart';
// import 'package:venta_cuba/Controllers/auth_controller.dart';
// import '../../Utils/funcations.dart';
// import '../../util/my_button.dart';

// class OTPScreen extends StatefulWidget {
//   final String province;
//   final String city;
//   const OTPScreen({super.key, required this.province, required this.city});

//   @override
//   State<OTPScreen> createState() => _OTPScreenState();
// }

// class _OTPScreenState extends State<OTPScreen> {
//  final authCont=Get.find<AuthController>();

//   @override
//   void dispose() {
//     authCont.otpCode.clear();
//     authCont.closeSmartAuth();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     authCont.getSmsCode();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//           appBar: AppBar(
//             elevation: 0,
//             backgroundColor: Colors.white,
//             leading: GestureDetector(
//               onTap: () {
//                 Navigator.of(context).pop();
//               },
//               child: Icon(
//                 Icons.arrow_back_ios,
//                 size: 20,
//               ),
//             ),
//           ),
//           backgroundColor: Colors.white,
//           body: GetBuilder(
//             init: AuthController(),
//             builder: (cont) {
//               return Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(
//                         height: 80..h,
//                       ),
//                       Text(
//                         'Confirm Your Code'.tr,
//                         style: TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
//                       ),
//                       SizedBox(height: 36..h),
//                       Text(
//                         'Please input the code sent to your phone number below'.tr,
//                         style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
//                       ),
//                       SizedBox(height: 40..h),
//                       SizedBox(
//                         child: Pinput(
//                           controller: cont.otpCode,
//                           androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsRetrieverApi,
//                           length: 6,
//                           preFilledWidget: Text(
//                             '-',
//                             style:
//                                 TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.w500, fontSize: 18),
//                           ),
//                           defaultPinTheme: PinTheme(
//                             width: 60..w,
//                             height: 50..h,
//                             textStyle: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w400,
//                               color: Color(0xB3000000),
//                             ),
//                             decoration: BoxDecoration(
//                               color: Color(0xFFF0F1F1),
//                               borderRadius: BorderRadius.circular(10.r),
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(
//                         height: 100..h,
//                       ),
//                       GestureDetector(
//                           onTap: () {
//                             if (cont.otpCode.text.length < 6) {
//                               errorAlertToast("Please Enter Correct OTP Code".tr);
//                             } else {
//                               cont.verifyOTP(
//                                 widget.province,
//                                 widget.city,
//                               );

//                             }
//                           },
//                           child: MyButton(text: 'Confirm Code'.tr)),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           )),
//     );
//   }
// }
