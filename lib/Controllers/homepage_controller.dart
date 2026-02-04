import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/Models/ListingModel.dart';
import 'package:venta_cuba/Utils/funcations.dart';
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
  Timer? _favoriteToastTimer;
  int _pendingFavoriteCount = 0;
  bool _hasShownFavoriteToast = false;
  
  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    
    // Also schedule delayed retries to ensure listener is attached
    Future.delayed(Duration(milliseconds: 300), () {
      ensureScrollListenerAttached();
    });
    
    Future.delayed(Duration(milliseconds: 800), () {
      ensureScrollListenerAttached();
    });
    
    _loadSavedLocation();
  }

  @override
  void onClose() {
    _favoriteToastTimer?.cancel();
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void ensureScrollListenerAttached() {
    _attachScrollListenerWithRetry(attempts: 0, maxAttempts: 10);
  }

  void _attachScrollListenerWithRetry({required int attempts, required int maxAttempts}) {
    if (attempts >= maxAttempts) {
      Get.log("❌ HomepageController: Failed to attach scroll listener after $maxAttempts attempts", isError: true);
      return;
    }

    if (!scrollController.hasClients) {
      // Exponential backoff: 100ms, 200ms, 400ms, 800ms...
      final delay = 100 * (1 << attempts); // 2^attempts * 100
      Get.log("📍 HomepageController: ScrollController not ready, retry ${attempts + 1}/$maxAttempts in ${delay}ms");
      
      Future.delayed(Duration(milliseconds: delay), () {
        _attachScrollListenerWithRetry(attempts: attempts + 1, maxAttempts: maxAttempts);
      });
      return;
    }

    // Remove existing listener to avoid duplicates
    try {
      scrollController.removeListener(_onScroll);
      Get.log("📍 HomepageController: Removed existing scroll listener");
    } catch (e) {
      // No existing listener, that's fine
    }

    // Add the listener
    try {
      scrollController.addListener(_onScroll);
      Get.log("✅ HomepageController: Scroll listener attached successfully on attempt ${attempts + 1}");
    } catch (e) {
      Get.log("❌ HomepageController: Error attaching scroll listener: $e", isError: true);
      // Retry on error
      if (attempts < maxAttempts - 1) {
        Future.delayed(Duration(milliseconds: 100), () {
          _attachScrollListenerWithRetry(attempts: attempts + 1, maxAttempts: maxAttempts);
        });
      }
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

  void _onScroll() {
    if (!scrollController.hasClients) {
      Get.log("Homepage: ScrollController has no clients");
      return;
    }

    // Calculate how close we are to the bottom
    final position = scrollController.position;
    final threshold = position.maxScrollExtent - 100;
    
    Get.log("Homepage: Scroll - pos: ${position.pixels.toStringAsFixed(0)}/${position.maxScrollExtent.toStringAsFixed(0)}, "
            "isLoading: ${isLoading.value}, hasMore: ${hasMore.value}, currentPage: ${currentPage.value}, totalItems: ${homepageListings.length}");

    if (position.pixels >= threshold) {
      if (!isLoading.value && hasMore.value) {
        Get.log("Homepage: 🔄 Scroll triggered pagination - Loading more items...");
        loadHomepageData(isLoadMore: true);
      } else {
        if (!hasMore.value) {
          Get.log("Homepage: ⚠️ At scroll threshold but hasMore=false - PAGINATION BLOCKED");
        }
        if (isLoading.value) {
          Get.log("Homepage: ⚠️ At scroll threshold but isLoading=true - PAGINATION BLOCKED");
        }
      }
    }
  }

  /// Main method to load homepage data
  Future<void> loadHomepageData(
      {bool isLoadMore = false, bool forceRefresh = false}) async {
    if (isLoading.value) {
      Get.log("Homepage: Already loading, skipping duplicate call");
      return;
    }

    // Set loading state with guaranteed cleanup in finally block
    isLoading.value = true;
    update();

    try {
      if (!isLoadMore || forceRefresh) {
        currentPage.value = 1;
        homepageListings.clear();
        hasMore.value = true;
        hasInitialLoadCompleted.value = false;
      }

      if (!hasMore.value && !forceRefresh) {
        Get.log("Homepage: No more data available");
        return;
      }

      // Fetch all posts, filter client-side
      Map<String, dynamic> requestData = {
        'user_id': authCont.user?.userId ?? "",
        'type': authCont.isBusinessAccount ? "Business" : "Personal", // Add type parameter
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

      Get.log("Homepage: Fetching starting from page ${currentPage.value}...");

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

        Get.log("Homepage: Fetching page $pageNum (attempt ${pagesFetched + 1}/$maxPagesToFetch)");

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

          // Always increment pagesFetched to avoid stuck pagination
          pagesFetched++;

          if (pageData.isEmpty) {
            Get.log("Homepage: Page $pageNum is empty, reached end");
            reachedEnd = true;
            hasMore.value = false;
            break;
          }

          List<ListingModel> pageListings =
              pageData.map((e) => ListingModel.fromJson(e)).toList();

          pageListings = await _applyLocationFilter(pageListings);

          int addedCount = 0;
          for (var listing in pageListings) {
            String id = listing.id?.toString() ?? '';
            if (id.isNotEmpty && !existingIds.contains(id)) {
              existingIds.add(id);
              filteredResults.add(listing);
              addedCount++;
            }
          }
          
          Get.log("Homepage: Page $pageNum added $addedCount new items after filtering (total: ${filteredResults.length})");

          // Check if we got less than expected items from API
          if (pageData.length < 15) {
            Get.log("Homepage: Page $pageNum returned less than 15 items, likely last page");
            reachedEnd = true;
            hasMore.value = false;
          }
        } else {
          Get.log("Homepage: API error ${response.statusCode}", isError: true);
          // Still increment pagesFetched on error to avoid stuck state
          pagesFetched++;
          
          // On error, allow retry by keeping hasMore true
          if (pagesFetched < maxPagesToFetch) {
            Get.log("Homepage: API error but will allow retry on next scroll");
            hasMore.value = true;
          }
          break;
        }
      }

      Get.log("Homepage: Fetched ${pagesFetched} pages, got ${filteredResults.length} filtered results");

      if (filteredResults.isNotEmpty) {
        homepageListings.addAll(filteredResults);

        if (!isLoadMore && homepageListings.isNotEmpty) {
          homepageListings.shuffle();
        }

        _saveLastLocation();
      }

      // ALWAYS update currentPage based on pagesFetched
      if (pagesFetched > 0) {
        int newPage = currentPage.value + pagesFetched;
        Get.log("Homepage: Updating currentPage from ${currentPage.value} to $newPage");
        currentPage.value = newPage;
      } else {
        Get.log("Homepage: WARNING - No pages fetched, keeping hasMore=true for retry");
        hasMore.value = true; // Allow retry
      }

      // If we fetched max pages but still don't have enough results, allow more scrolling
      if (pagesFetched >= maxPagesToFetch && filteredResults.length < minResultsToShow) {
        Get.log("Homepage: Hit max pages limit with insufficient results, will try more on next scroll");
        hasMore.value = true;
      }

      // If we reached the end but got zero results this time, no more pages
      if (reachedEnd && filteredResults.isEmpty && isLoadMore) {
        Get.log("Homepage: Reached end with no new results");
        hasMore.value = false;
      }
    } catch (e, stackTrace) {
      Get.log("Homepage: Error loading data: $e\n$stackTrace", isError: true);
      // On exception, reset loading and allow retry
      hasMore.value = true; // Allow retry on next scroll
    } finally {
      // GUARANTEED cleanup - this ALWAYS runs
      isLoading.value = false;
      hasInitialLoadCompleted.value = true;
      update();
      Get.log("Homepage: Loading completed. Total: ${homepageListings.length}, hasMore: ${hasMore.value}, page: ${currentPage.value}");
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
    // Find and update only the specific item
    for (int i = 0; i < homepageListings.length; i++) {
      if (homepageListings[i].itemId == itemId) {
        homepageListings[i].isFavorite = newStatus;
        Get.log("✅ Updated favorite status for item $itemId to $newStatus");
        break; // Stop after finding the item
      }
    }
    update(); // This will rebuild the UI with the correct state
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

      // Reset pagination state completely
      resetPaginationState();

      Get.log("📍 HomepageController: Reset to All provinces");

      // Load data with the default location
      await loadHomepageData(forceRefresh: true);
    } catch (e) {
      Get.log("Error resetting to all provinces: $e", isError: true);
    }
  }

  /// Reset pagination state - called when pagination is stuck or after logout
  void resetPaginationState() {
    Get.log("🔄 HomepageController: Resetting pagination state");
    
    // Clear data
    homepageListings.clear();
    
    // Reset all flags
    currentPage.value = 1;
    hasMore.value = true;
    isLoading.value = false; // Critical - ensure loading is not stuck
    hasInitialLoadCompleted.value = false;
    
    // Clear location tracking
    _lastLat = null;
    _lastLng = null;
    _lastRadius = null;
    
    // Force scroll listener re-attachment
    ensureScrollListenerAttached();
    
    update();
    
    Get.log("✅ HomepageController: Pagination state reset complete");
  }
}
