import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomText extends StatelessWidget {
  final String? text;
  final FontWeight? fontWeight;
  final double? fontSize;
  final Color? fontColor;
  final TextAlign? textAlign;
  final double? letterSpacing;
  final TextOverflow? textOverflow;

  const CustomText(
      {super.key,
      @required this.text,
      this.fontWeight,
      this.fontSize,
      this.fontColor,
      this.textAlign,
      this.textOverflow,
      this.letterSpacing});

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? "",
      textAlign: textAlign,
      style: TextStyle(
        fontWeight: fontWeight,
        fontSize: fontSize,
        fontFamily: "DMSans",
        color: fontColor,
        letterSpacing: letterSpacing,
      ),
      overflow: textOverflow,
    );
  }
}

class CustomTextMonthDays extends StatelessWidget {
  final String? text;
  final FontWeight? fontWeight;
  final double? fontSize;
  final Color? fontColor;
  final TextAlign? textAlign;
  final double? letterSpacing;
  final TextOverflow? textOverflow;

  const CustomTextMonthDays(
      {super.key,
      @required this.text,
      this.fontWeight,
      this.fontSize,
      this.fontColor,
      this.textAlign,
      this.textOverflow,
      this.letterSpacing});

  @override
  Widget build(BuildContext context) {
     // Check the current language
    Locale? currentLocale = Get.locale;
    String languageCode = currentLocale?.languageCode ?? 'en';
     String formatDuration(String duration) {
  final parts = duration.split(' ');
  if (parts.length != 3) return duration;

  String time = parts[0];
  String unit = parts[1];
  String value = unit == 'month' ? "mes" : "día";
  
  return ' hace '+time+' ${value}';
}
     if (text != null) {
  
    
        return Text(languageCode == 'en' ? text! :
          formatDuration(text!),
        textAlign: textAlign,
      style: TextStyle(
        fontWeight: fontWeight,
        fontSize: fontSize,
        fontFamily: "DMSans",
        color: fontColor,
        letterSpacing: letterSpacing,
      ),
      overflow: textOverflow,);
    
    }
    return Text(text ?? '');
  }
    
    // Text(
    //   text ?? "",
    //   textAlign: textAlign,
    //   style: TextStyle(
    //     fontWeight: fontWeight,
    //     fontSize: fontSize,
    //     fontFamily: "DMSans",
    //     color: fontColor,
    //     letterSpacing: letterSpacing,
    //   ),
    //   overflow: textOverflow,
    // );
  // }
}
class CustomText3 extends StatelessWidget {
  final String? text;
  final FontWeight? fontWeight;
  final double? fontSize;
  final Color? fontColor;
  final TextAlign? textAlign;
  final double? letterSpacing;
  final TextOverflow? textOverflow;

  const CustomText3(
      {super.key,
      @required this.text,
      this.fontWeight,
      this.fontSize,
      this.fontColor,
      this.textAlign,
      this.textOverflow,
      this.letterSpacing});

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? "",
      textAlign: textAlign,
      style: TextStyle(
        // overflow: TextOverflow.ellipsis,
        fontWeight: fontWeight,
        fontSize: fontSize,
        fontFamily: "SFUIText",
        color: fontColor,
        letterSpacing: letterSpacing,
      ),
      overflow: textOverflow,
    );
  }
}

class CustomText4 extends StatelessWidget {
  final String? text;
  final FontWeight? fontWeight;
  final double? fontSize;
  final Color? fontColor;
  final TextAlign? textAlign;
  final double? letterSpacing;
  final TextOverflow? textOverflow;

  const CustomText4(
      {super.key,
      @required this.text,
      this.fontWeight,
      this.fontSize,
      this.fontColor,
      this.textAlign,
      this.textOverflow,
      this.letterSpacing});

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? "",
      textAlign: textAlign,
      style: TextStyle(
        // overflow: TextOverflow.ellipsis,
        fontWeight: fontWeight,
        fontSize: fontSize,
        fontFamily: "SFUIText",
        color: fontColor,
        letterSpacing: letterSpacing,
      ),
      overflow: textOverflow,
    );
  }
}

class CustomText2 extends StatelessWidget {
  final String? text;
  final FontWeight? fontWeight;
  final double? fontSize;
  final Color? fontColor;
  final TextAlign? textAlign;
  final double? letterSpacing;

  const CustomText2(
      {super.key,
      @required this.text,
      this.fontWeight,
      this.fontSize,
      this.fontColor,
      this.textAlign,
      this.letterSpacing});

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? "",
      textAlign: textAlign,
      style: TextStyle(
        // overflow: TextOverflow.ellipsis,
        fontWeight: fontWeight,
        fontSize: fontSize,
        fontFamily: "DavidLibre",
        color: fontColor,
        letterSpacing: letterSpacing,
      ),
      overflow: TextOverflow.clip,
    );
  }
}
