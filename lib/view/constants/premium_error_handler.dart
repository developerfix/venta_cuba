import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'premium_animations.dart';
import 'premium_components.dart';
import 'Colors.dart';

/// Premium error handling system with intelligent recovery and user-friendly messaging
class PremiumErrorHandler {
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  /// Handle API errors with intelligent retry logic
  static Future<T?> handleApiCall<T>({
    required Future<T> Function() apiCall,
    String? customMessage,
    bool showSnackbar = true,
    int maxRetries = maxRetryAttempts,
  }) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      try {
        return await apiCall();
      } on SocketException catch (e) {
        lastException = e;
        if (showSnackbar && attempts == 0) {
          showNetworkError();
        }
        await _delay(attempts);
      } on TimeoutException catch (e) {
        lastException = e;
        if (showSnackbar && attempts == 0) {
          showTimeoutError();
        }
        await _delay(attempts);
      } on FormatException {
        // Don't retry format exceptions
        if (showSnackbar) {
          showDataError();
        }
        return null;
      } catch (e) {
        lastException = e as Exception;
        if (showSnackbar && attempts == 0) {
          showGenericError(customMessage);
        }
        await _delay(attempts);
      }
      attempts++;
    }

    // All retries failed
    if (showSnackbar) {
      showRetryFailedError();
    }

    // Log the last exception for debugging
    if (lastException != null) {
      debugPrint('API call failed after $maxRetries attempts: $lastException');
    }

    return null;
  }

  /// Smart delay with exponential backoff
  static Future<void> _delay(int attempt) async {
    final delayMs = (retryDelay.inMilliseconds * (1 << attempt)).clamp(
      retryDelay.inMilliseconds,
      10000, // Max 10 seconds
    );
    await Future.delayed(Duration(milliseconds: delayMs));
  }

  /// Network connection error
  static void showNetworkError() {
    _showErrorDialog(
      icon: Icons.wifi_off_outlined,
      title: 'Connection Problem'.tr,
      message: 'Please check your internet connection and try again.'.tr,
      actions: [
        _ErrorDialogAction(
          label: 'Retry'.tr,
          onPressed: () {
            Get.back();
            // Trigger a refresh if needed
          },
        ),
        _ErrorDialogAction(
          label: 'Settings'.tr,
          isSecondary: true,
          onPressed: () {
            Get.back();
            _openNetworkSettings();
          },
        ),
      ],
    );
  }

  /// Timeout error
  static void showTimeoutError() {
    _showErrorSnackbar(
      icon: Icons.hourglass_empty_outlined,
      message: 'Request timed out. Please try again.'.tr,
      backgroundColor: Colors.orange[600]!,
    );
  }

  /// Data parsing error
  static void showDataError() {
    _showErrorSnackbar(
      icon: Icons.error_outline,
      message: 'Data format error. Please try again later.'.tr,
      backgroundColor: Colors.red[600]!,
    );
  }

  /// Generic error
  static void showGenericError(String? customMessage) {
    _showErrorSnackbar(
      icon: Icons.warning_outlined,
      message: customMessage ?? 'Something went wrong. Please try again.'.tr,
      backgroundColor: Colors.grey[700]!,
    );
  }

  /// All retries failed
  static void showRetryFailedError() {
    _showErrorDialog(
      icon: Icons.error_outlined,
      title: 'Service Unavailable'.tr,
      message: 'Unable to connect to our servers. Please try again later.'.tr,
      actions: [
        _ErrorDialogAction(
          label: 'OK'.tr,
          onPressed: () => Get.back(),
        ),
      ],
    );
  }

  /// Authentication error
  static void showAuthError() {
    _showErrorDialog(
      icon: Icons.lock_outline,
      title: 'Authentication Required'.tr,
      message: 'Please log in to continue using the app.'.tr,
      actions: [
        _ErrorDialogAction(
          label: 'Login'.tr,
          onPressed: () {
            Get.back();
            // Navigate to login
            Get.offAllNamed('/login');
          },
        ),
        _ErrorDialogAction(
          label: 'Cancel'.tr,
          isSecondary: true,
          onPressed: () => Get.back(),
        ),
      ],
    );
  }

  /// Permission error
  static void showPermissionError(String permission) {
    _showErrorDialog(
      icon: Icons.security_outlined,
      title: 'Permission Required'.tr,
      message: 'This feature requires $permission permission to work properly.'.tr,
      actions: [
        _ErrorDialogAction(
          label: 'Grant Permission'.tr,
          onPressed: () {
            Get.back();
            _openAppSettings();
          },
        ),
        _ErrorDialogAction(
          label: 'Cancel'.tr,
          isSecondary: true,
          onPressed: () => Get.back(),
        ),
      ],
    );
  }

  /// Validation error for forms
  static void showValidationError(List<String> errors) {
    _showErrorDialog(
      icon: Icons.edit_off_outlined,
      title: 'Invalid Input'.tr,
      message: errors.join('\n'),
      actions: [
        _ErrorDialogAction(
          label: 'OK'.tr,
          onPressed: () => Get.back(),
        ),
      ],
    );
  }

  /// File operation error
  static void showFileError(String operation) {
    _showErrorSnackbar(
      icon: Icons.file_present_outlined,
      message: 'Failed to $operation file. Please try again.'.tr,
      backgroundColor: Colors.deepOrange[600]!,
    );
  }

  /// Success message
  static void showSuccess(String message, {IconData? icon}) {
    _showSuccessSnackbar(
      icon: icon ?? Icons.check_circle_outlined,
      message: message,
    );
  }

  /// Premium error dialog with animations
  static void _showErrorDialog({
    required IconData icon,
    required String title,
    required String message,
    required List<_ErrorDialogAction> actions,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: TweenAnimationBuilder<double>(
          duration: PremiumAnimations.medium,
          tween: Tween<double>(begin: 0.0, end: 1.0),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.7 + (0.3 * value),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.all(20.w),
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with animation
                TweenAnimationBuilder<double>(
                  duration: PremiumAnimations.slow,
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 64.w,
                    height: 64.h,
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 32.sp,
                      color: Colors.red[600],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                // Message
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                // Actions
                if (actions.isNotEmpty) ...[
                  if (actions.length == 1) ...[
                    // Single action
                    SizedBox(
                      width: double.infinity,
                      child: PremiumComponents.premiumButton(
                        text: actions[0].label,
                        onPressed: actions[0].onPressed,
                        backgroundColor: AppColors.k0xFF0254B8,
                      ),
                    ),
                  ] else ...[
                    // Multiple actions
                    Row(
                      children: [
                        for (int i = 0; i < actions.length; i++) ...[
                          Expanded(
                            child: PremiumComponents.premiumButton(
                              text: actions[i].label,
                              onPressed: actions[i].onPressed,
                              backgroundColor: actions[i].isSecondary
                                  ? Colors.grey[600]
                                  : AppColors.k0xFF0254B8,
                            ),
                          ),
                          if (i < actions.length - 1) SizedBox(width: 12.w),
                        ],
                      ],
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha:0.5),
    );
  }

  /// Premium error snackbar
  static void _showErrorSnackbar({
    required IconData icon,
    required String message,
    required Color backgroundColor,
  }) {
    final context = Get.context;
    if (context != null && context.mounted) {
      try {
        // Check if overlay exists before showing snackbar
        final overlay = Overlay.maybeOf(context);
        if (overlay != null) {
          PremiumComponents.showPremiumSnackbar(
            context: context,
            message: message,
            backgroundColor: backgroundColor,
            icon: icon,
            duration: const Duration(seconds: 4),
          );
        } else {
          // Fallback to debug print if no overlay available
          debugPrint('Error: $message');
        }
      } catch (e) {
        // Fallback to debug print if snackbar fails
        debugPrint('Error: $message (Failed to show snackbar: $e)');
      }
    } else {
      // Fallback to debug print if no context available
      debugPrint('Error: $message (No context available)');
    }
  }

  /// Premium success snackbar
  static void _showSuccessSnackbar({
    required IconData icon,
    required String message,
  }) {
    final context = Get.context;
    if (context != null && context.mounted) {
      try {
        // Check if overlay exists before showing snackbar
        final overlay = Overlay.maybeOf(context);
        if (overlay != null) {
          PremiumComponents.showPremiumSnackbar(
            context: context,
            message: message,
            backgroundColor: Colors.green[600]!,
            icon: icon,
            duration: const Duration(seconds: 3),
          );
        } else {
          // Fallback to debug print if no overlay available
          debugPrint('Success: $message');
        }
      } catch (e) {
        // Fallback to debug print if snackbar fails
        debugPrint('Success: $message (Failed to show snackbar: $e)');
      }
    } else {
      // Fallback to debug print if no context available
      debugPrint('Success: $message (No context available)');
    }
  }

  /// Open network settings
  static void _openNetworkSettings() {
    // This would typically open system settings
    // For now, we'll show a guidance dialog
    _showErrorDialog(
      icon: Icons.settings_outlined,
      title: 'Network Settings'.tr,
      message: 'Please check your WiFi or mobile data connection in your device settings.'.tr,
      actions: [
        _ErrorDialogAction(
          label: 'OK'.tr,
          onPressed: () => Get.back(),
        ),
      ],
    );
  }

  /// Open app settings
  static void _openAppSettings() {
    // This would typically open app settings
    // Implementation depends on platform
    showGenericError('Please grant the required permissions in your device settings.'.tr);
  }

  /// Handle widget errors with fallback UI
  static Widget errorBoundary({
    required Widget child,
    Widget? fallback,
    Function(FlutterErrorDetails)? onError,
  }) {
    return Builder(
      builder: (context) {
        try {
          return child;
        } catch (e, stackTrace) {
          // Log error
          debugPrint('Widget Error: $e\n$stackTrace');
          onError?.call(FlutterErrorDetails(
            exception: e,
            stack: stackTrace,
            context: ErrorDescription('Widget build error'),
          ));

          // Return fallback UI
          return fallback ?? _buildErrorFallback();
        }
      },
    );
  }

  /// Default error fallback widget
  static Widget _buildErrorFallback() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            'Something went wrong'.tr,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'Please try refreshing the page'.tr,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Initialize global error handling
  static void initialize() {
    // Set up global Flutter error handler
    FlutterError.onError = (FlutterErrorDetails details) {
      // Log error
      debugPrint('Flutter Error: ${details.exception}\n${details.stack}');

      // Show user-friendly message in debug mode
      if (kDebugMode) {
        showGenericError('A widget error occurred. Check console for details.');
      }
    };

    // Handle errors outside of Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('Platform Error: $error\n$stack');
      return true;
    };
  }
}

/// Error dialog action configuration
class _ErrorDialogAction {
  final String label;
  final VoidCallback onPressed;
  final bool isSecondary;

  _ErrorDialogAction({
    required this.label,
    required this.onPressed,
    this.isSecondary = false,
  });
}