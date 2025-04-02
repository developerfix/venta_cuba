import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as Http;
import '../Utils/funcations.dart';
import 'api_checker.dart';

String? tokenMain;
String baseUrl = "https://ventacuba.ca/";

class ApiClient extends GetxService {
  final String appBaseUrl;
  static const String noInternetMessage = 'Connection to API server failed due to internet connection';
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
    token = tokenMain!;
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
  Future<Response> getData(String uri, {Map<String, dynamic>? query, Map<String, String>? headers}) async {
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
    print("???????????????");
    print(tokenMain);
    if (showdialog) {
      showLoading();
    }
    try {
      _mainHeaders = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Access-Control-Allow-Origin': "*",
        'Authorization': 'Bearer $tokenMain'
      };
      print(Uri.parse(appBaseUrl + uri));
      print("body : ${jsonEncode(body)}");
      print("headers : ${jsonEncode(_mainHeaders)}");
      Http.Response _response = await Http.post(
        Uri.parse(appBaseUrl + uri),
        body: jsonEncode(body),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      if (showdialog) {
        Get.back();
      }
      return apichecker.checkApi(respons: _response);
    } catch (e) {
      if (showdialog) {
        Get.back();
      }
      print("error" + e.toString());
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postWithForm(String uri, Map<String, dynamic> body,
      {Map<String, String>? headers,
      bool showdialog = true,
      List<String>? image,
      String imageKey = ''}) async {
    print(body);
    if (showdialog) {
      showLoading();
    }
    try {
      var header = headers ?? _mainHeaders;
      print(header);
      Get.log('url testing ${appBaseUrl + uri}');
      var request = Http.MultipartRequest('POST', Uri.parse(appBaseUrl + uri));
      request.fields.addAll(body.map((key, value) => MapEntry(key, value.toString())));

      request.headers.addAll(header);
        image?.forEach((element) async {
        request.files.add(await Http.MultipartFile.fromPath(imageKey, element));
      });
    
      
      Http.StreamedResponse streamedResponse = await request.send();
      if (showdialog) {
        Get.back();
      }
      var response = await Http.Response.fromStream(streamedResponse);
      print("object......${response.statusCode}");
      print("object......${response.body}");
      return apichecker.checkApi(respons: response);
    } catch (e) {
      if (showdialog) {
        Get.back();
      }
      print("error" + e.toString());
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> putData(String uri, dynamic body, {Map<String, String>? headers}) async {
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
      {Map<String, dynamic>? query, Map<String, String>? headers, Map<String, dynamic>? body}) async {
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
