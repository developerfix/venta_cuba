import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:venta_cuba/view/auth/login.dart';
import 'package:venta_cuba/view/constants/Colors.dart';

class IntroSlider extends StatefulWidget {
  const IntroSlider({super.key});

  @override
  State<IntroSlider> createState() => _IntroSliderState();
}
class _IntroSliderState extends State<IntroSlider> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Padding(
        padding: const EdgeInsets.only(
          top: 120,
        ),
        child: IntroductionScreen(
          globalBackgroundColor: AppColors.white,
          scrollPhysics: BouncingScrollPhysics(),
          pages: [
            PageViewModel(
              image: Image.asset('assets/images/splash1.png'),
              titleWidget: Text(
                'Buy Products'.tr,
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 25,
                ),
              ),
              body:
                  'Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint.\nVelit officia consequat duis enim velit mollit. Exercitation veniam \nconsequat sunt nostrud amet.'
                      .tr,
              decoration: PageDecoration(
                  bodyTextStyle: TextStyle(
                color: AppColors.k0xFFA9ABAC,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              )),
            ),
            PageViewModel(
              image: Image.asset('assets/images/splash2.png'),
              titleWidget: Text(
                'List Products'.tr,
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 25,
                ),
              ),
              body: 'Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint.'
                  'Velit officia consequat duis enim velit mollit. Exercitation veniam '
                  'consequat sunt nostrud amet.',
              decoration: PageDecoration(
                  bodyTextStyle: TextStyle(
                color: AppColors.k0xFFA9ABAC,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              )),
            ),
            PageViewModel(
              image: Image.asset('assets/images/splash3.png'),
              titleWidget: Text(
                'Sell Products'.tr,
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 25,
                ),
              ),
              body: 'Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint.'
                  'Velit officia consequat duis enim velit mollit. Exercitation veniam '
                  'consequat sunt nostrud amet.',
              decoration: PageDecoration(
                  bodyTextStyle: TextStyle(
                color: AppColors.k0xFFA9ABAC,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              )),
            ),
          ],
          onDone: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Login(),
                ));
          },
          done: Text(
            'Next'.tr,
            style: TextStyle(
              color: AppColors.k0xFF403C3C,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          next: Text(
            'Next'.tr,
            style: TextStyle(
              color: AppColors.k0xFF403C3C,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          dotsDecorator: DotsDecorator(
              size: Size.square(10),
              activeSize: Size(40, 10),
              activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              activeColor: AppColors.k0xFF0254B8),
        ),
      ),
    );
  }
}
