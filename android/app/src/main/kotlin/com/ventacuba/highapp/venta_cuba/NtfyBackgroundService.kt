package com.ventacuba.highapp.venta_cuba

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.*
import androidx.core.app.NotificationCompat
import kotlinx.coroutines.*
import okhttp3.*
import org.json.JSONObject
import java.util.concurrent.TimeUnit

class NtfyBackgroundService : Service() {
    
    companion object {
        const val CHANNEL_ID = "venta_cuba_background"  // For sticky service notification
        const val CHAT_CHANNEL_ID = "venta_cuba_background_chat"  // For background chat notifications
        const val NOTIFICATION_ID = 1001
        const val ACTION_STOP_SERVICE = "STOP_SERVICE"
        const val ACTION_RESTORE_NOTIFICATION = "RESTORE_NOTIFICATION"

        var isRunning = false
            private set
    }
    
    private var webSocket: WebSocket? = null
    private var client: OkHttpClient? = null
    private var serviceScope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    private var userId: String? = null
    private var ntfyServerUrl: String = "https://ntfy.sh"
    
    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        client = OkHttpClient.Builder()
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(0, TimeUnit.SECONDS) // No timeout for WebSocket
            .writeTimeout(30, TimeUnit.SECONDS)
            .build()
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP_SERVICE -> {
                stopForeground(true)
                stopSelf()
                return START_NOT_STICKY
            }
            ACTION_RESTORE_NOTIFICATION -> {
                // Called when app resumes - restore original sticky notification
                restoreServiceNotification()
                return START_STICKY
            }
            else -> {
                userId = intent?.getStringExtra("userId")
                ntfyServerUrl = intent?.getStringExtra("serverUrl") ?: "https://ntfy.sh"

                if (userId != null) {
                    startForegroundService()
                    connectToNtfy()
                }
            }
        }

        // START_STICKY = restart service if killed (perfect for older phones)
        return START_STICKY
    }
    
    private fun startForegroundService() {
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(getString(R.string.service_title)) // Localized title
            .setContentText(getString(R.string.service_text)) // Localized text
            .setSmallIcon(R.drawable.ic_notification)
            .setPriority(NotificationCompat.PRIORITY_MIN) // Lowest priority
            .setCategory(NotificationCompat.CATEGORY_SERVICE) // System service category
            .setShowWhen(false) // Hide timestamp
            .setOngoing(true) // Cannot be dismissed
            .setSound(null) // No sound
            .setVibrate(null) // No vibration
            .setLights(0, 0, 0) // No LED
            .build()
        
        startForeground(NOTIFICATION_ID, notification)
        isRunning = true
    }
    
    private fun connectToNtfy() {
        if (userId == null) return
        
        serviceScope.launch {
            try {
                val topic = "venta_cuba_user_$userId"
                val wsUrl = ntfyServerUrl
                    .replace("https://", "wss://")
                    .replace("http://", "ws://")
                
                val request = Request.Builder()
                    .url("$wsUrl/$topic/ws")
                    .build()
                
                webSocket = client?.newWebSocket(request, object : WebSocketListener() {
                    override fun onOpen(webSocket: WebSocket, response: Response) {
                        println("🔌 Background WebSocket connected")
                        // Keep notification minimal - don't update status
                    }
                    
                    override fun onMessage(webSocket: WebSocket, text: String) {
                        println("📨 Background message: $text")
                        handleMessage(text)
                    }
                    
                    override fun onFailure(webSocket: WebSocket, t: Throwable, response: Response?) {
                        println("❌ Background WebSocket error: ${t.message}")
                        // Keep notification minimal - don't show connection status
                        
                        // Auto-retry after 5 seconds
                        serviceScope.launch {
                            delay(5000)
                            if (isRunning) {
                                connectToNtfy()
                            }
                        }
                    }
                    
                    override fun onClosed(webSocket: WebSocket, code: Int, reason: String) {
                        println("🔌 Background WebSocket closed: $reason")
                        if (isRunning) {
                            // Auto-reconnect if service is still running
                            serviceScope.launch {
                                delay(2000)
                                connectToNtfy()
                            }
                        }
                    }
                })
                
            } catch (e: Exception) {
                println("❌ Error connecting to ntfy: ${e.message}")
                // Keep notification minimal - don't show error status
            }
        }
    }
    
    private fun handleMessage(message: String) {
        // Check if app has actual UI activity (not just background service)
        val hasActiveUI = isAppInForegroundOrVisible()

        if (hasActiveUI) {
            println("🔇 STICKY SERVICE: App has active UI - letting Flutter handle notification")
            return // Let Flutter handle it when UI is active
        }

        // App is in background or terminated - we handle the notification
        println("📨 STICKY SERVICE: App is in background/terminated - showing notification")
        try {
            val json = JSONObject(message)

            // Filter out system messages and connection confirmations
            val messageType = json.optString("event", "")
            if (messageType == "open" || messageType == "keepalive") {
                println("🔇 BACKGROUND: Skipping system message: $messageType")
                return
            }

            // The actual notification data is nested in the 'message' field (just like Flutter)
            val nestedMessage = json.optString("message", "")
            if (nestedMessage.isEmpty()) {
                println("🔇 BACKGROUND: No nested message found")
                return
            }

            // Parse the nested JSON
            val notificationData = JSONObject(nestedMessage)
            println("🔍 BACKGROUND: Parsed notification data: $notificationData")

            // Extract the actual title and body from the nested data
            val title = notificationData.optString("title", "")
            val body = notificationData.optString("message", "")

            // Skip if no title or body
            if (title.isEmpty() || body.isEmpty()) {
                println("🔇 BACKGROUND: Skipping message without content (title: '$title', body: '$body')")
                return
            }

            // Skip if this is not a chat message (check for chat ID in click action)
            val clickAction = notificationData.optString("click", "")
            if (clickAction.isEmpty() || !clickAction.startsWith("myapp://chat/")) {
                println("🔇 BACKGROUND: Skipping non-chat message")
                return
            }

            // App is TERMINATED - sticky service shows notification
            println("📨 STICKY SERVICE: Showing notification (app terminated)")
            showChatNotification(title, body, clickAction)
            
        } catch (e: Exception) {
            println("❌ BACKGROUND: Error parsing message: ${e.message}")
        }
    }
    
    private fun showChatNotification(title: String, body: String, clickAction: String) {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // Create intent for when notification is tapped
        val intent = Intent().apply {
            action = Intent.ACTION_VIEW
            data = android.net.Uri.parse(clickAction.ifEmpty { "myapp://home" })
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }

        val pendingIntent = PendingIntent.getActivity(
            this,
            System.currentTimeMillis().toInt(),
            intent,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
        )

        // UPDATE the existing sticky notification with chat message
        // This shows the message IN the sticky notification (not separate)
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)  // Use SAME channel as sticky
            .setContentTitle("VentaCuba: $title")  // Include app name
            .setContentText(body)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setDefaults(NotificationCompat.DEFAULT_ALL)
            .setOngoing(true)  // Keep sticky
            .setShowWhen(true)  // Show timestamp for messages
            .build()

        // Update the SAME notification ID to replace sticky with message
        notificationManager.notify(NOTIFICATION_ID, notification)

        // DO NOT auto-restore - keep showing the message until app resumes
        // The message will stay visible while app is terminated
        println("📨 Sticky notification updated with message - will persist until app resumes")
    }

    private fun restoreServiceNotification() {
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(getString(R.string.service_title))
            .setContentText(getString(R.string.service_text))
            .setSmallIcon(R.drawable.ic_notification)
            .setPriority(NotificationCompat.PRIORITY_MIN)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setShowWhen(false)
            .setOngoing(true)
            .setSound(null)
            .setVibrate(null)
            .setLights(0, 0, 0)
            .build()

        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(NOTIFICATION_ID, notification)
    }
    
    // Removed updateNotification - keeping persistent notification static and minimal
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            // 1. Service channel for sticky "VentaCuba Active" notification
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                getString(R.string.channel_name), // Localized channel name
                NotificationManager.IMPORTANCE_MIN // Minimal importance
            ).apply {
                description = getString(R.string.channel_description) // Localized description
                setShowBadge(false) // No app badge count
                enableLights(false) // No LED
                enableVibration(false) // No vibration
                setSound(null, null) // No sound
                lockscreenVisibility = Notification.VISIBILITY_SECRET // Hide from lock screen
            }

            // 2. Chat channel for background chat notifications (dismissible)
            val chatChannel = NotificationChannel(
                CHAT_CHANNEL_ID,
                "Background Chat Messages", // Separate channel for chat
                NotificationManager.IMPORTANCE_HIGH // High importance for chat
            ).apply {
                description = "Chat notifications when app is in background"
                setShowBadge(true) // Show badge for chat notifications
                enableLights(true) // LED for chat
                enableVibration(true) // Vibration for chat
                setSound(android.provider.Settings.System.DEFAULT_NOTIFICATION_URI, null) // Default sound
                lockscreenVisibility = Notification.VISIBILITY_PRIVATE // Show on lock screen
            }

            notificationManager.createNotificationChannel(serviceChannel)
            notificationManager.createNotificationChannel(chatChannel)
        }
    }
    
    private fun isAppInForegroundOrVisible(): Boolean {
        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val runningProcesses = activityManager.runningAppProcesses

        // If no running processes, app is definitely terminated
        if (runningProcesses.isNullOrEmpty()) {
            return false
        }

        runningProcesses.forEach { processInfo ->
            if (processInfo.processName == packageName) {
                // Only consider the app "running with UI" if it's in foreground or visible
                return when (processInfo.importance) {
                    ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND,
                    ActivityManager.RunningAppProcessInfo.IMPORTANCE_VISIBLE -> {
                        true // App has active UI
                    }
                    else -> false // App is in background, cached, or only service is running
                }
            }
        }
        return false
    }

    private fun isAppRunning(): Boolean {
        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager

        // Check if any activities are running (not just the service)
        val runningTasks = try {
            @Suppress("DEPRECATION")
            activityManager.getRunningTasks(1)
        } catch (e: Exception) {
            null
        }

        // We should NOT skip notifications based on running tasks alone
        // The only time we skip is when the specific chat is open
        // This will be handled by the Flutter side logic
        // Let the notification through and Flutter will decide

        // Alternative check: Look at running app processes
        val runningProcesses = activityManager.runningAppProcesses

        // If no running processes, app is definitely terminated
        if (runningProcesses.isNullOrEmpty()) {
            println("🔍 STICKY SERVICE: No running processes - app is TERMINATED")
            return false
        }

        runningProcesses.forEach { processInfo ->
            if (processInfo.processName == packageName) {
                // Only consider the app "running" if it's in foreground or visible state
                // SERVICE state alone means only the sticky service is running
                val isRunning = when (processInfo.importance) {
                    ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND -> {
                        println("🔍 STICKY SERVICE: App is in FOREGROUND - let Flutter decide")
                        false // Let Flutter handle the notification logic
                    }
                    ActivityManager.RunningAppProcessInfo.IMPORTANCE_VISIBLE -> {
                        println("🔍 STICKY SERVICE: App is VISIBLE - let Flutter decide")
                        false // Let Flutter handle the notification logic
                    }
                    ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND_SERVICE -> {
                        // This might be just our sticky service - need to check further
                        // Check if MainActivity is alive
                        if (isMainActivityRunning()) {
                            println("🔍 STICKY SERVICE: App has MainActivity running - let Flutter decide")
                            false // Let Flutter handle the notification logic
                        } else {
                            println("🔍 STICKY SERVICE: Only sticky service running - app TERMINATED")
                            false
                        }
                    }
                    ActivityManager.RunningAppProcessInfo.IMPORTANCE_SERVICE -> {
                        // Just service running (likely our sticky service) - app is terminated
                        println("🔍 STICKY SERVICE: Only SERVICE running (app terminated) - SHOW notification")
                        false
                    }
                    ActivityManager.RunningAppProcessInfo.IMPORTANCE_BACKGROUND -> {
                        println("🔍 STICKY SERVICE: App is in BACKGROUND - SHOW notification")
                        false
                    }
                    ActivityManager.RunningAppProcessInfo.IMPORTANCE_TOP_SLEEPING -> {
                        println("🔍 STICKY SERVICE: App is TOP_SLEEPING - SHOW notification")
                        false
                    }
                    ActivityManager.RunningAppProcessInfo.IMPORTANCE_CACHED -> {
                        // App might be cached but check if activities are alive
                        println("🔍 STICKY SERVICE: App is CACHED - checking MainActivity")
                        isMainActivityRunning()
                    }
                    else -> {
                        println("🔍 STICKY SERVICE: App importance: ${processInfo.importance} - app TERMINATED")
                        false
                    }
                }
                return isRunning
            }
        }

        println("🔍 STICKY SERVICE: App process not found - app is TERMINATED")
        return false // App is terminated
    }

    private fun isMainActivityRunning(): Boolean {
        // Additional check to see if MainActivity specifically is running
        try {
            val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            @Suppress("DEPRECATION")
            val runningTasks = activityManager.getRunningTasks(100)

            runningTasks.forEach { task ->
                if (task.baseActivity?.packageName == packageName &&
                    task.baseActivity?.className?.contains("MainActivity") == true) {
                    return true
                }
            }
        } catch (e: Exception) {
            println("🔍 Could not check MainActivity status: ${e.message}")
        }
        return false
    }
    
    override fun onDestroy() {
        super.onDestroy()
        isRunning = false
        serviceScope.cancel()
        webSocket?.close(1000, "Service stopped")
        client = null
    }
    
    override fun onBind(intent: Intent?): IBinder? = null
}