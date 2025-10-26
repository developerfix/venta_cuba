import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as Http;
import '../Utils/funcations.dart';
import 'api_checker.dart';

String? tokenMain;
String baseUrl = "https://ventacuba.co/";

class ApiClient extends GetxService {
  final String appBaseUrl;
  static const String noInternetMessage =
      'Connection to API server failed due to internet connection';
  final int timeoutInSeconds = 60;
  String? token;
  Map<String, String> _mainHeaders = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    'Access-Control-Allow-Origin': "*",
  };
  ApiClient({
    required this.appBaseUrl,
  }) {
    if (tokenMain != null) {
      updateHeader(
        tokenMain!,
      );
    }
  }
  void updateHeader(
    String token,
  ) {
    tokenMain = token;
    _mainHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Access-Control-Allow-Origin': "*",
      'Authorization': 'Bearer $token'
    };
    // print('/////////////////////////////////////');
    // print(_mainHeaders);
  }

  ApiChecker apichecker = ApiChecker();
  Future<Response> getData(String uri,
      {Map<String, dynamic>? query, Map<String, String>? headers}) async {
    try {
      final url = Uri.parse(appBaseUrl + uri);
      final newURI = url.replace(queryParameters: query);
      print("Url:  $newURI");
      Http.Response _response = await Http.get(
        newURI,
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return apichecker.checkApi(
        respons: _response,
      );
    } catch (e) {
      print("eroor : $e");
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postData(String uri, dynamic body,
      {Map<String, String>? headers, bool showdialog = true}) async {
    print("🔥 postData tokenMain: $tokenMain");
    if (uri.contains("getListing")) {
      print("🚨 CALLING getListing API from: ${StackTrace.current.toString().split('\n')[1]}");
    }
    if (showdialog) {
      showLoading();
    }
    try {
      // Start with default headers
      Map<String, String> finalHeaders = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Access-Control-Allow-Origin': "*",
        'Authorization': 'Bearer ${tokenMain ?? ""}'
      };

      // If custom headers are provided, merge them and let them override defaults
      if (headers != null) {
        finalHeaders.addAll(headers);
      }

      print(Uri.parse(appBaseUrl + uri));
      print("body : ${jsonEncode(body)}");
      print("Final headers : ${jsonEncode(finalHeaders)}");
      Http.Response _response = await Http.post(
        Uri.parse(appBaseUrl + uri),
        body: jsonEncode(body),
        headers: finalHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      if (showdialog) {
        Get.back();
      }

      // EMERGENCY FIX: Redirect to getSellerListingByStatus when no location selected
      if (uri.contains("getListing") && body != null && body is Map) {
        String? lat = body['latitude']?.toString();
        String? lng = body['longitude']?.toString();
        String? userId = body['user_id']?.toString();

        // Check if no location is selected (empty lat/lng)
        if ((lat == null || lat.isEmpty) && (lng == null || lng.isEmpty) && userId != null && userId.isNotEmpty) {
          print("🚨 EMERGENCY FIX: No location selected, redirecting to getSellerListingByStatus API");
          print("🚨 Original request: ${jsonEncode(body)}");

          try {
            // Make a call to getSellerListingByStatus to get user's own listings
            String authToken = finalHeaders['Authorization'] ?? '';
            print("🚨 Making getSellerListingByStatus API call...");

            Http.Response userListingsResponse = await Http.post(
              Uri.parse(appBaseUrl + "api/getSellerListingByStatus"),
              headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                'Accept': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Authorization': authToken,
              },
              body: jsonEncode({}), // Empty body for all active listings
            ).timeout(Duration(seconds: timeoutInSeconds));

            print("🚨 getSellerListingByStatus response status: ${userListingsResponse.statusCode}");

            if (userListingsResponse.statusCode == 200) {
              var userResponseData = jsonDecode(userListingsResponse.body);
              print("🚨 User listings API response: ${userResponseData['status']}");

              if (userResponseData['status'] == true && userResponseData['data'] != null) {
                List<dynamic> userListings = userResponseData['data'];
                print("🚨 Found ${userListings.length} user listings");

                // Log and fix the isFavorite status of user's own posts
                for (var listing in userListings) {
                  String postId = listing['id']?.toString() ?? 'unknown';
                  String isFavorite = listing['is_favorite']?.toString() ?? 'unknown';
                  print("🚨 User's post ID=$postId, isFavorite=$isFavorite");

                  // Fix: User's own posts should never be marked as favorite
                  // Add both field names since model expects camelCase but API uses snake_case
                  listing['is_favorite'] = "0";  // snake_case for API compatibility
                  listing['isFavorite'] = "0";   // camelCase for ListingModel
                  print("🚨 Fixed: User's post ID=$postId now has is_favorite=0 and isFavorite=0");
                }

                // Convert to the same format as getListing API response
                var formattedResponse = {
                  "status": true,
                  "data": {
                    "current_page": 1,
                    "data": userListings,
                    "first_page_url": "https://ventacuba.co/api/getListing?page=1",
                    "from": 1,
                    "last_page": 1,
                    "last_page_url": "https://ventacuba.co/api/getListing?page=1",
                    "links": [
                      {"url": null, "label": "&laquo; Previous", "active": false},
                      {"url": "https://ventacuba.co/api/getListing?page=1", "label": "1", "active": true},
                      {"url": null, "label": "Next &raquo;", "active": false}
                    ],
                    "next_page_url": null,
                    "path": "https://ventacuba.co/api/getListing",
                    "per_page": 15,
                    "prev_page_url": null,
                    "to": userListings.length,
                    "total": userListings.length
                  }
                };

                // Create a simpler response by using the original response structure
                var originalData = jsonDecode(_response.body);
                originalData['data']['data'] = userListings;
                originalData['data']['total'] = userListings.length;
                originalData['data']['to'] = userListings.length;
                originalData['data']['last_page'] = 1;

                _response = Http.Response(
                  jsonEncode(originalData),
                  _response.statusCode,
                  headers: _response.headers,
                );

                print("🚨 Successfully redirected to user's own listings");
              } else {
                print("🚨 getSellerListingByStatus API returned error or no data");
              }
            } else {
              print("🚨 getSellerListingByStatus API failed with status: ${userListingsResponse.statusCode}");
            }
          } catch (e) {
            print("🚨 Error calling getSellerListingByStatus: $e");
          }
        }
      }

      return apichecker.checkApi(respons: _response, showUserError: showdialog);
    } catch (e) {
      if (showdialog) {
        Get.back();
      }
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postWithForm(String uri, Map<String, dynamic> body,
      {Map<String, String>? headers,
      bool showdialog = true,
      List<String>? image,
      String imageKey = ''}) async {
    if (showdialog) {
      showLoading();
    }
    try {
      // Start with default headers for multipart form data
      // Note: Content-Type will be automatically set by MultipartRequest
      Map<String, String> finalHeaders = {
        'Accept': 'application/json',
        'Access-Control-Allow-Origin': "*",
      };

      // Add Authorization header from tokenMain if available and not overridden
      if (tokenMain != null && tokenMain!.isNotEmpty) {
        finalHeaders['Authorization'] = 'Bearer $tokenMain';
      }

      // If custom headers are provided, merge them and let them override defaults
      if (headers != null) {
        finalHeaders.addAll(headers);
      }

      var request = Http.MultipartRequest('POST', Uri.parse(appBaseUrl + uri));
      request.fields
          .addAll(body.map((key, value) => MapEntry(key, value.toString())));

      request.headers.addAll(finalHeaders);
      if (image != null) {
        for (String element in image) {
          // Check if file exists before creating multipart file
          File tempFile = File(element);
          if (await tempFile.exists()) {
            var file = await Http.MultipartFile.fromPath(imageKey, element);
            request.files.add(file);
          } else {}
        }
      }

      Http.StreamedResponse streamedResponse = await request.send();
      if (showdialog) {
        Get.back();
      }
      var response = await Http.Response.fromStream(streamedResponse);
      return apichecker.checkApi(respons: response, showUserError: showdialog);
    } catch (e) {
      if (showdialog) {
        Get.back();
      }
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> putData(String uri, dynamic body,
      {Map<String, String>? headers}) async {
    try {
      Http.Response _response = await Http.put(
        Uri.parse(appBaseUrl + uri),
        body: jsonEncode(body),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return apichecker.checkApi(respons: _response);
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> deleteData(String uri,
      {Map<String, dynamic>? query,
      Map<String, String>? headers,
      Map<String, dynamic>? body}) async {
    try {
      final url = Uri.parse(appBaseUrl + uri);
      final newURI = url.replace(queryParameters: query);
      print("Url:  $newURI");
      print("body:  $body");
      Http.Response _response = await Http.delete(
        url,
        body: jsonEncode(body),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return apichecker.checkApi(
        respons: _response,
      );
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }
}
