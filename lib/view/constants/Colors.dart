import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/theme_controller.dart';

class AppColors {
  // Get theme controller instance
  static ThemeController get _themeController {
    try {
      return Get.find<ThemeController>();
    } catch (e) {
      // Return a default instance if not found
      return ThemeController();
    }
  }

  // Theme-aware colors
  static Color get backgroundColor => _themeController.isDarkMode.value
      ? const Color(0xFF121212)
      : const Color(0xFFFFFFFF);

  static Color get surfaceColor => _themeController.isDarkMode.value
      ? const Color(0xFF1E1E1E)
      : const Color(0xFFFFFFFF);

  static Color get cardColor => _themeController.isDarkMode.value
      ? const Color(0xFF2C2C2C)
      : const Color(0xFFFFFFFF);

  static Color get textPrimary => _themeController.isDarkMode.value
      ? const Color(0xFFFFFFFF)
      : const Color(0xFF000000);

  static Color get frameBG => _themeController.isDarkMode.value
      ? const Color(0xFF000000)
      : const Color(0xFFFFFFFF);

  static Color get textSecondary => _themeController.isDarkMode.value
      ? const Color(0xFFB3B3B3)
      : const Color(0xFF6C6C6C);

  static Color get dividerColor => _themeController.isDarkMode.value
      ? const Color(0xFF404040)
      : const Color(0xFFE0E0E0);

  // Theme-aware colors for overlays and shadows
  static Color get black60 => _themeController.isDarkMode.value
      ? const Color(0xFFFFFFFF).withValues(alpha: 0.6)
      : const Color(0xFF000000).withValues(alpha: 0.6);

  static Color get k0xFF6C6C6C => _themeController.isDarkMode.value
      ? const Color(0xFFB3B3B3).withValues(alpha: 0.4)
      : const Color(0xFF6C6C6C).withValues(alpha: 0.4);

  static Color get k1xFF403C3C => _themeController.isDarkMode.value
      ? const Color(0xFFB3B3B3).withValues(alpha: 0.4)
      : const Color(0xFF403C3C).withValues(alpha: 0.4);

  static Color get k1xFFF9E005 =>
      const Color(0xFFF9E005).withValues(alpha: 0.32);

  static Color get k1xFFF0F1F1 => _themeController.isDarkMode.value
      ? const Color(0xFF404040).withValues(alpha: 0.5)
      : const Color(0xFFF0F1F1).withValues(alpha: 0.5);

  // Brand colors that remain consistent
  static Color get k0xFF0254B8 => const Color(0xFF0254B8);
  static Color get k0xFFFB0808 => const Color(0xFFFB0808);
  static Color get k0xFFF9E005 => const Color(0xFFF9E005);

  // Theme-aware neutral colors
  static Color get k0xFFA9ABAC => _themeController.isDarkMode.value
      ? const Color(0xFF6C6C6C)
      : const Color(0xFFA9ABAC);

  static Color get k0xFF403C3C => _themeController.isDarkMode.value
      ? const Color(0xFFB3B3B3)
      : const Color(0xFF403C3C);

  static Color get k0xFFF0F1F1 => _themeController.isDarkMode.value
      ? const Color(0xFF404040)
      : const Color(0xFFF0F1F1);

  static Color get k0xFF6C6B6B => _themeController.isDarkMode.value
      ? const Color(0xFFB3B3B3)
      : const Color(0xFF6C6B6B);

  static Color get k0xFF848484 => _themeController.isDarkMode.value
      ? const Color(0xFF9E9E9E)
      : const Color(0xFF848484);

  static Color get k0xFF9F9F9F => _themeController.isDarkMode.value
      ? const Color(0xFF757575)
      : const Color(0xFF9F9F9F);

  static Color get k0xFFC4C4C4 => _themeController.isDarkMode.value
      ? const Color(0xFF616161)
      : const Color(0xFFC4C4C4);

  static Color get k0xFFD9D9D9 => _themeController.isDarkMode.value
      ? const Color(0xFF424242)
      : const Color(0xFFD9D9D9);

  static Color get k0xFF838385 => _themeController.isDarkMode.value
      ? const Color(0xFF9E9E9E)
      : const Color(0xFF838385);

  // Theme-aware white and black
  static Color get white => _themeController.isDarkMode.value
      ? const Color(0xFF121212)
      : const Color(0xFFFFFFFF);

  static Color get black => _themeController.isDarkMode.value
      ? const Color(0xFFFFFFFF)
      : const Color(0xFF000000);

  // Alias for backward compatibility
  static Color get dynamicWhite => white;
  static Color get dynamicBlack => black;
}
