# Cross-Platform Notification Testing Guide

## Overview
This guide helps you test that notifications work properly between iOS and Android devices in your VentaCuba Flutter app.

## What Was Fixed

### 1. **Unified Notification System**
- Created a single `PlatformPushService` that handles both iOS (FCM) and Android (ntfy.sh)
- Removed duplicate notification logic scattered across multiple files
- Fixed platform detection based on device token patterns

### 2. **Device Token Management**
- Android devices now use consistent `venta_cuba_user_{userId}` format for ntfy topics
- iOS devices properly save FCM tokens with platform information
- Added proper platform field in Supabase device_tokens table

### 3. **Cross-Platform Logic**
- The system now correctly detects recipient platform from token pattern
- iOS recipients receive FCM notifications
- Android recipients receive ntfy.sh notifications
- Proper fallback handling for unknown platforms

## Testing Steps

### Step 1: Database Setup
1. Run the SQL migration in your Supabase SQL Editor:
   - Open file: `supabase_migrations/001_device_tokens_platform.sql`
   - Copy and paste the SQL into Supabase SQL Editor
   - Execute the migration

### Step 2: Clear Existing Data
Clear old device tokens to ensure clean testing:
```sql
DELETE FROM device_tokens WHERE user_id = 'YOUR_USER_ID';
```

### Step 3: Test iOS Device
1. **Login on iOS device**
   - Device should request notification permissions
   - Check logs for: `✅ iOS FCM token saved`

2. **Verify token saved**
   ```sql
   SELECT * FROM device_tokens WHERE user_id = 'IOS_USER_ID';
   -- Should show: platform = 'ios', device_token = long FCM token
   ```

### Step 4: Test Android Device  
1. **Login on Android device**
   - Check logs for: `✅ Android ntfy topic saved`

2. **Verify token saved**
   ```sql
   SELECT * FROM device_tokens WHERE user_id = 'ANDROID_USER_ID';
   -- Should show: platform = 'android', device_token = 'venta_cuba_user_XXX'
   ```

### Step 5: Test Cross-Platform Messages

#### Android → iOS
1. Send message from Android to iOS user
2. iOS device should receive FCM notification
3. Check logs for: `🍎 Sending FCM notification to iOS user`

#### iOS → Android
1. Send message from iOS to Android user
2. Android device should receive ntfy notification
3. Check logs for: `🤖 Sending ntfy notification to Android user`

## Debug Checklist

### For iOS Issues:
- [ ] Firebase is initialized in main.dart
- [ ] FCM token is being retrieved
- [ ] Token is saved with platform='ios' in database
- [ ] APNS certificate is configured in Firebase Console
- [ ] Notification permissions are granted

### For Android Issues:
- [ ] ntfy.sh service is accessible from device
- [ ] Topic format is `venta_cuba_user_{userId}`
- [ ] Token is saved with platform='android' in database
- [ ] Local notifications permission is granted

## Common Issues & Solutions

### Issue: iOS not receiving notifications
**Solution**: 
- Check APNS token: Look for `APNS Token:` in logs
- Verify FCM token is saved in database
- Ensure notification permissions are granted in Settings

### Issue: Android not receiving notifications
**Solution**:
- Verify ntfy.sh server is accessible (https://ntfy.sh)
- Check topic subscription in logs
- Ensure device has internet connectivity

### Issue: Platform detection failing
**Solution**:
- Check device_tokens table has proper platform field
- Verify token patterns:
  - iOS: Long alphanumeric string (100+ chars)
  - Android: `venta_cuba_user_XXX` format

## Log Messages to Monitor

### Successful Flow:
```
🔔 Initializing Push Service for user: XXX on iOS/Android
✅ iOS FCM token saved: XXX... / Android ntfy topic saved
🔔 === CROSS-PLATFORM NOTIFICATION ===
🔔 Detected platform: ios/android
✅ FCM/ntfy notification sent successfully
```

### Error Messages:
```
❌ Error getting FCM token
❌ Error saving device token
❌ FCM notification failed
⚠️ No valid FCM token found
```

## Testing Commands

### Check Active Tokens
```sql
SELECT 
  user_id, 
  platform, 
  SUBSTR(device_token, 1, 30) as token_preview,
  is_active,
  updated_at
FROM device_tokens 
WHERE is_active = true
ORDER BY updated_at DESC;
```

### Monitor Recent Notifications
Check your app logs for notification-related messages using these filters:
- iOS: Filter by "FCM" or "🍎"
- Android: Filter by "ntfy" or "🤖"
- General: Filter by "🔔" or "notification"

## Final Verification

✅ **Working Correctly If:**
- Android users can send and receive from iOS users
- iOS users can send and receive from Android users
- Notifications show sender name and message preview
- Tapping notification opens correct chat
- No duplicate notifications are received

## Support

If issues persist after following this guide:
1. Check all log outputs during the notification flow
2. Verify database structure matches migration
3. Ensure both platforms have proper permissions
4. Test with fresh app install on both devices
