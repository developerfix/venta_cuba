import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:venta_cuba/Utils/funcations.dart';
import '../../../Utils/global_variabel.dart';
import '../custom_text.dart';

class MessageTile extends StatefulWidget {
  final String message;
  final String sender;
  final String messageType;
  final String messageTime;
  final bool sentByMe;

  const MessageTile(
      {Key? key,
      required this.message,
      required this.sender,
      required this.messageType,
      required this.messageTime,
      required this.sentByMe})
      : super(key: key);

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  double seconds = 0.0;
  Duration duration = Duration();
  Duration position = Duration();
  bool isPlaying = false;
  double value = 0.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: widget.sentByMe ? 0 : 24.w,
          right: widget.sentByMe ? 24.w : 0),
      alignment: widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            widget.sentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: widget.sentByMe
                ? EdgeInsets.only(left: 30.w)
                : EdgeInsets.only(right: 30.w),
            padding:
                EdgeInsets.only(top: 5.h, bottom: 5.h, left: 5.w, right: 5.w),
            decoration: BoxDecoration(
                borderRadius: widget.sentByMe
                    ? BorderRadius.only(
                        topLeft: Radius.circular(10.r),
                        topRight: Radius.circular(10.r),
                        bottomLeft: Radius.circular(10.r),
                      )
                    : BorderRadius.only(
                        topLeft: Radius.circular(10.r),
                        topRight: Radius.circular(10.r),
                        bottomRight: Radius.circular(10.r),
                      ),
                color: widget.sentByMe
                    ? Color(0xFF0254B8)
                    : Colors.grey.withValues(alpha: .4)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.messageType == 'image'
                    ? InkWell(
                        onTap: () {
                          isONImageScreen = true;
                          focusNode.unfocus();
                          Get.to(ImageView(
                            image: widget.message,
                          ))?.then((value) {
                            isONImageScreen = true;
                          });
                        },
                        child: _buildImageWidget(widget.message),
                      )
                    : SizedBox(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 5.w, vertical: 2.h),
                          child: SelectionArea(
                            child: Text(widget.message,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 17,
                                    color: widget.sentByMe
                                        ? Colors.white
                                        : Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.color ??
                                            Colors.black)),
                          ),
                        ),
                      )
              ],
            ),
          ),
          SizedBox(
            height: 2.h,
          ),
          SelectionArea(
            child: CustomText(
              text: widget.messageTime,
              fontColor: Theme.of(context).textTheme.bodySmall?.color ??
                  Color(0xFF828284),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String path) {
    final isNetwork = path.startsWith('http://') || path.startsWith('https://');
    if (isNetwork) {
      return CachedNetworkImage(
        height: 100..h,
        width: 100.w,
        imageUrl: path,
        imageBuilder: (context, imageProvider) => ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.r),
            topRight: Radius.circular(10.r),
            bottomLeft: Radius.circular(10.r),
            bottomRight: Radius.circular(10.r),
          ),
          child: Container(
            height: 100..h,
            width: 100.w,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        placeholder: (context, url) => SizedBox(
            height: 100..h,
            width: 100.w,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
        errorWidget: (context, url, error) => Icon(Icons.error),
      );
    } else {
      // Local file
      return ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.r),
          topRight: Radius.circular(10.r),
          bottomLeft: Radius.circular(10.r),
          bottomRight: Radius.circular(10.r),
        ),
        child: Image.file(
          File(path),
          height: 100..h,
          width: 100.w,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
        ),
      );
    }
  }
}

Future<void> saveImageToGallery(String imageUrl) async {
  try {
    // Try to get the cached file first for instant saving
    final cacheManager = DefaultCacheManager();
    final fileInfo = await cacheManager.getFileFromCache(imageUrl);
    File? file;
    if (fileInfo != null && await fileInfo.file.exists()) {
      file = fileInfo.file;
    } else {
      // If not cached, download and cache it
      final fileFetched = await cacheManager.getSingleFile(imageUrl);
      file = fileFetched;
    }
    // Save the image to the gallery
    final result = await ImageGallerySaverPlus.saveFile(file.path,
        isReturnPathOfIOS: true);
    if (result != null && result.isNotEmpty) {
      print('Image saved to gallery: $result');
      errorAlertToast("Saved".tr);
    } else {
      print('Failed to save image to gallery. File path is null or empty.');
    }
  } catch (e) {
    print('Error saving image to gallery: $e');
  }
}

