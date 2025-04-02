import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Controllers/home_controller.dart';

import '../../util/my_button.dart';

class RattingScreen extends StatelessWidget {
  RattingScreen({super.key});

  final homeCont = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: SelectionArea(
        child: Container(
          height: 478.h,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r)),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
            child: Column(
              children: [
                Text(
                  'Rate this Service?'.tr,
                  style: TextStyle(
                    color: Color(0xFF444444),
                    fontSize: 18,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(
                  height: 16.h,
                ),
                RatingBar.builder(
                  initialRating: 3,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    homeCont.userRatting = rating;
                  },
                ),
                SizedBox(
                  height: 35.h,
                ),
                Text(
                  'Please share your opinion\nabout this service'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF444444),
                    fontSize: 18,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(
                  height: 30.h,
                ),
                TextField(
                    controller: homeCont.reviewController,
                    maxLines: 5,
                    minLines: 5,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                        hintText: 'Your review'.tr,
                        hintStyle: TextStyle(
                          color: Color(0xFFC0C0C0),
                          fontSize: 14,
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.w400,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(
                              color: Color(0xFFC0C0C0),
                            )))),
                SizedBox(
                  height: 40.h,
                ),
                InkWell(
                  onTap: () {
                    homeCont.ratting();
                    Get.back();
                  },
                  child: MyButton(
                    text: 'Done'.tr,
                  ),
                ),
                SizedBox(
                  height: 17.h,
                ),
                InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Text(
                    'Skip'.tr,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Sk-Modernist',
                      fontWeight: FontWeight.w700,
                      height: 0,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
