import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:venta_cuba/Controllers/home_controller.dart';

import '../../Models/AllPromoCodesModel.dart';
import '../constants/Colors.dart';
import '../payment/payment_next.dart';

class PromoCodeScreen extends StatefulWidget {
  @override
  _PromoCodeScreenState createState() => _PromoCodeScreenState();
}

class _PromoCodeScreenState extends State<PromoCodeScreen> {
  final homeCont = Get.find<HomeController>();

  @override
  void initState() {
    homeCont.isEnterPromoCode = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SelectionArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 20,
                      ),
                    ),
                    Text(
                      'Promo Codes'.tr,
                      style: TextStyle(
                          fontSize: 21..sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.titleLarge?.color),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(PaymentNext(
                          fromCuba: false,
                        ));
                      },
                      child: Icon(
                        Icons.add,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Visibility(
                  visible: homeCont.checkUserPackageModel?.data != null,
                  child: SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 3,
                      color: Colors.white,
                      surfaceTintColor: Colors.white,
                      margin: EdgeInsets.all(10),
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Package Details'.tr,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(homeCont
                                            .checkUserPackageModel?.data?.status
                                            ?.toLowerCase() ==
                                        'pending'
                                    ? 'Pending'.tr
                                    : '')
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Start Date:'.tr,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  homeCont.checkUserPackageModel?.data?.status
                                              ?.toLowerCase() ==
                                          'pending'
                                      ? ''
                                      : '${homeCont.checkUserPackageModel?.data?.startDate}',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'End Date:'.tr,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  homeCont.checkUserPackageModel?.data?.status
                                              ?.toLowerCase() ==
                                          'pending'
                                      ? ''
                                      : '${homeCont.checkUserPackageModel?.data?.endDate}',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Remaining Days:'.tr,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  homeCont.checkUserPackageModel?.data?.status
                                              ?.toLowerCase() ==
                                          'pending'
                                      ? ''
                                      : '${homeCont.checkUserPackageModel?.data?.remainingDays}',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: homeCont.allPromoCodesModel?.message?.length,
                    itemBuilder: (context, index) {
                      return PromoCodeCard(
                          promoCode:
                              homeCont.allPromoCodesModel?.message?[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PromoCodeCard extends StatelessWidget {
  final PromoCode? promoCode;

  PromoCodeCard({this.promoCode});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      surfaceTintColor: Colors.white,
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(promoCode?.promoCode ?? ""),
        subtitle: Text("${promoCode?.status}".tr),
        trailing: IconButton(
          icon: Icon(Icons.share),
          onPressed: () {
            // Add share functionality here
            _sharePromoCode(promoCode);
          },
        ),
      ),
    );
  }

  void _sharePromoCode(PromoCode? promoCode) {
    String message =
        '${"Check out this promo code:".tr} ${promoCode?.promoCode} - ${"${promoCode?.status}".tr}';

    Share.share(message,
        subject: '${"Promo Code:".tr} ${promoCode?.promoCode}');
  }
}
