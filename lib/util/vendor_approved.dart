import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../view/constants/Colors.dart';

class VendorApproved extends StatelessWidget {
  const VendorApproved({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      height: 125..h,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.white,
          border: Border.all(
            color: AppColors.black.withOpacity(.1),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 3,
              color: AppColors.black.withOpacity(.1),
            )
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SelectionArea(
                child: Text('Customer Name',
                  style: TextStyle(
                      fontSize: 13..sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.k0xFFA9ABAC
                  ),
                ),
              ),
              Container(
                height: 30..h,
                width: 30..w,
                decoration: BoxDecoration(
                    shape: BoxShape.circle
                ),
                child: Image.asset('assets/images/profile1.png'),
              )
            ],
          ),
          SelectionArea(
            child: Text('Anton Demeron',
              style: TextStyle(
                  fontSize: 17..sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black
              ),
            ),
          ),
          SizedBox(height: 7..h,),
          SelectionArea(
            child: Text('Tracking ID: ASV23456777',
              style: TextStyle(
                  fontSize: 15..sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.k0xFFA9ABAC
              ),
            ),
          ),
        ],
      ),
    );
  }
}
