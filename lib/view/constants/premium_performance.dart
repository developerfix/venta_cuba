import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Premium performance monitoring and optimization system
class PremiumPerformance {
  static final PremiumPerformance _instance = PremiumPerformance._internal();
  factory PremiumPerformance() => _instance;
  PremiumPerformance._internal();

  static PremiumPerformance get instance => _instance;

  // Performance metrics
  final Map<String, PerformanceMetric> _metrics = {};
  final Queue<FrameMetric> _frameMetrics = Queue();
  final int _maxFrameMetrics = 100;

  Timer? _performanceTimer;
  bool _isMonitoring = false;

  // Frame rate tracking
  Duration? _lastFrameTime;
  final List<double> _frameTimes = [];
  double _averageFPS = 60.0;

  /// Initialize performance monitoring
  void initialize() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _startFrameMonitoring();
    _startPerformanceTimer();

    debugPrint('📊 Premium Performance Monitoring Started');
  }

  /// Start monitoring frame rates
  void _startFrameMonitoring() {
    SchedulerBinding.instance.addPersistentFrameCallback((timeStamp) {
      _trackFrame(timeStamp);
    });
  }

  /// Track individual frame performance
  void _trackFrame(Duration timeStamp) {
    if (_lastFrameTime != null) {
      final frameDuration = timeStamp - _lastFrameTime!;
      final fps = 1000 / frameDuration.inMicroseconds * 1000000;

      _frameTimes.add(fps);
      if (_frameTimes.length > 30) {
        _frameTimes.removeAt(0);
      }

      _averageFPS = _frameTimes.fold<double>(0, (sum, fps) => sum + fps) / _frameTimes.length;

      // Add frame metric
      final frameMetric = FrameMetric(
        timestamp: DateTime.now(),
        fps: fps,
        frameDuration: frameDuration,
      );

      _frameMetrics.add(frameMetric);
      if (_frameMetrics.length > _maxFrameMetrics) {
        _frameMetrics.removeFirst();
      }
    }
    _lastFrameTime = timeStamp;
  }

  /// Start performance monitoring timer
  void _startPerformanceTimer() {
    _performanceTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _analyzePerformance();
    });
  }

  /// Analyze current performance metrics
  void _analyzePerformance() {
    final memoryUsage = _getMemoryUsage();
    final frameCount = _frameMetrics.length;
    final avgFPS = _averageFPS;

    // Log performance if in debug mode
    if (kDebugMode) {
      debugPrint('📊 Performance Update:');
      debugPrint('   FPS: ${avgFPS.toStringAsFixed(1)}');
      debugPrint('   Memory: ${memoryUsage.toStringAsFixed(1)}MB');
      debugPrint('   Frame Count: $frameCount');
    }

    // Alert if performance is degraded
    if (avgFPS < 45) {
      _handleLowFPS(avgFPS);
    }

    if (memoryUsage > 200) {
      _handleHighMemoryUsage(memoryUsage);
    }
  }

  /// Handle low FPS scenarios
  void _handleLowFPS(double fps) {
    debugPrint('⚠️ Low FPS detected: ${fps.toStringAsFixed(1)}');

    // Suggest optimizations
    if (kDebugMode) {
      debugPrint('💡 Performance suggestions:');
      debugPrint('   - Reduce complex animations');
      debugPrint('   - Optimize image loading');
      debugPrint('   - Check for expensive operations on UI thread');
    }
  }

  /// Handle high memory usage
  void _handleHighMemoryUsage(double memoryMB) {
    debugPrint('⚠️ High memory usage: ${memoryMB.toStringAsFixed(1)}MB');

    // Trigger garbage collection if needed
    if (memoryMB > 300) {
      _triggerMemoryCleanup();
    }
  }

  /// Trigger memory cleanup
  void _triggerMemoryCleanup() {
    debugPrint('🧹 Triggering memory cleanup...');

    // Clear image caches if available
    try {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      debugPrint('✅ Image cache cleared');
    } catch (e) {
      debugPrint('Failed to clear image cache: $e');
    }
  }

  /// Get current memory usage in MB
  double _getMemoryUsage() {
    // This is a simplified implementation
    // In a real app, you'd use more sophisticated memory tracking
    return 50.0; // Placeholder value
  }

  /// Start measuring a specific operation
  void startMeasurement(String name) {
    _metrics[name] = PerformanceMetric(
      name: name,
      startTime: DateTime.now(),
    );
  }

  /// End measurement and log result
  void endMeasurement(String name) {
    final metric = _metrics[name];
    if (metric == null) return;

    metric.endTime = DateTime.now();
    metric.duration = metric.endTime!.difference(metric.startTime);

    if (kDebugMode && metric.duration != null) {
      debugPrint('⏱️ $name: ${metric.duration!.inMilliseconds}ms');
    }

    // Warn about slow operations
    if (metric.duration != null && metric.duration!.inMilliseconds > 1000) {
      debugPrint('⚠️ Slow operation detected: $name (${metric.duration!.inMilliseconds}ms)');
    }
  }

  /// Measure a function execution time
  Future<T> measure<T>(String name, Future<T> Function() operation) async {
    startMeasurement(name);
    try {
      final result = await operation();
      endMeasurement(name);
      return result;
    } catch (e) {
      endMeasurement(name);
      rethrow;
    }
  }

  /// Get current performance stats
  PerformanceStats getStats() {
    return PerformanceStats(
      averageFPS: _averageFPS,
      frameCount: _frameMetrics.length,
      memoryUsageMB: _getMemoryUsage(),
      activeMetrics: _metrics.length,
    );
  }

  /// Get recent frame metrics
  List<FrameMetric> getRecentFrameMetrics([int count = 30]) {
    final recent = _frameMetrics.toList();
    return recent.length > count
        ? recent.sublist(recent.length - count)
        : recent;
  }

  /// Optimize widget performance
  static Widget optimizedBuilder({
    required Widget Function() builder,
    String? debugName,
  }) {
    return Builder(
      builder: (context) {
        if (kDebugMode && debugName != null) {
          Timeline.startSync(debugName);
          final result = builder();
          Timeline.finishSync();
          return result;
        }
        return builder();
      },
    );
  }

  /// Optimized list view for better performance
  static Widget optimizedListView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    ScrollController? controller,
    EdgeInsets? padding,
    bool shrinkWrap = false,
  }) {
    return ListView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: itemBuilder(context, index),
        );
      },
      // Performance optimizations
      cacheExtent: 250,
      addRepaintBoundaries: true,
      addAutomaticKeepAlives: true,
      addSemanticIndexes: true,
    );
  }

  /// Optimized grid view
  static Widget optimizedGridView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    required SliverGridDelegate gridDelegate,
    ScrollController? controller,
    EdgeInsets? padding,
  }) {
    return GridView.builder(
      controller: controller,
      padding: padding,
      itemCount: itemCount,
      gridDelegate: gridDelegate,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: itemBuilder(context, index),
        );
      },
      // Performance optimizations
      cacheExtent: 250,
      addRepaintBoundaries: true,
      addAutomaticKeepAlives: true,
      addSemanticIndexes: true,
    );
  }

  /// Lazy loading widget
  static Widget lazyWidget({
    required Widget Function() builder,
    Widget? placeholder,
    bool condition = true,
  }) {
    if (!condition) {
      return placeholder ?? const SizedBox.shrink();
    }

    return FutureBuilder<Widget>(
      future: Future.microtask(builder),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!;
        }
        return placeholder ?? const SizedBox.shrink();
      },
    );
  }

  /// Dispose resources
  void dispose() {
    _performanceTimer?.cancel();
    _metrics.clear();
    _frameMetrics.clear();
    _frameTimes.clear();
    _isMonitoring = false;
  }
}

