import UIKit
import Flutter
import GoogleMaps  // Add this import
import flutter_local_notifications
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

     FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
    GeneratedPluginRegistrant.register(with: registry)
  }

  if #available(iOS 10.0, *) {
    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
  }

    // Request notification permissions early
    if #available(iOS 10.0, *) {
      let center = UNUserNotificationCenter.current()
      center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
        if granted {
          print("🔥 iOS: Notification permissions granted")
        } else {
          print("🔥 iOS: Notification permissions denied: \(error?.localizedDescription ?? "Unknown error")")
        }
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    GMSServices.provideAPIKey("AIzaSyBx95Bvl9O-US2sQpqZ41GdsHIprnXvJv8")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Handle notification when app is in foreground
  @available(iOS 10.0, *)
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                     willPresent notification: UNNotification,
                                     withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    print("🔥 iOS: Notification received in foreground: \(notification.request.content.title)")
    print("🔥 iOS: Notification body: \(notification.request.content.body)")
    print("🔥 iOS: Notification sound: \(notification.request.content.sound?.description ?? "No sound")")

    // Show notification with badge, sound, and alert - ensure sound is always played
    if #available(iOS 14.0, *) {
      completionHandler([.alert, .badge, .sound, .banner, .list])
    } else {
      completionHandler([.alert, .badge, .sound])
    }
  }

  // Handle notification tap
  @available(iOS 10.0, *)
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                     didReceive response: UNNotificationResponse,
                                     withCompletionHandler completionHandler: @escaping () -> Void) {
    print("🔥 iOS: Notification tapped: \(response.notification.request.content.title)")
    // Handle notification tap here if needed
    completionHandler()
  }

  // Reset badge when app becomes active
  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    print("🔥 iOS: App became active - clearing badge")
    // Reset badge count when app becomes active
    application.applicationIconBadgeNumber = 0

    // Also clear notification center
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
  }

  // Handle app entering background
  override func applicationDidEnterBackground(_ application: UIApplication) {
    super.applicationDidEnterBackground(application)
    print("🔥 iOS: App entered background")
  }

  // Handle app entering foreground
  override func applicationWillEnterForeground(_ application: UIApplication) {
    super.applicationWillEnterForeground(application)
    print("🔥 iOS: App will enter foreground")
  }
}
