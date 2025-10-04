# Fix for Background Notifications Not Showing When App is Terminated

## Problem
The sticky "VentaCuba Active" notification is not showing new messages when the app is terminated/removed from recents.

## Root Cause
In `NtfyBackgroundService.kt` line 146-151, the service checks if Flutter process is running and skips showing notifications if it is. The problem is that `isFlutterProcessRunning()` returns `true` even when the app is in background or cached state.

## Solution

### Option 1: Modify the Logic (Recommended)
Change the condition in `NtfyBackgroundService.kt` line 146-151:

**Current Code (BROKEN):**
```kotlin
// Line 146-151
if (isFlutterAppRunning) {
    println("🔇 STICKY SERVICE: Flutter app is running (foreground/background) - letting Flutter handle notification")
    return // Let Flutter handle notifications when app is running
}
```

**Fixed Code:**
```kotlin
// Only skip if app is in FOREGROUND (not background or cached)
val isAppInForeground = isAppInForegroundOrVisible()
if (isAppInForeground) {
    println("🔇 STICKY SERVICE: App is in foreground - letting Flutter handle notification")
    return // Let Flutter handle notifications only when app is in foreground
}

// App is in background or terminated - we should show notification
println("📨 STICKY SERVICE: App is background/terminated - showing notification")
```

### Option 2: Remove the Check Entirely
Simply comment out lines 146-151 and let the service always show notifications. Flutter's own logic will handle deduplication.

### Option 3: Check for Specific Chat Screen
Only skip notifications if the specific chat is open (more complex implementation).

## How to Apply the Fix

1. Open `android/app/src/main/kotlin/com/ventacuba/highapp/venta_cuba/NtfyBackgroundService.kt`
2. Find line 146-151
3. Replace with the fixed code from Option 1
4. Rebuild the app: `flutter clean && flutter build apk`

## Testing

1. Install the updated APK
2. Login to the app
3. Ensure "VentaCuba Active" notification appears
4. Close the app (remove from recents)
5. Send a message from another user
6. The "VentaCuba Active" notification should update with the message

## Additional Notes

- The service uses notification ID `1001` for the sticky notification
- When a message arrives while app is terminated, it updates the sticky notification with the message content
- When the app resumes, it should restore the original "VentaCuba Active" text

## Current Behavior Flow

1. **App Running in Foreground**: Flutter handles notifications
2. **App in Background**: Currently BROKEN - service skips notifications (should show)
3. **App Terminated**: Should work but may fail if service detects cached process

## Expected Behavior Flow

1. **App Running in Foreground**: Flutter handles notifications (no change)
2. **App in Background**: Background service shows notifications
3. **App Terminated**: Background service shows notifications in sticky notification