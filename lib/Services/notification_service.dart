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
        "project_id": "ventacuba-latest-version",
        "private_key_id": "c2f51565dbb152de63dc6a49001db85ad63d531e",
        "private_key":
            "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCSO5UPYe7qSWB0\nkSzKnjxeiPq7MosVl2bbt51k68zrsm9kfgYuNi6Exs1Vx/rju1zB3FVk0MITh7V6\nk5MXxXPtk4i83UnhfAn0+HetJIaRyVcJ0ziSiEv+alBmob3spcu16/XMCdTabE0y\neA0DVAFsvzUaRSV2KCustm4TcdaPV3cqYetBIlZKDqPeQPZPA/sfN7EO5T4sklVh\n+BrMPLGid4tQiI8KB4M0ffrnslFOpTsLopozzM3VQaWqqpp5OODt2q6G0S4jeQLm\n/Jf3CZzFZgW8O2ErsNo0nDzNXrwblAkW/f5xPtfhvNwIEtqeOGX/LqMRVCIdoIsG\nBpq8HCtPAgMBAAECggEADBTVG1i9eujGCctmtnS9SxgpEuc5m3aPPm7cl5Ztrzlm\nP5iz3QSH8ltUYpZrkX4My01vVq1yo1dudGqV1/xtt/6c6PGlZXYwgmc2x/zBC3Fl\nef/T6DNPh/zzmI8bWF5YRrbwb0OOrN8Ov7Ewbgp2NaxUcE+vKSRne1T1IjEhB2WU\nDGO0HzwZhONrogtOsMhVi7QBs/4JJcnC0lcLViKebyS6soZ3qqITT6dPYnH2wmck\nP/XE2rHtw0XDnPIPhCeWNZsQsd7X6KqClrqmYq0E7zDsy0QfM2vAVaQ0DybnpxIS\n4uj8h6m4aahZaR0paLhIsBrZTzOPJC8m8Rty/RyYvQKBgQDHMIBZgAPDe1ovdA9D\nSUla6EDCbjys8QG8QUXZ2nv4nSzawixtcJlcFNV8m28H7fnVKMjIaI7aBP0OBGi+\nnocFlFhRqTAr0CIpvmPi21AZGvWbAxIdmgWYqK6qRVhUxFJ4b5bpdLLZGwBXjhgZ\nYcx9YQxqmBH3iiZ1ixNPbJe8XQKBgQC78IgFBusk23k2GdH4DC5+pNF3gSiMg1E2\nqVHLENF07KaiUAlViDt+lOhwOEtEcW9kUjIHq/PdrUFoBzKWyn8Pd50oFIUNmfrm\nPnPSwumwGXXUybacQ98KKaFSu7RJadmrFZ6RhCKmmqKOqssMOnlRKPiSEVedjPZC\nktUHuGermwKBgD1FJwXgwcecpuYX3iYFYgILlPf5rsJHtA/zSAg2E5IqzsRPnBjh\n3NqdMfoNWb7nrcSqsfArcV2Q0UJBivKvkrrdobkkwMOJVyjd/p2mdmHyj//pluXy\nHaySnn+TqxMP/Io9UP9ovSbZDmbgN3t/QMaEVqxnMIejQCdB62Ov9JClAoGAVNxP\nDrYJByNyn9MY0//sHpMdYfCX9pp02VGq9R4q9bjFpRSuokhZVNa3/bPtiIIP4iSb\nIouqGbZZijd1yFC2/qzr8WUSjwmwGLaqZchM7I8SfXp3UifzVgtmJI1M4rlA59dj\nOiGH4+J+9Bx6gpMEpHjzhEEAZst3hqf2OP4zEXECgYEAtT0Cp00gP9dlCR/R6fyT\nG7bfGd6xrmHcXY6x4MvwiGIMkxoE4QXJFvViKz5fBez+yEEp3fnc24Umk+U+//PK\nts5oeFfQJaoQR+Gx7RIOdJ3JH9809j0pA0kpf6NIq+fLbaqErBLCc4+UFybGWgnu\nzIX3g69uFjIk3/Ow5qig3SY=\n-----END PRIVATE KEY-----\n",
        "client_email":
            "firebase-adminsdk-fbsvc@ventacuba-latest-version.iam.gserviceaccount.com",
        "client_id": "102898629775184873889",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url":
            "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url":
            "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40ventacuba-latest-version.iam.gserviceaccount.com",
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
