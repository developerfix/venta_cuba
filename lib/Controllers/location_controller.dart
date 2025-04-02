import 'dart:convert';
import 'package:flutter/cupertino.dart';
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
    locations =
        await geocoding.locationFromAddress(placeList[index]["description"]);
    lat = locations![0].latitude;
    lng = locations![0].longitude;

    print(locations![0].latitude);
    print(locations![0].longitude);
    address = placeList[index]["description"];

    userPreferences.setSaveHistory(
        jsonEncode({'address': address, 'lat': lat, 'lng': lng}));
    isTextFiled == 0
        ? locationEditingController.value.text = placeList[index]["description"]
        : isTextFiled == 1
            ? authCont.businessCityCont.text = placeList[index]["description"]
            : isTextFiled == 2
                ? authCont.businessProvinceCont.text =
                    placeList[index]["description"]
                : authCont.businessAddressCont.text =
                    placeList[index]["description"];
    updateLocationList();
  }

  void onChange(String value) {
    if (_sessingToken == null) {
      _sessingToken!.value = uuid.v4();
    }
    getSuggestion(value);
  }

  void getSuggestion(String input) async {
    String apiKey = "AIzaSyBx95Bvl9O-US2sQpqZ41GdsHIprnXvJv8";
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$apiKey&sessiontoken=$_sessingToken';

    var response = await http.get(Uri.parse(request));
    print(response.body.toString());
    if (response.statusCode == 200) {
      placeList = jsonDecode(response.body.toString())["predictions"];
      update();
    } else {
      throw Exception("location failed");
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
