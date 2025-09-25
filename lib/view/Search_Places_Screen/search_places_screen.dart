import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:venta_cuba/Controllers/home_controller.dart';
import '../../Controllers/location_controller.dart';
import '../Chat/custom_text.dart';

class SearchPlacesScreen extends StatefulWidget {
  final bool isShowRadius;

  const SearchPlacesScreen({Key? key, required this.isShowRadius})
      : super(key: key);

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

const kGoogleApiKey = 'AIzaSyBx95Bvl9O-US2sQpqZ41GdsHIprnXvJv8';
final homeScaffoldKey = GlobalKey<ScaffoldState>();

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {
  static CameraPosition initialCameraPosition = CameraPosition(
      target: LatLng(23.124792615936276, -82.38597269330762), zoom: 14.0);
  final homeCont = Get.put(HomeController());
  final locationCont = Get.find<LocationController>();
  Set<Marker> markersList = {};

  double zoomLevel = 7.19;

  // final Mode _mode = Mode.overlay;

  @override
  void initState() {
    initialCameraPosition = CameraPosition(
        target: LatLng(locationCont.lat!, locationCont.lng!), zoom: 14.0);
    //   markOnCurrentLocation();
    super.initState();
  }

  bool isOnMap = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: homeScaffoldKey,
      body: SelectionArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            GetBuilder<LocationController>(builder: (cont) {
              return GoogleMap(
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                zoomGesturesEnabled: false,
                initialCameraPosition: initialCameraPosition,
                //markers: markersList,
                mapType: MapType.normal,
                onMapCreated: (GoogleMapController controller) {
                  cont.googleMapController = controller;
                },
                onTap: (value) {
                  isOnMap = true;
                  print("Good");
                },
                onLongPress: (value) {
                  isOnMap = true;
                  print("Bad");
                },
                onCameraMove: (value) {
                  if (isOnMap) {
                    locationCont.lat = value.target.latitude;
                    locationCont.lng = value.target.longitude;
                    homeCont.lat = locationCont.lat.toString();
                    homeCont.lng = locationCont.lng.toString();
                    Timer(Duration(seconds: 1), () {
                      locationCont.getAddressFromLatLngOnly(
                          value.target.latitude, value.target.longitude);
                    });
                  }
                },
              );
            }),
            Positioned(
              top: 40..h,
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: GetBuilder<LocationController>(builder: (cont) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          padding: EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: IconButton(
                            onPressed: () {
                              Get.back();
                            },
                            icon: const Icon(Icons.arrow_back_ios),
                          ),
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        SizedBox(width: 230, child: Text(cont.address)),
                        SizedBox(
                          width: 10.w,
                        ),
                        Container(
                          height: 50,
                          width: 50,
                          // decoration: BoxDecoration(
                          //     color: Colors.white, shape: BoxShape.circle),
                          // child: IconButton(
                          //   onPressed: () {
                          //     _handlePressButton();
                          //   },
                          //   icon: const Icon(Icons.search_outlined),
                          // ),
                        ),
                      ],
                    );
                  })),
            ),
            // Positioned(
            //   top: 40..h,
            //   right: 20..w,
            //   child: Container(
            //     height: 50,
            //     width: 50,
            //     decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            //     child: IconButton(
            //       onPressed: () {
            //         _handlePressButton();
            //       },
            //       icon: const Icon(Icons.search_outlined),
            //     ),
            //   ),
            // ),
            // Positioned(
            //   top: 40..h,
            //   left: 20..w,
            //   child: Container(
            //     height: 50,
            //     width: 50,
            //     padding: EdgeInsets.only(left: 10),
            //     decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            //     child: IconButton(
            //       onPressed: () {
            //         Get.back();
            //       },
            //       icon: const Icon(Icons.arrow_back_ios),
            //     ),
            //   ),
            // ),
            Visibility(
              visible: widget.isShowRadius,
              child: GetBuilder<HomeController>(
                builder: (cont) {
                  return Center(
                    child: Container(
                      height: 300,
                      width: 300,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF0254B8))),
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 50,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Visibility(
                    visible: widget.isShowRadius,
                    child: GetBuilder<HomeController>(
                      builder: (cont) {
                        return Container(
                          height: 90.h,
                          // width: 300.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Search Range".tr),
                                    Container(
                                      height: 20.h,
                                      width: 100.w,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Colors.black26)),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 5.w),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("${cont.radius.toInt()}"),
                                            Text(
                                              "Km",
                                              style: TextStyle(
                                                  color: Colors.black26),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      activeTrackColor: Colors.white,
                                      thumbColor: Colors.white,
                                      overlayColor: Color(0x29eb1555),
                                      thumbShape: CircleThumbShape(),
                                      overlayShape: RoundSliderOverlayShape(
                                          overlayRadius: 20.0),
                                    ),
                                    child: Slider(
                                        min: 1,
                                        max: 500,
                                        value: cont.radius,
                                        activeColor: const Color(0xFF0254B8),
                                        divisions: 499,
                                        onChanged: (value) {
                                          isOnMap = false;
                                          print(
                                              ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>$isOnMap");
                                          cont.radius = value;
                                          cont.update();
                                          updateRadius(
                                              LatLng(locationCont.lat!,
                                                  locationCont.lng!),
                                              value);
                                        }))
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  GetBuilder<HomeController>(
                    builder: (cont) {
                      return InkWell(
                        onTap: () async {
                          homeCont.lat = locationCont.lat.toString();
                          homeCont.lng = locationCont.lng.toString();
                          if (homeCont.lat != null) {
                            if (widget.isShowRadius) {
                              cont.currentPage.value = 1;
                              cont.hasMore.value = true;
                              cont.listingModelList.clear();
                              
                              // Set flag to shuffle listings when location changes
                              homeCont.forceShuffleAfterLocationChange();
                              
                              await homeCont.getListing();
                              SharedPreferences sharedPreferences =
                                  await SharedPreferences.getInstance();
                              await sharedPreferences.setString(
                                  "saveAddress", locationCont.address);
                              await sharedPreferences.setString(
                                  "saveRadius", cont.radius.toString());
                              homeCont.addressCont.text = locationCont.address;
                              Get.close(2);
                            } else {
                              Get.back();
                            }
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text('Select Place first.'),
                            ));
                          }
                        },
                        child: Container(
                          height: 45.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0254B8),
                            borderRadius: widget.isShowRadius
                                ? BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  )
                                : BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: CustomText(
                              text: "Set Location".tr,
                              fontColor: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 40..h)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  updateRadius(LatLng latLng, double radiusInMiles) {
    LatLng center = latLng;

    // Convert miles to kilometers
    double radiusInKm = radiusInMiles * 1.60934;

    // Calculate LatLngBounds based on the center and radius
    double offset = radiusInKm / 111.32;
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(center.latitude - offset, center.longitude - offset),
      northeast: LatLng(center.latitude + offset, center.longitude + offset),
    );

    // Move the camera to show the specified area
    locationCont.googleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(bounds, 0));
    locationCont.update();
  }
}

//
class CircleThumbShape extends SliderComponentShape {
  final double thumbRadius;

  const CircleThumbShape({
    this.thumbRadius = 12.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required Size sizeWithOverflow,
    /*The missing link*/
    required double textScaleFactor,
    /*And the missing link I missed*/
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
  }) {
    // We need to draw the thumb here
    final Canvas canvas = context.canvas;

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = sliderTheme.thumbColor!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, thumbRadius, fillPaint);
    canvas.drawCircle(center, thumbRadius, borderPaint);
  }
}
