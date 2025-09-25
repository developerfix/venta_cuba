import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../view/constants/Colors.dart';

class SellerList extends StatelessWidget {
  const SellerList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260..h,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10..r)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180..h,
            width: MediaQuery.of(context).size.width,
            child: Image.asset('assets/images/notImage.jpg',
              fit: BoxFit.fill,
            ),
          ),
          Container(
            height: 57..h,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Real State',
                  style: TextStyle(
                      fontSize: 17..sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black
                  ),
                ),
                Text('Buy & Sell ',
                  style: TextStyle(
                      fontSize: 13..sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.k0xFF403C3C
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
