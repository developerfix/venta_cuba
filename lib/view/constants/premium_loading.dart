import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'premium_animations.dart';
import 'Colors.dart';

/// Premium loading states for ultra-smooth user experience
class PremiumLoading {

  /// Skeleton loading for list items
  static Widget listItemSkeleton({
    bool hasImage = true,
    bool hasSubtitle = true,
    double height = 80,
  }) {
    return Container(
      height: height.h,
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (hasImage) ...[
            // Image skeleton
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: Colors.grey[300],
              ),
            ),
            SizedBox(width: 16.w),
          ],
          // Content skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title skeleton
                Container(
                  height: 16.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: Colors.grey[300],
                  ),
                ),
                if (hasSubtitle) ...[
                  SizedBox(height: 8.h),
                  // Subtitle skeleton
                  Container(
                    height: 14.h,
                    width: 0.7.sw,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Action skeleton
          Container(
            width: 24.w,
            height: 24.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.r),
              color: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }

  /// Card skeleton for grid items
  static Widget cardSkeleton({
    double? width,
    double? height,
    bool hasContent = true,
  }) {
    return Container(
      width: width,
      height: height ?? 200.h,
      margin: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          Container(
            height: 120.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              color: Colors.grey[300],
            ),
          ),
          if (hasContent) ...[
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title skeleton
                  Container(
                    height: 16.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: Colors.grey[300],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Subtitle skeleton
                  Container(
                    height: 14.h,
                    width: 0.6 * (width ?? 200.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Profile header skeleton
  static Widget profileHeaderSkeleton() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          // Profile picture
          Container(
            width: 100.w,
            height: 100.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
          ),
          SizedBox(height: 16.h),
          // Name
          Container(
            height: 20.h,
            width: 150.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: Colors.grey[300],
            ),
          ),
          SizedBox(height: 8.h),
          // Email
          Container(
            height: 16.h,
            width: 200.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }

  /// Text skeleton lines
  static Widget textSkeleton({
    int lines = 3,
    double? width,
    double height = 16,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) {
        final isLastLine = index == lines - 1;
        final lineWidth = width ?? (isLastLine ? 0.7.sw : 1.0.sw);

        return Container(
          height: height.h,
          width: lineWidth,
          margin: EdgeInsets.only(bottom: index < lines - 1 ? 8.h : 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular((height / 2).r),
            color: Colors.grey[300],
          ),
        );
      }),
    );
  }

  /// Animated shimmer wrapper
  static Widget shimmerWrapper({
    required Widget child,
    bool enabled = true,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    if (!enabled) return child;

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: duration,
      child: child,
    );
  }

  /// Premium loading indicator
  static Widget indicator({
    Color? color,
    double size = 24,
    String? message,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.k0xFF0254B8,
              ),
            ),
          ),
          if (message != null) ...[
            SizedBox(height: 16.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Staggered loading for lists
  static Widget staggeredList({
    required int itemCount,
    required Widget Function(int index) skeletonBuilder,
    Duration staggerDuration = const Duration(milliseconds: 100),
  }) {
    return ListView.builder(
      itemCount: itemCount,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return PremiumAnimations.staggeredListItem(
          index: index,
          delay: staggerDuration,
          child: shimmerWrapper(
            child: skeletonBuilder(index),
          ),
        );
      },
    );
  }

  /// Grid skeleton
  static Widget gridSkeleton({
    required int itemCount,
    int crossAxisCount = 2,
    double? childAspectRatio,
  }) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio ?? 0.8,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return PremiumAnimations.staggeredListItem(
          index: index,
          child: shimmerWrapper(
            child: cardSkeleton(),
          ),
        );
      },
    );
  }

  /// Search results skeleton
  static Widget searchSkeleton() {
    return Column(
      children: [
        // Search bar skeleton
        Container(
          height: 48.h,
          margin: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            color: Colors.grey[300],
          ),
        ),
        // Results skeleton
        Expanded(
          child: staggeredList(
            itemCount: 6,
            skeletonBuilder: (index) => listItemSkeleton(),
          ),
        ),
      ],
    );
  }

  /// Bottom sheet skeleton
  static Widget bottomSheetSkeleton() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.r),
              color: Colors.grey[300],
            ),
          ),
          SizedBox(height: 20.h),
          // Content
          textSkeleton(lines: 4),
          SizedBox(height: 20.h),
          // Buttons
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.r),
                    color: Colors.grey[300],
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.r),
                    color: Colors.grey[300],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Premium loading states for specific app screens
class AppLoadingStates {

  /// Home screen loading
  static Widget homeLoading() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header skeleton
          Container(
            height: 200.h,
            width: double.infinity,
            color: Colors.grey[300],
          ),
          SizedBox(height: 20.h),
          // Categories skeleton
          Container(
            height: 100.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  width: 80.w,
                  margin: EdgeInsets.symmetric(horizontal: 8.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    color: Colors.grey[300],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20.h),
          // Listings grid skeleton
          PremiumLoading.gridSkeleton(itemCount: 6),
        ],
      ),
    );
  }

  /// Chat list loading
  static Widget chatListLoading() {
    return PremiumLoading.staggeredList(
      itemCount: 8,
      skeletonBuilder: (index) => PremiumLoading.listItemSkeleton(
        hasImage: true,
        hasSubtitle: true,
      ),
    );
  }

  /// Profile loading
  static Widget profileLoading() {
    return SingleChildScrollView(
      child: Column(
        children: [
          PremiumLoading.profileHeaderSkeleton(),
          SizedBox(height: 20.h),
          // Menu items skeleton
          ...List.generate(6, (index) {
            return Container(
              height: 56.h,
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: Colors.grey[300],
              ),
            );
          }),
        ],
      ),
    );
  }
}