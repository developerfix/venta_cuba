import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CustomImageView extends StatelessWidget {
  String image;
  CustomImageView({super.key,required this.image});

  @override
  Widget build(BuildContext context) {
    return  Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 0.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: (){
                Get.back();
              },
              child: Icon(Icons.cancel,
              size: 30,
              ),
            ),
          ),
          SizedBox(
            height: 600.h,
            child: InteractiveViewer(
              maxScale: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CachedNetworkImage(
                  imageUrl:image,
                  imageBuilder: (context, imageProvider) => Container(


                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => SizedBox(

                      child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ))),
                  errorWidget: (context, url, error) => Container(

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage("assets/images/notImage.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ), ),
          ),
        ],
      ),
    );
  }
}
