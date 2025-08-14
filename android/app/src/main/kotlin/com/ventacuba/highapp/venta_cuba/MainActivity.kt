package com.ventacuba.highapp.venta_cuba

import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "venta_cuba/background_service"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startService" -> {
                    val userId = call.argument<String>("userId")
                    val serverUrl = call.argument<String>("serverUrl")
                    
                    if (userId != null && serverUrl != null) {
                        startBackgroundService(userId, serverUrl)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGS", "userId and serverUrl are required", null)
                    }
                }
                "stopService" -> {
                    stopBackgroundService()
                    result.success(true)
                }
                "isServiceRunning" -> {
                    result.success(NtfyBackgroundService.isRunning)
                }
                "requestBatteryOptimization" -> {
                    requestBatteryOptimization()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    private fun startBackgroundService(userId: String, serverUrl: String) {
        val intent = Intent(this, NtfyBackgroundService::class.java).apply {
            putExtra("userId", userId)
            putExtra("serverUrl", serverUrl)
        }
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }
    
    private fun stopBackgroundService() {
        val intent = Intent(this, NtfyBackgroundService::class.java).apply {
            action = NtfyBackgroundService.ACTION_STOP_SERVICE
        }
        startService(intent)
    }
    
    private fun requestBatteryOptimization() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent().apply {
                action = Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
                data = Uri.parse("package:$packageName")
            }
            
            try {
                startActivity(intent)
            } catch (e: Exception) {
                // Fallback to battery optimization settings
                try {
                    val fallbackIntent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                    startActivity(fallbackIntent)
                } catch (e2: Exception) {
                    println("No se pudieron abrir las configuraciones de optimización de batería")
                }
            }
        }
    }
}
