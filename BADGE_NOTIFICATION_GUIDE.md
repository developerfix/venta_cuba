# iOS Badge Notification Fix Guide

## Problem
Firebase push notifications were being received on iOS but the app icon was not showing a badge (red dot) with the notification count.

## Root Causes Identified
1. **Missing Badge Count in FCM Payload**: The Firebase Cloud Messaging payload didn't include badge count information
2. **Incomplete iOS Notification Configuration**: Local notification settings weren't properly configured for badge display
3. **No APNS-specific Configuration**: Missing Apple Push Notification Service (APNS) specific badge configuration
4. **Missing Badge Management**: No system to track and manage badge counts

## Solutions Implemented

### 1. Enhanced FCM Model (`lib/Notification/fcm_model.dart`)
- Added `ApnsConfig`, `ApnsPayload`, and `Aps` classes to support APNS-specific configuration
- Updated `FCMModel` to include APNS configuration with badge count

### 2. Updated Firebase Messaging Service (`lib/Notification/firebase_messaging.dart`)
- Added badge count management methods:
  - `incrementBadgeCount()`: Increases badge count
  - `resetBadgeCount()`: Resets badge count to 0
  - `getBadgeCount()`: Gets current badge count
  - `setBadgeCount(int count)`: Sets specific badge count
  - `clearBadgeCount()`: Clears badge from app icon

- Enhanced `DarwinNotificationDetails` with proper badge configuration:
  ```dart
  DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
    badgeNumber: currentBadgeCount,
  )
  ```

- Updated `sendNotificationFCM()` to include APNS configuration with badge count

### 3. Enhanced iOS AppDelegate (`ios/Runner/AppDelegate.swift`)
- Added proper notification delegate methods
- Configured foreground notification presentation with badge support
- Added UserNotifications framework import

### 4. Updated Navigation Bar (`lib/view/Navigation bar/navigation_bar.dart`)
- Added automatic badge clearing when user switches to chat tab
- Resets both app icon badge and in-app unread message indicator

### 5. Enhanced App Lifecycle Management (`lib/main.dart`)
- Added badge clearing when app becomes active/foreground
- Integrated with existing app lifecycle observer

## How Badge Management Works

### Automatic Badge Increment
- Badge count automatically increments when notifications are sent via `sendNotificationFCM()`
- Background notifications also increment the badge count
- Each notification increases the badge by 1

### Automatic Badge Clearing
- Badge is cleared when user switches to chat tab in navigation
- Badge is cleared when app becomes active (foreground)
- Badge can be manually cleared using `FCM.clearBadgeCount()`

### Manual Badge Management
```dart
// Increment badge count
FCM.incrementBadgeCount();

// Set specific badge count
FCM.setBadgeCount(5);

// Get current badge count
int currentCount = FCM.getBadgeCount();

// Clear badge completely
FCM.clearBadgeCount();

// Reset badge count to 0
FCM.resetBadgeCount();
```

## Testing the Fix

### Prerequisites
1. Physical iOS device (badges don't show in simulator)
2. App installed via TestFlight or App Store
3. Notification permissions granted

### Test Steps
1. **Send a notification** while app is in background
2. **Check app icon** - should show red badge with number
3. **Open app** - badge should clear automatically
4. **Send multiple notifications** - badge count should increment
5. **Switch to chat tab** - badge should clear immediately

### Debugging
- Check console logs for badge-related messages (prefixed with 🔥)
- Verify APNS token is being retrieved successfully
- Ensure notification permissions include badge permission
- Check that FCM payload includes APNS configuration

## Key Files Modified
- `lib/Notification/fcm_model.dart` - Enhanced FCM payload structure
- `lib/Notification/firebase_messaging.dart` - Added badge management
- `ios/Runner/AppDelegate.swift` - Enhanced iOS notification handling
- `lib/view/Navigation bar/navigation_bar.dart` - Added badge clearing on tab switch
- `lib/main.dart` - Added badge clearing on app resume

## Important Notes
- Badge functionality only works on physical iOS devices
- TestFlight builds support badge notifications
- Badge count is managed locally and resets when app is reinstalled
- APNS configuration is required for proper iOS badge display
- Badge clearing is automatic but can also be triggered manually
