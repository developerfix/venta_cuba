import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../view/constants/Colors.dart';

class CategoryList extends StatelessWidget {
  final String imagePath;
  final String text;
  final VoidCallback? onTitleTap;
  final VoidCallback? onArrowTap;

  const CategoryList({
    super.key,
    required this.imagePath,
    required this.text,
    this.onTitleTap,
    this.onArrowTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      height: 60..h,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Theme.of(context).brightness == Brightness.dark
              ? Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.black.withValues(alpha: 0.25),
              blurRadius: 4,
            )
          ],
          color: AppColors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Expanded clickable area for title
          Expanded(
            child: GestureDetector(
              onTap: onTitleTap,
              child: Row(
                children: [
                  CachedNetworkImage(
                    height: 45..h,
                    width: 45..w,
                    imageUrl: imagePath,
                    imageBuilder: (context, imageProvider) => Container(
                      height: 45..h,
                      width: 45..w,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                          shape: BoxShape.circle),
                    ),
                    placeholder: (context, url) => SizedBox(
                        height: 45..h,
                        width: 45..w,
                        child: Center(
                            child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ))),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                  SizedBox(
                    width: 10..w,
                  ),
                  Expanded(
                    child: Text(
                      text,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 15..sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Separate clickable area for arrow
          GestureDetector(
            onTap: onArrowTap,
            child: Container(
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.arrow_forward_ios_outlined,
                size: 15,
                color: AppColors.k1xFF403C3C,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
