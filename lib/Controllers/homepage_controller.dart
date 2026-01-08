import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/Models/ListingModel.dart';
import 'package:venta_cuba/main.dart';
import '../api/api_client.dart';

/// Separate controller for Homepage only
/// This controller is isolated from Search and Category screens
class HomepageController extends GetxController {
  final authCont = Get.find<AuthController>();
  ApiClient api = ApiClient(appBaseUrl: baseUrl);

  // Homepage specific state
  List<ListingModel> homepageListings = [];
  ScrollController scrollController = ScrollController();

  RxBool isLoading = false.obs;
  RxBool hasInitialLoadCompleted = false.obs;
  RxInt currentPage = 1.obs;
  RxBool hasMore = true.obs;

  // Location state (homepage specific)
  String address = "";
  String lat = "23.124792615936276";
  String lng = "-82.38597269330762";
  double radius = 500.0;

  // Track last location to detect changes
  String? _lastLat;
  String? _lastLng;
  double? _lastRadius;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    _loadSavedLocation();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

// Add this method to HomepageController
  void ensureScrollListenerAttached() {
    try {
      scrollController.removeListener(_onScroll);
    } catch (e) {
      // Ignore if not attached
    }
    try {
      if (scrollController.hasClients) {
        scrollController.addListener(_onScroll);
        Get.log("📍 HomepageController: Scroll listener re-attached");
      }
    } catch (e) {
      Get.log("Error attaching scroll listener: $e", isError: true);
    }
  }

  /// Load saved location from SharedPreferences
  Future<void> _loadSavedLocation() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Check if location is saved, if not set default to "All provinces"
      String? savedAddress = prefs.getString("saveAddress");
      if (savedAddress == null || savedAddress.isEmpty) {
        // Set default to All provinces (store English key, translate when displaying)
        await prefs.setString("saveAddress", "All provinces");
        await prefs.setString("saveLat", "23.1136");
        await prefs.setString("saveLng", "-82.3666");
        await prefs.setString("saveRadius", "1000.0");
        await prefs.setBool("isAllProvinces", true);
        await prefs.setBool("isAllCities", false);
        await prefs.setStringList("selectedProvinceNames", []);
        await prefs.setStringList("selectedCityNames", []);
      }

      address = prefs.getString("saveAddress") ?? "All provinces";
      lat = prefs.getString("saveLat") ?? "23.1136";
      lng = prefs.getString("saveLng") ?? "-82.3666";
      radius = double.parse(prefs.getString("saveRadius") ?? "1000.0");