/// Performance metric data class
class PerformanceMetric {
  final String name;
  final DateTime startTime;
  DateTime? endTime;
  Duration? duration;

  PerformanceMetric({
    required this.name,
    required this.startTime,
    this.endTime,
    this.duration,
  });
}

/// Frame performance data
class FrameMetric {
  final DateTime timestamp;
  final double fps;
  final Duration frameDuration;

  FrameMetric({
    required this.timestamp,
    required this.fps,
    required this.frameDuration,
  });
}

/// Performance statistics
class PerformanceStats {
  final double averageFPS;
  final int frameCount;
  final double memoryUsageMB;
  final int activeMetrics;

  PerformanceStats({
    required this.averageFPS,
    required this.frameCount,
    required this.memoryUsageMB,
    required this.activeMetrics,
  });

  @override
  String toString() {
    return 'PerformanceStats(fps: ${averageFPS.toStringAsFixed(1)}, '
           'memory: ${memoryUsageMB.toStringAsFixed(1)}MB, '
           'frames: $frameCount, metrics: $activeMetrics)';
  }
}

/// Performance monitoring widget
class PerformanceOverlay extends StatelessWidget {
  final Widget child;
  final bool showFPS;
  final bool showMemory;

  const PerformanceOverlay({
    Key? key,
    required this.child,
    this.showFPS = true,
    this.showMemory = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return child;

    return Stack(
      children: [
        child,
        if (showFPS || showMemory) ...[
          Positioned(
            top: 50,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(4),
              ),
              child: StreamBuilder<PerformanceStats>(
                stream: Stream.periodic(
                  const Duration(seconds: 1),
                  (_) => PremiumPerformance.instance.getStats(),
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();

                  final stats = snapshot.data!;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (showFPS) ...[
                        Text(
                          '${stats.averageFPS.toStringAsFixed(1)} FPS',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      if (showMemory) ...[
                        Text(
                          '${stats.memoryUsageMB.toStringAsFixed(1)} MB',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}