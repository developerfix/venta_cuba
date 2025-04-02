import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Categories extends StatelessWidget {
  final String imagePath;
  final String text;
  const Categories({super.key,
    required this.imagePath,
    required this.text
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CachedNetworkImage(
          height: 35..h,
          width: 35..w,
          imageUrl: imagePath,
          imageBuilder: (context, imageProvider) => Container(
            height: 35..h,
            width: 35..w,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                 ),
              shape: BoxShape.circle
            ),
          ),
          placeholder: (context, url) => SizedBox(
              height: 35..h,
              width: 35..w,
              child: Center(child: CircularProgressIndicator(
                strokeWidth: 2,
              ))),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
        SelectionArea(
          child: Text(text,
            style: TextStyle(
              fontSize: 15..sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        )
      ],
    );
  }
}