final _transformationController = TransformationController();
TapDownDetails? _doubleTapDetails;
void _handleDoubleTap() {
  if (_transformationController.value != Matrix4.identity()) {
    _transformationController.value = Matrix4.identity();
  } else {
    final position = _doubleTapDetails?.localPosition;
    // For a 3x zoom
    _transformationController.value = Matrix4.identity()
      ..translate(-position!.dx * 2, -position.dy * 2)
      ..scale(3.0);
    // Fox a 2x zoom
    // ..translate(-position.dx, -position.dy)
    // ..scale(2.0);
  }
}

class ImageView extends StatefulWidget {
  final String? image;
  const ImageView({super.key, this.image});

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView>
    with SingleTickerProviderStateMixin {
  bool isSharingImage = false;
  bool isDownloadingImage = false;

  double _dragOffset = 0.0;
  double _opacity = 1.0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _animation = Tween<double>(begin: 0, end: 0).animate(_animationController)
      ..addListener(() {
        setState(() {
          _dragOffset = _animation.value;
          _opacity = 1.0 - (_dragOffset.abs() / 300).clamp(0, 0.7);
        });
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dy;
      _opacity = 1.0 - (_dragOffset.abs() / 300).clamp(0, 0.7);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_dragOffset.abs() > 120) {
      Get.back();
    } else {
      _animation = Tween<double>(begin: _dragOffset, end: 0)
          .animate(_animationController);
      _animationController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: InkWell(
            onTap: () {
              Get.back();
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            )),
        actions: [
          GestureDetector(
            onTap: isDownloadingImage
                ? null
                : () async {
                    setState(() {
                      isDownloadingImage = true;
                    });

                    await saveImageToGallery(widget.image!);
                    setState(() {
                      isDownloadingImage = false;
                    });
                  },
            child: isDownloadingImage
                ? SizedBox(
                    height: 16, width: 16, child: CircularProgressIndicator())
                : Icon(Icons.file_download_rounded),
          ),
          SizedBox(width: 20),
          GestureDetector(
            onTap: isSharingImage
                ? null
                : () async {
                    setState(() {
                      isSharingImage = true;
                    });
                    try {
                      // Try to get the cached file first for instant sharing
                      final cacheManager = DefaultCacheManager();
                      final fileInfo =
                          await cacheManager.getFileFromCache(widget.image!);
                      File? file;
                      if (fileInfo != null && await fileInfo.file.exists()) {
                        file = fileInfo.file;
                      } else {
                        // If not cached, download and cache it
                        final fileFetched =
                            await cacheManager.getSingleFile(widget.image!);
                        file = fileFetched;
                      }
                      await Share.shareXFiles([XFile(file.path)], text: '');
                    } catch (e) {
                      // fallback: share the image URL if file fails
                      await Share.share(widget.image!);
                    }
                    setState(() {
                      isSharingImage = false;
                    });
                  },
            child: isSharingImage
                ? SizedBox(
                    height: 16, width: 16, child: CircularProgressIndicator())
                : Icon(Icons.share),
          ),
          SizedBox(width: 20)
        ],
      ),
      body: Center(
        child: GestureDetector(
          onVerticalDragUpdate: _onVerticalDragUpdate,
          onVerticalDragEnd: _onVerticalDragEnd,
          child: Opacity(
            opacity: _opacity,
            child: Transform.translate(
              offset: Offset(0, _dragOffset),
              child: PhotoView(
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                imageProvider: CachedNetworkImageProvider(widget.image!),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
