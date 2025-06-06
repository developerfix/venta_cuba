import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:venta_cuba/Utils/global_variabel.dart';

class NotificationService {
  Future obtainCredentials() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? getToken = sharedPreferences.getString("access_token");
    int? tokenExpiry = sharedPreferences.getInt("token_expiry");

    // Check if token is valid (not null and not expired)
    bool isTokenValid = getToken != null &&
        tokenExpiry != null &&
        DateTime.now().millisecondsSinceEpoch <
            tokenExpiry - 60000; // 1-minute buffer

    if (!isTokenValid) {
      final accountCredentials = {
        "type": "service_account",
        "project_id": "ventacuba-acf38",
        "private_key_id": "109451b3490863b43c7c47271246f984c1937893",
        "private_key":
            "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCVX4UgPj+8hGUO\nl0nV+vkrG7retVOWXqKt4UxoMxdJN5Qu0KPjSKnwi95SKbAo9koLMgF2E6DWir5Z\n/UIZvkvhUpxnLZA3SeM7CP173L4lFg+8Re1e2l9wz+3OJmXJB7J7BLjssphI1IOp\nXNaLlMAK6zPfLjwz2SooHRmsMH05rHOp8ZA5vO0uM2c9O4BeUCMKtlnbirUu7Ukn\nWKv+HGcTo+/BZ2mIHQ55KJJECxgxdLdOKeOOs7JYe/S0ZaFoH0eSb7bboMSu8Zzr\nLCzJikWNTSkCcXS58KTl3GBuIdQ0PNsBPnZ43bfD/mMOMfwkDg/raq4f3OhGRjcS\n6PNocfvPAgMBAAECggEAKAyd0XjPNvjabZCTq+soDm5Xaqn8WNdTz8IV7eQw7KEZ\nunmXT3OmmMevmqDxyfHLBXhpWuLFX3CAu/kC1YsnpiizpZhaT/CgG6575E9ZrfDd\n1DF9hM6RA1rEnF7AMKe/K2unN1NlMDXGfUzWe0MtQGAynrazToV935Z50SiJEsKo\nghfBzpytYrJUEe+NKpjhnkCfXS2tTyvlLK7IjO5czol+wZc7BQRlL0lnIUa5yVU7\nS7WXn5xbbqqKx5xqWSjfBnR8RH2887v7mCx/xDudmoue13/RWmb6miqescYU+k18\neUtIX4iBoKw+nWxvZT8L6RorPnCFCuicrsP+swr6iQKBgQDRCrjspzHn/fEeO9Qe\nmrxNmu2QJ++i6Pq6pGksmwgoXCPyPHWV4UNKN6T3rZtjOLUBlEvMxyElzDOSn260\nnorjUy9vehEmXHU4UtnM+InuMtEFaQWCUG+u0O+vl+UE01qLLr/Bjbjjo0iaqc9p\nm+2TFu4NzLhxMHdrOQ8eqrnWNwKBgQC27XQCYAhK0Nm0Zbl6G0/Dlm64aTkO7K/v\nRybt7w9LmsXO5alUX3pm6M1H3oiL1cpI/abS4KkfhSqILX74px7juLLRQ00PgnDd\nMf6ll2s8mFWkWfxXx8SXOHZoHfT5Rf9UTjCQLZZ2//QVRx9U4zELBZGbochFw0Hg\nOGTmfjA7KQKBgQC0t7FRHeXeKsJVoeFqp9jcunBgLLZVv1ZrHpGyN0DhK28EDtKU\nxU6YDez3FkX8jFynRd4V5Zy5gYSgYGajjWCC0Dp1BDFpWYsZKz8RnVgY7iOXqshR\ndVpn5kcgJY+fEVz4cGzkVrIdUd8FnoIqSdwkSjF5Cp/1crH6pzR0DaJlFwKBgEGG\nDr7nDTFXXBP9OBHgBJNHqENQFYseBusLrosdzXnEZ8RziVLanGqOSzHKKVkFbF72\n1LHGnW3X8mMzAL8qhasGNq80jz7V932T8eX4tgXPfyXOwc/jk6yjIe6rhFth0lKt\na0HJwpK/nfudLUDn3GJZTU3VBnrOtSMOsD3Lx5T5AoGAdBDdGOp776aFb7VPHx2p\nSo8RiVLcgZSLcSR+YLTGjcv/OuH5bgTpv+1rLg3iSuM7ys5d+oAixMFVtBE3cXZU\ntiy7EXVAQNo8fCeDvetE5oqAa5Rmb+ByY6lxUSvoweIkKFdt5WMlO1H+v8LcZku9\n/zoxY+gF0yHRKamSlWAh75U=\n-----END PRIVATE KEY-----\n",
        "client_email":
            "ventacubenotification@ventacuba-acf38.iam.gserviceaccount.com",
        "client_id": "108296340102093206612",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url":
            "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url":
            "https://www.googleapis.com/robot/v1/metadata/x509/ventacubenotification%40ventacuba-acf38.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com"
      };

      final scopes = [
        'https://www.googleapis.com/auth/firebase.messaging',
      ];

      try {
        final client = await auth.clientViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(accountCredentials),
            scopes);
        final credentials = await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(accountCredentials),
            scopes,
            client);
        client.close();

        notificationAccessToken = credentials.accessToken.data;
        await sharedPreferences.setString(
            "access_token", notificationAccessToken);
        await sharedPreferences.setInt("token_expiry",
            credentials.accessToken.expiry.millisecondsSinceEpoch);
        print('New access token generated: $notificationAccessToken');
        print(
            'Token expiry: ${DateTime.fromMillisecondsSinceEpoch(tokenExpiry ?? 0)}');
      } catch (e) {
        print('Error generating access token: $e');
        rethrow; // Propagate error for debugging
      }
    } else {
      notificationAccessToken = getToken;
      print('Using cached access token');
    }
  }
}
