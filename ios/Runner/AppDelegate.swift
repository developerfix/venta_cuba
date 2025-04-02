import UIKit
import Flutter
import GoogleMaps  // Add this import
@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
        GMSServices.provideAPIKey("AIzaSyBx95Bvl9O-US2sQpqZ41GdsHIprnXvJv8")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
