import 'dart:io';
import 'package:flutter/services.dart';

/// Android Background Service Controller
/// 
/// Controls the native Android background service that maintains
/// persistent WebSocket connection to ntfy.sh even when app is terminated.
/// Perfect for older Chinese phones with less aggressive battery management.
class AndroidBackgroundService {
  static const MethodChannel _channel = MethodChannel('venta_cuba/background_service');
  static bool _isServiceRunning = false;
  
  /// Start the background service for notifications
  static Future<bool> startService({
    required String userId,
    String? customServerUrl,
  }) async {
    if (!Platform.isAndroid) {
      print('⚠️ Servicio en segundo plano solo disponible en Android');
      return false;
    }
    
    try {
      print('🚀 Iniciando servicio en segundo plano de Android para usuario: $userId');
      
      final bool success = await _channel.invokeMethod('startService', {
        'userId': userId,
        'serverUrl': customServerUrl ?? 'https://ntfy.sh',
      });
      
      if (success) {
        _isServiceRunning = true;
        print('✅ Servicio en segundo plano iniciado exitosamente');
        
        // Request battery optimization exemption for better reliability
        await _requestBatteryOptimizationExemption();
      } else {
        print('❌ No se pudo iniciar el servicio en segundo plano');
      }
      
      return success;
    } catch (e) {
      print('❌ Error al iniciar el servicio en segundo plano: $e');
      return false;
    }
  }
  
  /// Stop the background service
  static Future<bool> stopService() async {
    if (!Platform.isAndroid) return true;
    
    try {
      print('🛑 Deteniendo servicio en segundo plano de Android');
      
      final bool success = await _channel.invokeMethod('stopService');
      
      if (success) {
        _isServiceRunning = false;
        print('✅ Servicio en segundo plano detenido exitosamente');
      } else {
        print('❌ No se pudo detener el servicio en segundo plano');
      }
      
      return success;
    } catch (e) {
      print('❌ Error al detener el servicio en segundo plano: $e');
      return false;
    }
  }
  
  /// Check if the background service is running
  static Future<bool> isServiceRunning() async {
    if (!Platform.isAndroid) return false;
    
    try {
      final bool running = await _channel.invokeMethod('isServiceRunning');
      _isServiceRunning = running;
      return running;
    } catch (e) {
      print('❌ Error al verificar el estado del servicio: $e');
      return false;
    }
  }
  
  /// Request battery optimization exemption (important for older Chinese phones)
  static Future<void> _requestBatteryOptimizationExemption() async {
    try {
      print('🔋 Solicitando exención de optimización de batería');
      await _channel.invokeMethod('requestBatteryOptimization');
    } catch (e) {
      print('⚠️ No se pudo solicitar la optimización de batería: $e');
    }
  }
  
  /// Get current service status
  static bool get isRunning => _isServiceRunning;
}