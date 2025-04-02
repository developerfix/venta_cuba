import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../view/constants/Colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GridItem extends StatelessWidget {
  final String imagePath;
  const GridItem({super.key,
  required this.imagePath
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 280..h,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10..r)
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 180..h,
                width: MediaQuery.of(context).size.width,
                child: Image.asset(imagePath,
                  fit: BoxFit.fill,
                ),
              ),
              Container(
                height: 57..h,
                color: Colors.white,
                child: Column(
                  children: [
                    Text('Black Shirt',
                      style: TextStyle(
                          fontSize: 17..sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black
                      ),
                    ),
                    Text('New Winter Wear',
                      style: TextStyle(
                          fontSize: 13..sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.k0xFF403C3C
                      ),
                    ),
                    SizedBox(height: 2..h,),
                    Text('\$45.00',
                      style: TextStyle(
                          fontSize: 16..sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.k0xFF0254B8
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        Positioned(
          top: 10..h,
          right: 10..w,
          child: Container(
            padding: EdgeInsets.all(10),
            height: 43..h,
            width: 43..w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(21.5..r)
            ),
            child: SvgPicture.asset('assets/icons/heart1.svg'),
          ),
        )
      ],
    );
  }
}
