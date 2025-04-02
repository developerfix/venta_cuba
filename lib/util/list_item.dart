import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../view/constants/Colors.dart';

class ListItem extends StatelessWidget {
  final String imagePath;
  const ListItem({super.key,
  required this.imagePath
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 170..h,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10..r)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 170..h,
                width: 170..w,
                child: Image.asset(imagePath,
                  fit: BoxFit.fill,
                ),
              ),
              Container(
                height: 79..h,
                width: MediaQuery.of(context).size.width*.37,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          left: 115..w,
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
