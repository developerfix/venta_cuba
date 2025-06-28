import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyButton extends StatelessWidget {
  final String text;
  final double? width;
  const MyButton({
    super.key,
    required this.text,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50..h,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Color(0xFF0254B8), borderRadius: BorderRadius.circular(10)),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w400, color: Colors.white),
        ),
      ),
    );
  }
}
