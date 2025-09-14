# VentaCuba Push Notifications Setup Guide

## Overview
This app uses **ntfy.sh** for push notifications instead of Firebase, making it work perfectly in Cuba and other regions where Google services might be restricted.

## How It Works

### Android
- ✅ **Full background support** with native Android service
- ✅ Notifications work even when app is terminated
- ✅ Persistent WebSocket connection to ntfy.sh
- ✅ Automatic reconnection on network changes
- ✅ Battery optimization handling

### iOS  
- ✅ Works when app is in foreground/background
- ⚠️ Limited support when app is terminated (iOS platform restrictions)
- Uses local notifications for display

## Setup Instructions

### 1. Install Dependencies
Run in terminal:
```bash
flutter pub get
```

### 2. Build and Run
```bash
# For Android
flutter run

# For iOS
flutter run
```

### 3. Testing Notifications

#### Method 1: Use Built-in Test Screen
1. Login to the app
2. Go to Profile → Notification Preferences
3. Click "Test Notifications (Debug)" button
4. Use the test interface to:
   - Check service status
   - Initialize notifications
   - Send test notification
   - Stop notifications

#### Method 2: Test from Another Device
1. Login on Device A
2. Login on Device B with different account
3. Send a chat message from Device B to Device A
4. Device A should receive notification

## Automatic Initialization

The app automatically initializes notifications when:
1. **User logs in** - Notifications start automatically
2. **App starts with logged-in user** - Notifications resume
3. **User logs out** - Notifications stop automatically

## Troubleshooting

### Android Issues

#### No Notification Permission Dialog
- On Android 13+ (API 33+), the app will request notification permission
- On older Android versions, notifications are allowed by default
- Check Settings → Apps → VentaCuba → Notifications

#### No Sticky Notification
The persistent notification is minimized by default:
- Check notification settings for "VentaCuba Service" channel
- It should show as "Active" in a collapsed notification

#### Notifications Not Working
1. Open the app
2. Go to Profile → Notification Preferences → Test Notifications
3. Click "Initialize Notifications"
4. Click "Send Test Notification"
5. Check the status indicators

### iOS Issues

#### Background Notifications Limited
- iOS doesn't allow persistent background services
- Notifications work best when app is recently used
- For critical messages, consider opening the app periodically

## Manual Testing with cURL

You can test notifications directly using cURL:

```bash
# Replace USER_ID with actual user ID
curl -d "title=Test" \
     -d "message=Hello from ntfy!" \
     -d "click=myapp://chat/test" \
     https://ntfy.sh/venta_cuba_user_USER_ID
```

## Service Status Indicators

In the Test Screen, you'll see:
- 🟢 **Green checkmark** = Service running
- 🔴 **Red X** = Service not running
- Connection status for WebSocket
- User login status

## Important Notes

1. **Battery Optimization**: On some devices (especially Chinese phones), you may need to:
   - Disable battery optimization for VentaCuba
   - Add app to "Protected apps" list
   - Enable "Auto-start" permission

2. **Network Requirements**: 
   - Requires internet connection
   - Works on WiFi and mobile data
   - Automatically reconnects when network changes

3. **Privacy**: 
   - Notifications use ntfy.sh public server by default
   - Messages are end-to-end encrypted in the app
   - Consider self-hosting ntfy for maximum privacy

## Developer Commands

```bash
# Check logs for notification service
adb logcat | grep -E "ntfy|notification|push"

# Force stop app (to test background service)
adb shell am force-stop com.ventacuba.highapp.venta_cuba

# Check if background service is running
adb shell dumpsys activity services | grep NtfyBackgroundService
```

## Configuration

The notification system can be configured in:
- `lib/Services/RealPush/ntfy_push_service.dart` - Main service logic
- `android/.../NtfyBackgroundService.kt` - Android background service
- `android/.../MainActivity.kt` - Platform channel implementation

## Support

If notifications aren't working:
1. Check the Test Screen for service status
2. Ensure you're logged in
3. Check Android notification permissions
4. Try "Initialize Notifications" button
5. Send a test notification
6. Check device logs for errors
