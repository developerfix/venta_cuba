import 'package:flutter/material.dart';

/// Premium animation configurations and utilities for ultra-smooth user experience
class PremiumAnimations {
  // Animation durations optimized for premium feel
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 450);
  static const Duration slower = Duration(milliseconds: 600);

  // Premium easing curves for natural motion
  static const Curve smoothCurve = Curves.easeOutCubic;
  static const Curve bouncyCurve = Curves.elasticOut;
  static const Curve sharpCurve = Curves.easeInOutCubic;

  /// Custom page transition with slide and fade
  static Route<T> createSlideRoute<T>(
    Widget page, {
    RouteSettings? settings,
    Offset beginOffset = const Offset(1.0, 0.0),
    Duration duration = medium,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: Duration(milliseconds: duration.inMilliseconds ~/ 1.5),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Primary slide animation
        final slideAnimation = Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: smoothCurve,
        ));

        // Fade animation
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Interval(0.0, 0.8, curve: smoothCurve),
        ));

        // Scale animation for subtle depth
        final scaleAnimation = Tween<double>(
          begin: 0.95,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: smoothCurve,
        ));

        // Secondary animation for current page
        final secondarySlideAnimation = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.3, 0.0),
        ).animate(CurvedAnimation(
          parent: secondaryAnimation,
          curve: smoothCurve,
        ));

        final secondaryFadeAnimation = Tween<double>(
          begin: 1.0,
          end: 0.8,
        ).animate(CurvedAnimation(
          parent: secondaryAnimation,
          curve: smoothCurve,
        ));

        return Stack(
          children: [
            // Current page sliding out
            if (secondaryAnimation.status != AnimationStatus.dismissed)
              SlideTransition(
                position: secondarySlideAnimation,
                child: FadeTransition(
                  opacity: secondaryFadeAnimation,
                  child: child,
                ),
              ),
            // New page sliding in
            SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: child,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Hero transition wrapper for premium feel
  static Widget heroWrapper({
    required String tag,
    required Widget child,
    bool enabled = true,
  }) {
    if (!enabled) return child;

    return Hero(
      tag: tag,
      transitionOnUserGestures: true,
      flightShuttleBuilder: (context, animation, flightDirection, fromContext, toContext) {
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.95,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: smoothCurve,
          )),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Staggered list animation for premium lists
  static Widget staggeredListItem({
    required Widget child,
    required int index,
    Duration delay = const Duration(milliseconds: 50),
    Duration duration = medium,
    Offset slideOffset = const Offset(0, 30),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration + (delay * index),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: smoothCurve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: slideOffset * (1 - value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Premium button press animation
  static Widget premiumButton({
    required Widget child,
    required VoidCallback onPressed,
    bool enabled = true,
    Color? rippleColor,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isPressed = false;

        return GestureDetector(
          onTapDown: enabled ? (_) {
            setState(() => isPressed = true);
          } : null,
          onTapUp: enabled ? (_) {
            setState(() => isPressed = false);
            onPressed();
          } : null,
          onTapCancel: enabled ? () {
            setState(() => isPressed = false);
          } : null,
          child: AnimatedContainer(
            duration: fast,
            curve: smoothCurve,
            transform: Matrix4.identity()
              ..scale(isPressed ? 0.95 : 1.0),
            child: AnimatedOpacity(
              duration: fast,
              opacity: enabled ? (isPressed ? 0.8 : 1.0) : 0.6,
              child: child,
            ),
          ),
        );
      },
    );
  }

  /// Smooth loading shimmer effect
  static Widget shimmerLoading({
    required Widget child,
    Color? baseColor,
    Color? highlightColor,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0 + 3 * value, 0.0),
              end: Alignment(1.0 + 3 * value, 0.0),
              colors: [
                baseColor ?? Colors.grey[300]!,
                highlightColor ?? Colors.grey[100]!,
                baseColor ?? Colors.grey[300]!,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: child,
    );
  }

  /// Scale animation for list items
  static Widget scaleOnTap({
    required Widget child,
    required VoidCallback onTap,
    double scaleFactor = 0.95,
    Duration duration = fast,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isPressed = false;

        return GestureDetector(
          onTapDown: (_) => setState(() => isPressed = true),
          onTapUp: (_) {
            setState(() => isPressed = false);
            onTap();
          },
          onTapCancel: () => setState(() => isPressed = false),
          child: AnimatedScale(
            scale: isPressed ? scaleFactor : 1.0,
            duration: duration,
            curve: smoothCurve,
            child: child,
          ),
        );
      },
    );
  }

  /// Physics-based spring animation
  static AnimationController createSpringAnimation({
    required TickerProvider vsync,
    double initialValue = 0.0,
    double mass = 1.0,
    double stiffness = 100.0,
    double damping = 10.0,
  }) {
    final controller = AnimationController.unbounded(
      vsync: vsync,
      value: initialValue,
    );

    return controller;
  }

  /// Bounce animation for success states
  static Widget bounceAnimation({
    required Widget child,
    required bool trigger,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween<double>(
        begin: trigger ? 0.0 : 1.0,
        end: trigger ? 1.0 : 0.0,
      ),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Custom page transitions for different screen types
class PremiumPageTransitions {
  /// Slide from right (default for new screens)
  static Route<T> slideFromRight<T>(Widget page, {RouteSettings? settings}) {
    return PremiumAnimations.createSlideRoute<T>(
      page,
      settings: settings,
      beginOffset: const Offset(1.0, 0.0),
    );
  }

  /// Slide from bottom (for modals and sheets)
  static Route<T> slideFromBottom<T>(Widget page, {RouteSettings? settings}) {
    return PremiumAnimations.createSlideRoute<T>(
      page,
      settings: settings,
      beginOffset: const Offset(0.0, 1.0),
      duration: PremiumAnimations.medium,
    );
  }

  /// Scale transition (for dialogs)
  static Route<T> scaleTransition<T>(Widget page, {RouteSettings? settings}) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: PremiumAnimations.medium,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: PremiumAnimations.smoothCurve,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: PremiumAnimations.smoothCurve,
        ));

        return ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// Fade transition (for subtle changes)
  static Route<T> fadeTransition<T>(Widget page, {RouteSettings? settings}) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: PremiumAnimations.fast,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}