      Get.log(
          "📍 HomepageController: Loaded address: $address, isAllProvinces: ${prefs.getBool('isAllProvinces')}");
      update();
    } catch (e) {
      Get.log("Error loading saved location: $e", isError: true);
    }
  }

  /// Refresh location from SharedPreferences (call when returning to homepage)
  Future<void> refreshLocation() async {
    await _loadSavedLocation();

    // Check if location changed
    if (_hasLocationChanged()) {
      Get.log("Homepage: Location changed, reloading data...");
      await loadHomepageData(forceRefresh: true);
    }
  }

  bool _hasLocationChanged() {
    return lat != _lastLat || lng != _lastLng || radius != _lastRadius;
  }

  void _saveLastLocation() {
    _lastLat = lat;
    _lastLng = lng;
    _lastRadius = radius;
  }

  /// Scroll listener for infinite scroll
  void _onScroll() {
    if (!scrollController.hasClients) return;

    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 100) {
      if (!isLoading.value && hasMore.value) {
        Get.log("Homepage: Scroll triggered, loading more...");
        loadHomepageData(isLoadMore: true);
      }
    }
  }

  /// Main method to load homepage data
  Future<void> loadHomepageData(
      {bool isLoadMore = false, bool forceRefresh = false}) async {
    if (isLoading.value) return;

    isLoading.value = true;
    update();

    try {
      if (!isLoadMore || forceRefresh) {
        currentPage.value = 1;
        homepageListings.clear();
        hasMore.value = true;
        hasInitialLoadCompleted.value = false;
      }

      if (!hasMore.value) {
        isLoading.value = false;
        update();
        return;
      }

      // Fetch all posts, filter client-side
      Map<String, dynamic> requestData = {
        'user_id': authCont.user?.userId ?? "",
        'category_id': "",
        'sub_category_id': "",
        'sub_sub_category_id': "",
        'latitude': "",
        'longitude': "",
        'radius': "",
        'min_price': '',
        'max_price': '',
        'search_by_title': ''
      };

      Get.log("Homepage: Fetching page ${currentPage.value}...");

      final int minResultsToShow = isLoadMore ? 5 : 10;
      const int maxPagesToFetch = 10;

      List<ListingModel> filteredResults = [];
      int pagesFetched = 0;
      bool reachedEnd = false;

      Set<String> existingIds = homepageListings
          .map((l) => l.id?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();

      while (filteredResults.length < minResultsToShow &&
          pagesFetched < maxPagesToFetch &&
          !reachedEnd) {
        int pageNum = currentPage.value + pagesFetched;

        Response response = await api.postData(
          "api/getListing?page=$pageNum",
          requestData,
          headers: {
            'Accept': 'application/json',
            'Access-Control-Allow-Origin': "*",
            'Authorization':
                'Bearer ${authCont.user?.accessToken ?? tokenMain ?? ""}'
          },
          showdialog: false,
        );

        if (response.statusCode == 200) {
          List<dynamic> pageData = response.body['data']['data'] ?? [];
          Get.log("Homepage: Page $pageNum returned ${pageData.length} items");

          if (pageData.isEmpty) {
            reachedEnd = true;
            hasMore.value = false;
            break;
          }

          List<ListingModel> pageListings =
              pageData.map((e) => ListingModel.fromJson(e)).toList();

          pageListings = await _applyLocationFilter(pageListings);

          for (var listing in pageListings) {
            String id = listing.id?.toString() ?? '';
            if (id.isNotEmpty && !existingIds.contains(id)) {
              existingIds.add(id);
              filteredResults.add(listing);
            }
          }

          if (pageData.length < 15) {
            reachedEnd = true;
            hasMore.value = false;
          }

          pagesFetched++;
        } else {
          Get.log("Homepage: API error ${response.statusCode}", isError: true);
          break;
        }
      }

      Get.log("Homepage: Got ${filteredResults.length} filtered results");

      if (filteredResults.isNotEmpty) {
        homepageListings.addAll(filteredResults);

        if (!isLoadMore && homepageListings.isNotEmpty) {
          homepageListings.shuffle();
        }

        _saveLastLocation();
      }

      // FIX: Current page ko hamesha update karein agar pages fetch huye hain
      // Chahay filteredResults empty hi kyun na ho
      if (pagesFetched > 0) {
        currentPage.value += pagesFetched;
      }
    } catch (e, stackTrace) {
      Get.log("Homepage: Error loading data: $e\n$stackTrace", isError: true);
    } finally {
      isLoading.value = false;
      hasInitialLoadCompleted.value = true;
      update();
    }
  }

  Future<List<ListingModel>> _applyLocationFilter(
      List<ListingModel> listings) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> selectedProvinceNames =
          prefs.getStringList("selectedProvinceNames") ?? [];
      List<String> selectedCityNames =
          prefs.getStringList("selectedCityNames") ?? [];
      bool isAllProvinces = prefs.getBool("isAllProvinces") ?? true;
      bool isAllCities = prefs.getBool("isAllCities") ?? false;

      if (isAllProvinces || selectedProvinceNames.isEmpty) {
        return listings;
      }

      return listings.where((listing) {
        String? listingAddress = listing.address?.trim();
        if (listingAddress == null ||
            listingAddress.isEmpty ||
            listingAddress == 'null') {
          return false;
        }

        List<String> addressParts =
            listingAddress.split(',').map((s) => s.trim()).toList();
        String? postProvince = addressParts.isNotEmpty ? addressParts[0] : null;
        String? postCity = addressParts.length > 1 ? addressParts[1] : null;

        if (postProvince == null || postProvince.isEmpty) {
          return false;
        }

        bool provinceMatch = selectedProvinceNames.any((selectedProvince) =>
            postProvince.toLowerCase() == selectedProvince.toLowerCase());

        if (!provinceMatch) {
          return false;
        }

        if (isAllCities || selectedCityNames.isEmpty) {
          return true;
        }

        return selectedCityNames.any((selectedCity) =>
            postCity?.toLowerCase() == selectedCity.toLowerCase());
      }).toList();
    } catch (e) {
      Get.log("Homepage: Error in location filter: $e", isError: true);
      return listings;
    }
  }

  void updateFavoriteStatus(String itemId, String newStatus) {
    for (int i = 0; i < homepageListings.length; i++) {
      if (homepageListings[i].itemId == itemId) {
        homepageListings[i].isFavorite = newStatus;
        break;
      }
    }
    update();
  }

  Future<void> forceRefresh() async {
    await _loadSavedLocation();
    await loadHomepageData(forceRefresh: true);
  }

  /// Reset to default "All provinces" state - called on login
  Future<void> resetToAllProvinces() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Set default to All provinces (store English key)
      await prefs.setString("saveAddress", "All provinces");
      await prefs.setString("saveLat", "23.1136");
      await prefs.setString("saveLng", "-82.3666");
      await prefs.setString("saveRadius", "1000.0");
      await prefs.setBool("isAllProvinces", true);
      await prefs.setBool("isAllCities", false);
      await prefs.setStringList("selectedProvinceNames", []);
      await prefs.setStringList("selectedCityNames", []);

      // Also clear lastLat/lastLng to force fresh load
      await prefs.remove("lastLat");
      await prefs.remove("lastLng");
      await prefs.remove("lastRadius");

      // Update local state
      address = "All provinces";
      lat = "23.1136";
      lng = "-82.3666";
      radius = 1000.0;

      // Clear listings and reset pagination
      homepageListings.clear();
      currentPage.value = 1;
      hasMore.value = true;
      hasInitialLoadCompleted.value = false;

      // Clear last location tracking
      _lastLat = null;
      _lastLng = null;
      _lastRadius = null;

      update();

      Get.log("📍 HomepageController: Reset to All provinces");

      Get.log("Homepage: Reset to All provinces");

      // Load data with the default location
      await loadHomepageData();
    } catch (e) {
      Get.log("Error resetting to all provinces: $e", isError: true);
    }
  }
}
