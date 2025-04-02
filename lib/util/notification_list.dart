import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../view/constants/Colors.dart';

class NotificationList extends StatelessWidget {
  final String imagePath;
  final String time;
  const NotificationList({super.key,
  required this.imagePath,
    required this.time
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66..h,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 65..h,
            width: 65..w,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32.5)
            ),
            child: Image.asset(imagePath),
          ),
          Container(
            height: 66..h,
            width: MediaQuery.of(context).size.width*.70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5..h),
                Text('Your Order is Placed Successfully',
                  style: TextStyle(
                      fontSize: 16..sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black
                  ),
                  textAlign: TextAlign.start,
                ),
                Text('Track your Order!',
                  style: TextStyle(
                      fontSize: 16..sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black
                  ),
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 5..h,),
                Text(time,
                  style: TextStyle(
                      fontSize: 13..sp,
                      fontWeight: FontWeight.w500,
                      color:AppColors.k0xFF6C6C6C
                  ),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
