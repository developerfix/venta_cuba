import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../view/constants/Colors.dart';

class ProfileList extends StatelessWidget {
  final String text;
  const ProfileList({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      height: 60..h,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(.4),
              blurRadius: 5,
            )
          ],
          color: AppColors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
                fontSize: 15..sp,
                fontWeight: FontWeight.w500,
                color: AppColors.black),
          ),
          Icon(
            Icons.arrow_forward_ios_outlined,
            size: 15,
            color: AppColors.k1xFF403C3C,
          )
        ],
      ),
    );
  }
}

class ProfileList2 extends StatelessWidget {
  final String text;
  const ProfileList2({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      height: 60..h,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(.4),
              blurRadius: 5,
            )
          ],
          borderRadius: BorderRadius.circular(5),
          color: AppColors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
                fontSize: 15..sp,
                fontWeight: FontWeight.w500,
                color: AppColors.black),
          ),
          Icon(
            Icons.arrow_forward_ios_outlined,
            size: 15,
            color: AppColors.k1xFF403C3C,
          )
        ],
      ),
    );
  }
}