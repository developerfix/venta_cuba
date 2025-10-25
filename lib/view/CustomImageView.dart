import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CustomImageView extends StatefulWidget {
  final String image;
  CustomImageView({super.key, required this.image});

  @override
  State<CustomImageView> createState() => _CustomImageViewState();
}

class _CustomImageViewState extends State<CustomImageView> {
  final TransformationController _transformationController =
      TransformationController();

  bool get _isZoomed {
    final Matrix4 matrix = _transformationController.value;
    final double scaleX = matrix.getMaxScaleOnAxis();
    return scaleX > 1.01;
  }

  void _handleDoubleTap() {
    final Matrix4 matrix = _transformationController.value;
    final double currentScale = matrix.getMaxScaleOnAxis();

    if (currentScale <= 1.01) {
      // Zoom in to 2x
      _transformationController.value = Matrix4.identity()
        ..scale(2.0, 2.0, 1.0);
    } else {
      // Zoom out to normal
      _transformationController.value = Matrix4.identity();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          // Full screen interactive viewer
          Positioned.fill(
            child: GestureDetector(
              onDoubleTap: _handleDoubleTap,
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.5,
                maxScale: 8.0,
                panEnabled: _isZoomed,
                scaleEnabled: true, // Always allow pinch zoom
                child: CachedNetworkImage(
                  imageUrl: widget.image,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 64,
                          color: Colors.white54,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Image not available',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: Material(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => Get.back(),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
