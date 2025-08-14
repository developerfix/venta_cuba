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
        const val CHANNEL_ID = "venta_cuba_background"
        const val NOTIFICATION_ID = 1001
        const val ACTION_STOP_SERVICE = "STOP_SERVICE"
        
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
        try {
            val json = JSONObject(message)
            
            // Filter out system messages and connection confirmations
            val messageType = json.optString("event", "")
            if (messageType == "open" || messageType == "keepalive") {
                println("🔇 BACKGROUND: Skipping system message: $messageType")
                return
            }
            
            // Only process messages that have actual content
            val title = json.optString("title", "")
            val body = json.optString("message", "")
            
            // Skip if no title or body (system messages)
            if (title.isEmpty() || body.isEmpty()) {
                println("🔇 BACKGROUND: Skipping message without content")
                return
            }
            
            // Skip if this is not a chat message (check for chat ID in click action)
            val clickAction = json.optString("click", "")
            if (clickAction.isEmpty() || !clickAction.startsWith("myapp://chat/")) {
                println("🔇 BACKGROUND: Skipping non-chat message")
                return
            }
            
            println("🔴 BACKGROUND SERVICE: Received notification for chat")
            
            // Check if app is in foreground - if so, don't show notification
            if (isAppInForeground()) {
                println("🔇 BACKGROUND: App is in foreground, skipping notification")
                return
            }
            
            // Show notification only when app is in background/terminated
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
        
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(body)
            .setSmallIcon(R.drawable.ic_notification)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setDefaults(NotificationCompat.DEFAULT_ALL)
            .build()
        
        notificationManager.notify(System.currentTimeMillis().toInt(), notification)
    }
    
    // Removed updateNotification - keeping persistent notification static and minimal
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
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
            
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    private fun isAppInForeground(): Boolean {
        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val runningProcesses = activityManager.runningAppProcesses
        
        runningProcesses?.forEach { processInfo ->
            if (processInfo.processName == packageName) {
                return processInfo.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND
            }
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