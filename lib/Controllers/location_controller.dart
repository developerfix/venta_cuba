import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
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
  List<geocoding.Location>? locations;
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
      // Show loading dialog
      Get.dialog(
        AlertDialog(
          title: Text("Loading Location..."),
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Getting coordinates..."),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      print(
          "DEBUG: Starting geocoding for: ${placeList[index]["description"]}");

      locations =
          await geocoding.locationFromAddress(placeList[index]["description"]);

      print("DEBUG: Geocoding successful!");
      print("DEBUG: Latitude: ${locations![0].latitude}");
      print("DEBUG: Longitude: ${locations![0].longitude}");

      lat = locations![0].latitude;
      lng = locations![0].longitude;
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

      // Close loading dialog
      Get.back();

      updateLocationList();

      // Show success dialog
      Get.dialog(
        AlertDialog(
          title: Text("✅ Success"),
          content: Text("Location found!\nLat: $lat\nLng: $lng"),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text("OK"),
            ),
          ],
        ),
      );
    } catch (e, stackTrace) {
      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) Get.back();

      print("DEBUG: Geocoding failed with error: $e");
      print("DEBUG: Stack trace: $stackTrace");

      // Show detailed error dialog
      Get.dialog(
        AlertDialog(
          title: Text("❌ Location Error"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Failed to get coordinates for:"),
                SizedBox(height: 5),
                Text("'${placeList[index]["description"]}'",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text("Error Details:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text("$e", style: TextStyle(fontSize: 12, color: Colors.red)),
                SizedBox(height: 10),
                Text("Possible causes:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text("• Internet connection issue"),
                Text("• Google services blocked"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void onChange(String value) {
    if (_sessingToken == null) {
      _sessingToken!.value = uuid.v4();
    }
    getSuggestion(value);
  }

  void getSuggestion(String input) async {
    try {
      String apiKey = "AIzaSyBx95Bvl9O-US2sQpqZ41GdsHIprnXvJv8";
      String baseURL =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request =
          '$baseURL?input=$input&key=$apiKey&sessiontoken=$_sessingToken';

      print("DEBUG: Making Places API request to: $request");

      var response = await http.get(Uri.parse(request));

      print("DEBUG: Places API response status: ${response.statusCode}");
      print("DEBUG: Places API response: ${response.body}");

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body.toString());

        if (jsonResponse["status"] == "OK" ||
            jsonResponse["status"] == "ZERO_RESULTS") {
          placeList = jsonResponse["predictions"] ?? [];
          print("DEBUG: Found ${placeList.length} place suggestions");
          update();
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

      // Show error dialog for Places API failures
      Get.dialog(
        AlertDialog(
          title: Text("🔍 Search Error"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Failed to search for places"),
              SizedBox(height: 10),
              Text("Error: $e",
                  style: TextStyle(fontSize: 12, color: Colors.red)),
              SizedBox(height: 10),
              Text("This might indicate:"),
              Text("• Google Places API is blocked"),
              Text("• Network connectivity issues"),
              Text("• API quota exceeded"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text("OK"),
            ),
          ],
        ),
      );

      placeList = [];
      update();
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
        return Future.error("Your location permissions are denied");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          "Location permissions are permanently denied, we cannot request permissions.");
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
