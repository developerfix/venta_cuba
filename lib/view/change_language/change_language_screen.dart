import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:venta_cuba/view/Chat/custom_text.dart';

import '../Navigation bar/navigation_bar.dart';
import '../constants/Colors.dart';

class ChangeLanguageScreen extends StatefulWidget {
  const ChangeLanguageScreen({super.key});

  @override
  State<ChangeLanguageScreen> createState() => _ChangeLanguageScreenState();
}

class _ChangeLanguageScreenState extends State<ChangeLanguageScreen> {
  late int _selection = 0;
  String? countryCode = "ES";
  Future<void> getLanguage() async {
    var prefs = await SharedPreferences.getInstance();
    countryCode = prefs.getString('countryCode') ?? "ES";
    setState(() {
      countryCode == "US" ? _selection = 1 : _selection = 2;
    });
    print(countryCode);
  }

  @override
  void initState() {
    super.initState();
    getLanguage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
          ),
        ),
      ),
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomText(
              text: "Choose your language".tr,
              fontSize: 25..sp,
              fontWeight: FontWeight.w700,
            ),
            SizedBox(height: 20..h),
            CustomText(
              text:
                  "Select your preferred language to use\n VentaCuba easily".tr,
              fontSize: 16..sp,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w400,
            ),
            SizedBox(height: 20..h),
            InkWell(
              onTap: () async {
                setState(() {
                  _selection = 1;
                });
                var prefs = await SharedPreferences.getInstance();
                prefs.setString(
                    'languageCode', Locale("en", "US").languageCode);
                prefs.setString('countryCode', "US");
                Get.updateLocale(Locale("en", "US"));
              },
              child: Container(
                width: double.maxFinite,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: _selection == 1
                      ? Colors.green.shade300
                      : Theme.of(context).cardColor,
                  border: Border.all(
                      color: _selection == 1
                          ? Colors.green
                          : Theme.of(context).unselectedWidgetColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: AssetImage("assets/icons/f2.webp"),
                    ),
                    SizedBox(width: 15),
                    Text(
                      "English".tr,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18..sp),
                    ),
                    Spacer(),
                    Radio(
                      focusColor: Theme.of(context).cardColor,
                      groupValue: _selection,
                      onChanged: (va) async {
                        setState(() {
                          _selection = 1;
                        });
                        var prefs = await SharedPreferences.getInstance();
                        prefs.setString(
                            'languageCode', Locale("en", "US").languageCode);
                        prefs.setString('countryCode', "US");
                        Get.updateLocale(Locale("en", "US"));
                      },
                      value: 1,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20..h),
            InkWell(
              onTap: () async {
                setState(() {
                  _selection = 2;
                });
                var prefs = await SharedPreferences.getInstance();
                prefs.setString(
                    'languageCode', Locale("es", "ES").languageCode);
                prefs.setString('countryCode', "ES");
                Get.updateLocale(Locale("es", "ES"));
              },
              child: Container(
                // height: 40,
                width: double.maxFinite,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: _selection == 2
                      ? Colors.green.shade300
                      : Theme.of(context).cardColor,
                  border: Border.all(
                      color: _selection == 2
                          ? Colors.green
                          : Theme.of(context).unselectedWidgetColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                        backgroundImage: AssetImage("assets/icons/f1.jpg")),
                    SizedBox(width: 15),
                    Text(
                      "Spanish".tr,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18..sp),
                    ),
                    Spacer(),
                    Radio(
                      focusColor: AppColors.k0xFF0254B8,
                      groupValue: _selection,
                      onChanged: (va) async {
                        setState(() {
                          _selection = 2;
                        });
                        var prefs = await SharedPreferences.getInstance();
                        prefs.setString(
                            'languageCode', Locale("es", "ES").languageCode);
                        prefs.setString('countryCode', "ES");
                        Get.updateLocale(Locale("es", "ES"));
                      },
                      value: 2,
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            InkWell(
              onTap: () {
                Get.offAll(Navigation_Bar());
              },
              child: Container(
                height: 50..h,
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: AppColors.k0xFF0254B8)),
                child: Center(
                  child: Text(
                    'Continue'.tr,
                    style: TextStyle(
                        fontSize: 17..sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.k0xFF0254B8),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30)
          ],
        ),
      ),
    );
  }
}
