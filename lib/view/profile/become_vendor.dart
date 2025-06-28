import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/util/vender_latest.dart';
import 'package:venta_cuba/util/vendor_approved.dart';
import 'package:venta_cuba/view/constants/Colors.dart';

class BecomeVendor extends StatefulWidget {
  const BecomeVendor({super.key});

  @override
  State<BecomeVendor> createState() => _BecomeVendorState();
}

class _BecomeVendorState extends State<BecomeVendor> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 10..h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 18,
                      ),
                    ),
                    Text(
                      'Approvals'.tr,
                      style: TextStyle(
                          fontSize: 20..sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.titleLarge?.color),
                    ),
                    Container(
                      width: 10..w,
                    ),
                  ],
                ),
                SizedBox(
                  height: 50..h,
                ),
                TabBar(
                  labelColor: AppColors.k0xFF0254B8,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18..sp,
                  ),
                  unselectedLabelColor: AppColors.k0xFFA9ABAC,
                  tabs: [
                    SelectionArea(
                      child: Tab(
                        text: 'Latest'.tr,
                      ),
                    ),
                    SelectionArea(
                      child: Tab(
                        text: 'Approved'.tr,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 40..h,
                ),
                Expanded(
                    child: TabBarView(
                  children: [
                    ListView(
                      children: [
                        VendorLatest(),
                        SizedBox(
                          height: 15..h,
                        ),
                        VendorLatest(),
                        SizedBox(
                          height: 15..h,
                        ),
                        VendorLatest(),
                        SizedBox(
                          height: 15..h,
                        ),
                        VendorLatest(),
                        SizedBox(
                          height: 15..h,
                        ),
                      ],
                    ),
                    ListView(
                      children: [
                        VendorApproved(),
                        SizedBox(
                          height: 15..h,
                        ),
                        VendorApproved(),
                        SizedBox(
                          height: 15..h,
                        ),
                        VendorApproved(),
                        SizedBox(
                          height: 15..h,
                        ),
                        VendorApproved(),
                        SizedBox(
                          height: 15..h,
                        ),
                      ],
                    )
                  ],
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
