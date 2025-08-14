import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_webservice/places.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/view/Search_Places_Screen/search_places_screen.dart';
import '../Share Preferences/Share Preferences.dart';
import 'home_controller.dart';

class LocationController extends GetxController {
  final authCont = Get.put(
    AuthController(),
  );
  final homeCont = Get.put(
    HomeController(),
  );
  bool isLocationOn = false;

  @override
  Future<void> onInit() async {
    // TODO: implement onInit
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    isLocationOn = sharedPreferences.getBool('isLocationOn') ?? false;
    super.onInit();
  }

  saveIsLocationOn(bool isValue) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool('isLocationOn', isValue);
  }

  int? isTextFiled;
  String? token;
  String? userID;
  Rx<bool> showOrHideLocationsList = false.obs;
  Rx<String>? _sessingToken = "12".obs;
  List placeList = [];
  var location = "".obs;
  double? lat;
  double? lng;
  String address = "";
  late GoogleMapController googleMapController;
  UserPreferences userPreferences = UserPreferences();

  Rx<TextEditingController> locationEditingController =
      TextEditingController(text: '').obs;
  var uuid = Uuid();

  bool updateLocationList() {
    showOrHideLocationsList.value = !showOrHideLocationsList.value;
    return showOrHideLocationsList.value;
  }

  Future selectLocation(int index) async {
    try {

      print(
          "🔥 📍 STARTING GEOCODING for: ${placeList[index]["description"]}");

      // Use Google Geocoding Web API instead of native geocoding
      String addressToGeocode = placeList[index]["description"];
      String encodedAddress = Uri.encodeComponent(addressToGeocode);
      String geocodingUrl = 'https://maps.googleapis.com/maps/api/geocode/json?address=$encodedAddress&key=AIzaSyBx95Bvl9O-US2sQpqZ41GdsHIprnXvJv8';
      
      print("🔥 📡 Making Geocoding API request to: $geocodingUrl");
      
      var response = await http.get(Uri.parse(geocodingUrl)).timeout(Duration(seconds: 15));
      
      print("🔥 📊 Geocoding API response status: ${response.statusCode}");
      print("🔥 📋 Geocoding API response: ${response.body}");
      
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String status = data['status'] ?? 'UNKNOWN';
        
        print("🔥 📍 Geocoding API status: $status");
        
        if (status == 'OK' && data['results'] != null && data['results'].isNotEmpty) {
          lat = data['results'][0]['geometry']['location']['lat'];
          lng = data['results'][0]['geometry']['location']['lng'];
          
          print("🔥 ✅ GEOCODING SUCCESSFUL!");
          print("🔥 📍 Latitude: $lat");
          print("🔥 📍 Longitude: $lng");
        } else {
          throw Exception('Geocoding failed: $status - ${data['error_message'] ?? 'No coordinates found'}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: Geocoding API request failed');
      }

      address = placeList[index]["description"];

      userPreferences.setSaveHistory(
          jsonEncode({'address': address, 'lat': lat, 'lng': lng}));
      isTextFiled == 0
          ? locationEditingController.value.text =
              placeList[index]["description"]
          : isTextFiled == 1
              ? authCont.businessCityCont.text = placeList[index]["description"]
              : isTextFiled == 2
                  ? authCont.businessProvinceCont.text =
                      placeList[index]["description"]
                  : authCont.businessAddressCont.text =
                      placeList[index]["description"];

      updateLocationList();
    } catch (e, stackTrace) {
      print("🔥 ❌ GEOCODING FAILED with error: $e");
      print("🔥 🔍 Stack trace: $stackTrace");
    }
  }

  void onChange(String value) {
    if (_sessingToken == null) {
      _sessingToken!.value = uuid.v4();
    }
    getSuggestion(value);
  }

  void getSuggestion(String input) async {
    // Don't search if input is empty or too short
    if (input.trim().isEmpty || input.trim().length < 2) {
      placeList = [];
      update();
      return;
    }
    
    try {
      print("🔥 🔍 STARTING PLACES API SEARCH for: '$input'");
      String apiKey = "AIzaSyBx95Bvl9O-US2sQpqZ41GdsHIprnXvJv8";
      String baseURL =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request =
          '$baseURL?input=$input&key=$apiKey&sessiontoken=$_sessingToken';

      print("🔥 📡 Making Places API request to: $request");

      var response = await http.get(Uri.parse(request)).timeout(Duration(seconds: 10));

      print("🔥 📊 Places API response status: ${response.statusCode}");
      print("🔥 📋 Places API response: ${response.body}");

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body.toString());
        String status = jsonResponse["status"] ?? "UNKNOWN";
        
        print("🔥 📍 Places API status: $status");

        if (status == "OK" || status == "ZERO_RESULTS") {
          placeList = jsonResponse["predictions"] ?? [];
          print("🔥 ✅ Found ${placeList.length} place suggestions");
          if (placeList.isEmpty && status == "ZERO_RESULTS") {
            print("🔥 ⚠️ Google Places returned ZERO_RESULTS for: '$input'");
          }
          update();
        } else if (status == "REQUEST_DENIED") {
          print("🔥 ❌ Google Places API: REQUEST_DENIED - API key issue or service blocked");
          placeList = [];
          update();
          // Show user-visible error
          _showLocationError("Google Places API blocked or invalid API key");
        } else if (status == "OVER_QUERY_LIMIT") {
          print("🔥 ❌ Google Places API: OVER_QUERY_LIMIT - rate limit exceeded");
          placeList = [];
          update();
          _showLocationError("Too many location requests, try again later");
        } else {
          print("DEBUG: Places API error status: ${jsonResponse["status"]}");
          print(
              "DEBUG: Error message: ${jsonResponse["error_message"] ?? 'No message'}");
          throw Exception("Places API error: ${jsonResponse["status"]}");
        }
      } else {
        print("DEBUG: HTTP error ${response.statusCode}: ${response.body}");
        throw Exception(
            "HTTP ${response.statusCode}: Places API request failed");
      }
    } catch (e, stackTrace) {
      print("DEBUG: Places API exception: $e");
      print("DEBUG: Stack trace: $stackTrace");

      placeList = [];
      update();
    }
  }

  // Show user-visible location error  
  void _showLocationError(String message) {
    try {
      Get.snackbar(
        "🔥 Location Error",
        message,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: Duration(seconds: 5),
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      print("🔥 ❌ Could not show snackbar: $e");
    }
  }

  // final places =
  //     GoogleMapsPlaces(apiKey: 'AIzaSyDe084ESzLxX0Pn2IHfmqAmDV96s19OVoU');

  Future<void> getLocation() async {
    LocationPermission permission;
    bool servicesEnabled = await Geolocator.isLocationServiceEnabled();

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Your location permissions are denied".tr);
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          "Location permissions are permanently denied, we cannot request permissions".tr);
    }
    print('going to get the location');
    permission = await Geolocator.requestPermission();

    locationUpdate();
  }

  locationUpdate() async {
    try {
      Position? position = await Geolocator.getCurrentPosition();
      homeCont.lat = position.latitude.toString();
      homeCont.lng = position.longitude.toString();
      lat = position.latitude;
      lng = position.longitude;
      getAddressFromLatLng(position.latitude, position.longitude);
    } catch (e)
    // ignore: empty_catches
    {}
  }

  getAddressFromLatLng(double lat, double lng) async {
    String _host = 'https://maps.google.com/maps/api/geocode/json';
    final url =
        '$_host?key=AIzaSyBx95Bvl9O-US2sQpqZ41GdsHIprnXvJv8&language=en&latlng=$lat,$lng';

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map data = jsonDecode(response.body);
      String _formattedAddress = data["results"][0]["formatted_address"];
      print("response ==== $_formattedAddress");
      address = _formattedAddress;
      Get.to(SearchPlacesScreen(isShowRadius: true));
      update();
    } else {}
  }

  getAddressFromLatLngOnly(double lat, double lng) async {
    String _host = 'https://maps.google.com/maps/api/geocode/json';
    final url =
        '$_host?key=AIzaSyBx95Bvl9O-US2sQpqZ41GdsHIprnXvJv8&language=en&latlng=$lat,$lng';

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map data = jsonDecode(response.body);
      String _formattedAddress = data["results"][0]["formatted_address"];
      print("response ==== $_formattedAddress");
      address = _formattedAddress;
      update();
    } else {}
  }

  getLatLngFromAddress(double lat, double lng) async {
    String _host = 'https://maps.google.com/maps/api/geocode/json';
    final url =
        '$_host?key=AIzaSyBx95Bvl9O-US2sQpqZ41GdsHIprnXvJv8&language=en&latlng=$lat,$lng';

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map data = jsonDecode(response.body);
      String _formattedAddress = data["results"][0]["formatted_address"];
      print("response ==== $_formattedAddress");
      homeCont.address = _formattedAddress;
      homeCont.update();
      homeCont.listingModelList.clear();
      homeCont.getListing();
    } else {}
  }
}
