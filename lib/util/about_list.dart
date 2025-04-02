import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../view/constants/Colors.dart';

class AboutList extends StatelessWidget {
final String text;
  const AboutList({super.key,
required this.text
});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      height: 45..h,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(60),
          color: AppColors.k0xFFC4C4C4.withOpacity(.10)
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 20..h,
            width: 20..w,
            child: Image.asset('assets/icons/like.png'),
          ),
          SizedBox(width: 15..w,),
          Text(text,
            style: TextStyle(
                fontSize: 13..sp,
                fontWeight: FontWeight.w500,
                color: AppColors.black
            ),
          ),
        ],
      ),
    );
  }
}
