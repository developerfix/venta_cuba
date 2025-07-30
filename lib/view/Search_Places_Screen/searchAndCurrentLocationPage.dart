import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Controllers/location_controller.dart';
import 'package:venta_cuba/view/Search_Places_Screen/search_places_screen.dart';

import '../../Controllers/home_controller.dart';
import '../constants/Colors.dart';

class SearchAndCurrentLocationPage extends StatefulWidget {
  const SearchAndCurrentLocationPage({super.key});

  @override
  State<SearchAndCurrentLocationPage> createState() =>
      _SearchAndCurrentLocationPageState();
}

class _SearchAndCurrentLocationPageState
    extends State<SearchAndCurrentLocationPage> {
  FocusNode focusNode = FocusNode();
  final locationCont = Get.put(LocationController());

  // Debug banner for location search functionality
  Widget _buildLocationSearchDebugBanner() {
    return Container(
      width: double.infinity,
      color: Colors.teal.withOpacity(0.8),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      margin: EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Text(
            "🔥 LOCATION SEARCH DEBUG 🔥",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 3),
          GetBuilder<LocationController>(builder: (cont) {
            return Column(
              children: [
                Row(
                  children: [
                    Icon(
                      cont.placeList.isNotEmpty ? Icons.list : Icons.list_alt,
                      color: cont.placeList.isNotEmpty ? Colors.green : Colors.orange,
                      size: 16,
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        cont.placeList.isNotEmpty 
                          ? "✅ Found ${cont.placeList.length} search results"
                          : "⚠️ No search results yet",
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      cont.showOrHideLocationsList.value ? Icons.visibility : Icons.visibility_off,
                      color: cont.showOrHideLocationsList.value ? Colors.green : Colors.grey,
                      size: 16,
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        cont.showOrHideLocationsList.value 
                          ? "✅ Search results visible"
                          : "ℹ️ Search results hidden",
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: InkWell(
              onTap: () {
                Get.back();
              },
              child: Icon(Icons.arrow_back_ios_new)),
        ),
        body: InkWell(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: SelectionArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Debug banner for location search
                    _buildLocationSearchDebugBanner(),
                    Container(
                      height: 60..h,
                      decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withValues(alpha: 0.3),
                              width: 1)),
                      child: TextField(
                        onTap: () {
                          locationCont.isTextFiled = 0;
                        },
                        focusNode: focusNode,
                        controller:
                            locationCont.locationEditingController.value,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          hintText: "Select location".tr,
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          locationCont.showOrHideLocationsList.value = true;
                          locationCont.onChange(value.toString());
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            focusNode.unfocus();
                            locationCont.getLocation();
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_searching,
                                color: Theme.of(context).unselectedWidgetColor,
                              ),
                              SizedBox(
                                width: 10.w,
                              ),
                              SizedBox(
                                  width: 280.w,
                                  child: Text("Use Current Location".tr)),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        GetBuilder<LocationController>(builder: (cont) {
                          return Visibility(
                            visible: cont.isTextFiled == 0 &&
                                cont.showOrHideLocationsList.value,
                            child: ListView.builder(
                                itemCount: cont.placeList.length,
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                      onTap: () async {
                                        focusNode.unfocus();
                                        await locationCont
                                            .selectLocation(index);
                                        Get.to(SearchPlacesScreen(
                                          isShowRadius: true,
                                        ));
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.only(bottom: 10.h),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(
                                              width: 10.w,
                                            ),
                                            SizedBox(
                                                width: 280.w,
                                                child: Text(cont
                                                    .placeList[index]
                                                        ["description"]
                                                    .toString())),
                                          ],
                                        ),
                                      ));
                                }),
                          );
                        }),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Recent".tr,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ListView.separated(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  focusNode.unfocus();
                                  locationCont.lat =
                                      jsonDecode(beforeData[index])['lat'];
                                  locationCont.lng =
                                      jsonDecode(beforeData[index])['lng'];
                                  locationCont.address =
                                      "${jsonDecode(beforeData[index])['address']}";
                                  Get.log(locationCont.address);
                                  Get.to(
                                      SearchPlacesScreen(isShowRadius: true));
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Color(0xffE4E4E4),
                                      child: Center(
                                          child: Icon(
                                        Icons.location_on,
                                        size: 20,
                                        color: Colors.black,
                                      )),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    SizedBox(
                                        width: 250.w,
                                        child: Text(
                                            "${jsonDecode(beforeData[index])['address']}")),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return SizedBox(
                                height: 10,
                              );
                            },
                            itemCount: beforeData.length),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
