import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Controllers/location_controller.dart';
import 'package:venta_cuba/view/Search_Places_Screen/search_places_screen.dart';

import '../../Controllers/home_controller.dart';

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
                    Container(
                      height: 45.h,
                      decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              width: 0.5)),
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
                          filled: true,
                          fillColor: Colors.transparent,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                        cursorColor:
                            Theme.of(context).textTheme.bodyLarge?.color,
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
                                  child: Text(
                                    "Use Current Location".tr,
                                    style: TextStyle(
                                      color: Theme.of(context).textTheme.bodyLarge?.color,
                                    ),
                                  )),
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
                                                child: Text(
                                                  cont.placeList[index]["description"].toString(),
                                                  style: TextStyle(
                                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                                  ),
                                                )),
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
                            color: Theme.of(context).textTheme.titleLarge?.color,
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
                                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.grey[700]
                                          : Color(0xffE4E4E4),
                                      child: Center(
                                          child: Icon(
                                        Icons.location_on,
                                        size: 20,
                                        color: Theme.of(context).brightness == Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                      )),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    SizedBox(
                                        width: 250.w,
                                        child: Text(
                                          "${jsonDecode(beforeData[index])['address']}",
                                          style: TextStyle(
                                            color: Theme.of(context).textTheme.bodyLarge?.color,
                                          ),
                                        )),
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
