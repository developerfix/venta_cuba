import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:venta_cuba/Controllers/home_controller.dart';
import '../../Controllers/location_controller.dart';
import '../Chat/custom_text.dart';
import '../Navigation bar/navigation_bar.dart';
import 'package:http/http.dart' as http;

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

  @override
  void initState() {
    initialCameraPosition = CameraPosition(
        target: LatLng(locationCont.lat!, locationCont.lng!), zoom: 14.0);
    super.initState();
  }

  bool isOnMap = false;

  // Test Google Services availability (for professional error handling)
  Future<Map<String, bool>> _testGoogleServices() async {
    Map<String, bool> results = {
      'places': false,
      'geocoding': false,
    };

    try {
      // Test Places API
      final placesTest = await http.get(
        Uri.parse(
            'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=23.1136,-82.3666&radius=1000&key=$kGoogleApiKey'),
      );
      results['places'] = placesTest.statusCode == 200;

      // Test Geocoding API
      final geocodingTest = await http.get(
        Uri.parse(
            'https://maps.googleapis.com/maps/api/geocode/json?latlng=23.1136,-82.3666&key=$kGoogleApiKey'),
      );
      results['geocoding'] = geocodingTest.statusCode == 200;
    } catch (e) {
      // Silent fail - services might be blocked
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Get.back();
            },
            child: Icon(Icons.arrow_back_ios_new)),
        title: Text("Select Location".tr),
      ),
      body: Stack(
        children: [
          GetBuilder<LocationController>(
            builder: (cont) {
              return GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: initialCameraPosition,
                  onMapCreated: (GoogleMapController controller) {
                    cont.googleMapController = controller;
                    markOnCurrentLocation();
                  },
                  markers: markersList);
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 10.h),
                  // Location display
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on,
                            color: Color(0xFF0254B8), size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: GetBuilder<LocationController>(
                            builder: (cont) {
                              return Text(
                                cont.address.isNotEmpty
                                    ? cont.address
                                    : "Fetching location...".tr,
                                style: TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // Radius selector (if enabled)
                  Visibility(
                    visible: widget.isShowRadius,
                    child: GetBuilder<HomeController>(
                      builder: (cont) {
                        return Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Search Radius".tr,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    "${cont.radius.toStringAsFixed(0)} miles",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0254B8),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: const Color(0xFF0254B8),
                                  inactiveTrackColor: Colors.grey[300],
                                  thumbColor: const Color(0xFF0254B8),
                                  thumbShape: CircleThumbShape(thumbRadius: 10),
                                  overlayShape: RoundSliderOverlayShape(
                                      overlayRadius: 20),
                                  overlayColor:
                                      const Color(0xFF0254B8).withOpacity(0.2),
                                ),
                                child: Slider(
                                  value: cont.radius,
                                  min: 1,
                                  max: 500,
                                  divisions: 499,
                                  onChanged: (value) {
                                    isOnMap = false;
                                    cont.radius = value;
                                    cont.update();
                                    updateRadius(
                                      LatLng(
                                          locationCont.lat!, locationCont.lng!),
                                      value,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // Set Location button
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
                              await homeCont.getListing();
                              SharedPreferences sharedPreferences =
                                  await SharedPreferences.getInstance();
                              await sharedPreferences.setString(
                                  "saveAddress", locationCont.address);
                              await sharedPreferences.setString(
                                  "saveRadius", cont.radius.toString());
                              homeCont.addressCont.text = locationCont.address;
                              // Navigate to homepage
                              Get.offAll(() => Navigation_Bar());
                            } else {
                              Get.back();
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Please select a location first'.tr),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: Container(
                          height: 45.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0254B8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: CustomText(
                              text: "Set Location".tr,
                              fontColor: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void markOnCurrentLocation() async {
    // Wait a bit for the map to be ready
    await Future.delayed(Duration(milliseconds: 500));

    if (locationCont.lat != null && locationCont.lng != null) {
      markersList.add(
        Marker(
          markerId: MarkerId("selected_location"),
          position: LatLng(locationCont.lat!, locationCont.lng!),
          infoWindow: InfoWindow(
            title: "Selected Location".tr,
            snippet: locationCont.address,
          ),
        ),
      );

      // Move camera to the selected location
      locationCont.googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(locationCont.lat!, locationCont.lng!),
            zoom: 14.0,
          ),
        ),
      );

      setState(() {});
    }
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

// Custom thumb shape for the slider
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
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required Size sizeWithOverflow,
    required double textScaleFactor,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
  }) {
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
