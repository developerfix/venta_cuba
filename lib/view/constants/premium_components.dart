import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'premium_animations.dart';
import 'Colors.dart';

/// Premium interactive components with micro-animations and haptic feedback
class PremiumComponents {

  /// Enhanced button with premium interactions
  static Widget premiumButton({
    required String text,
    required VoidCallback onPressed,
    bool enabled = true,
    Color? backgroundColor,
    Color? textColor,
    double? width,
    double height = 48,
    IconData? icon,
    bool loading = false,
    BorderRadius? borderRadius,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isPressed = false;

        return GestureDetector(
          onTapDown: enabled ? (_) {
            setState(() => isPressed = true);
            HapticFeedback.lightImpact();
          } : null,
          onTapUp: enabled ? (_) {
            setState(() => isPressed = false);
            if (!loading) onPressed();
          } : null,
          onTapCancel: enabled ? () {
            setState(() => isPressed = false);
          } : null,
          child: AnimatedContainer(
            duration: PremiumAnimations.fast,
            curve: PremiumAnimations.smoothCurve,
            width: width,
            height: height.h,
            transform: Matrix4.identity()
              ..scale(isPressed ? 0.97 : 1.0),
            decoration: BoxDecoration(
              color: enabled
                ? (backgroundColor ?? AppColors.k0xFF0254B8)
                : Colors.grey[400],
              borderRadius: borderRadius ?? BorderRadius.circular(12.r),
              boxShadow: [
                if (!isPressed) ...[
                  BoxShadow(
                    color: (backgroundColor ?? AppColors.k0xFF0254B8).withValues(alpha:0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ],
            ),
            child: Center(
              child: loading
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        textColor ?? Colors.white,
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          color: textColor ?? Colors.white,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                      ],
                      Text(
                        text,
                        style: TextStyle(
                          color: textColor ?? Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
            ),
          ),
        );
      },
    );
  }

  /// Premium card with hover and press effects
  static Widget premiumCard({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? elevation,
    BorderRadius? borderRadius,
    Color? backgroundColor,
    bool enabled = true,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isPressed = false;

        return GestureDetector(
          onTapDown: (onTap != null && enabled) ? (_) {
            setState(() => isPressed = true);
            HapticFeedback.selectionClick();
          } : null,
          onTapUp: (onTap != null && enabled) ? (_) {
            setState(() => isPressed = false);
            onTap();
          } : null,
          onTapCancel: (onTap != null && enabled) ? () {
            setState(() => isPressed = false);
          } : null,
          child: AnimatedContainer(
            duration: PremiumAnimations.fast,
            curve: PremiumAnimations.smoothCurve,
            margin: margin ?? EdgeInsets.all(8.w),
            padding: padding ?? EdgeInsets.all(16.w),
            transform: Matrix4.identity()
              ..scale(isPressed ? 0.98 : 1.0),
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.white,
              borderRadius: borderRadius ?? BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:isPressed ? 0.1 : 0.08),
                  blurRadius: isPressed ? 8 : 12,
                  offset: Offset(0, isPressed ? 2 : 4),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
    );
  }

  /// Premium text field with smooth animations
  static Widget premiumTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? prefixIcon,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Function(String)? onChanged,
    bool enabled = true,
    int maxLines = 1,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        return AnimatedContainer(
          duration: PremiumAnimations.medium,
          curve: PremiumAnimations.smoothCurve,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            onChanged: onChanged,
            enabled: enabled,
            maxLines: maxLines,
            onTap: () {
              HapticFeedback.selectionClick();
            },
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.grey[600])
                : null,
              suffixIcon: suffixIcon != null
                ? GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onSuffixTap?.call();
                    },
                    child: Icon(suffixIcon, color: Colors.grey[600]),
                  )
                : null,
              labelStyle: TextStyle(
                color: Colors.grey[600],
                fontSize: 14.sp,
              ),
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14.sp,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.k0xFF0254B8, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.red[400]!, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.red[400]!, width: 2),
              ),
            ),
            // Note: onFocusChange will be handled through FocusNode if needed
          ),
        );
      },
    );
  }

  /// Premium switch with smooth animations
  static Widget premiumSwitch({
    required bool value,
    required Function(bool) onChanged,
    String? label,
    bool enabled = true,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Row(
          children: [
            if (label != null) ...[
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: enabled ? null : Colors.grey[600],
                  ),
                ),
              ),
              SizedBox(width: 16.w),
            ],
            GestureDetector(
              onTap: enabled ? () {
                HapticFeedback.selectionClick();
                onChanged(!value);
              } : null,
              child: AnimatedContainer(
                duration: PremiumAnimations.medium,
                curve: PremiumAnimations.smoothCurve,
                width: 56.w,
                height: 32.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  color: value
                    ? AppColors.k0xFF0254B8
                    : Colors.grey[300],
                  boxShadow: [
                    BoxShadow(
                      color: (value ? AppColors.k0xFF0254B8 : Colors.grey[400]!)
                          .withValues(alpha:0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: AnimatedAlign(
                  duration: PremiumAnimations.medium,
                  curve: PremiumAnimations.smoothCurve,
                  alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 28.w,
                    height: 28.h,
                    margin: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Premium list tile with interactions
  static Widget premiumListTile({
    Widget? leading,
    required Widget title,
    Widget? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    EdgeInsets? contentPadding,
    bool enabled = true,
  }) {
    return PremiumComponents.premiumCard(
      onTap: onTap,
      enabled: enabled,
      padding: contentPadding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          if (leading != null) ...[
            leading,
            SizedBox(width: 16.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                if (subtitle != null) ...[
                  SizedBox(height: 4.h),
                  DefaultTextStyle(
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14.sp,
                    ),
                    child: subtitle,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: 16.w),
            trailing,
          ],
        ],
      ),
    );
  }

  /// Premium floating action button
  static Widget premiumFAB({
    required VoidCallback onPressed,
    IconData icon = Icons.add,
    String? tooltip,
    Color? backgroundColor,
    bool mini = false,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isPressed = false;

        return GestureDetector(
          onTapDown: (_) {
            setState(() => isPressed = true);
            HapticFeedback.mediumImpact();
          },
          onTapUp: (_) {
            setState(() => isPressed = false);
            onPressed();
          },
          onTapCancel: () {
            setState(() => isPressed = false);
          },
          child: AnimatedContainer(
            duration: PremiumAnimations.fast,
            curve: PremiumAnimations.smoothCurve,
            transform: Matrix4.identity()
              ..scale(isPressed ? 0.9 : 1.0),
            child: Container(
              width: mini ? 40.w : 56.w,
              height: mini ? 40.h : 56.h,
              decoration: BoxDecoration(
                color: backgroundColor ?? AppColors.k0xFF0254B8,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (backgroundColor ?? AppColors.k0xFF0254B8)
                        .withValues(alpha:isPressed ? 0.4 : 0.3),
                    blurRadius: isPressed ? 8 : 12,
                    offset: Offset(0, isPressed ? 2 : 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: mini ? 20.sp : 24.sp,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Premium bottom sheet
  static Future<T?> showPremiumBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        duration: PremiumAnimations.medium,
        vsync: Navigator.of(context),
      ),
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              child,
            ],
          ),
        );
      },
    );
  }

  /// Premium snackbar
  static void showPremiumSnackbar({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Color backgroundColor = Colors.black87,
    Duration duration = const Duration(seconds: 3),
    IconData? icon,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).viewPadding.top + 16.h,
        left: 16.w,
        right: 16.w,
        child: TweenAnimationBuilder<double>(
          duration: PremiumAnimations.medium,
          tween: Tween<double>(begin: 0.0, end: 1.0),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              ),
            );
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: 20.sp),
                    SizedBox(width: 12.w),
                  ],
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (actionLabel != null && onActionPressed != null) ...[
                    SizedBox(width: 12.w),
                    TextButton(
                      onPressed: () {
                        overlayEntry.remove();
                        onActionPressed();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      child: Text(actionLabel),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto dismiss after duration
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}