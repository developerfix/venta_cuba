import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
// import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:venta_cuba/Utils/funcations.dart';
import '../../../Utils/global_variabel.dart';
import '../custom_text.dart';
import '../pages/chat_page.dart';

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
                    : Colors.grey.withOpacity(.4)),
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
                        child: CachedNetworkImage(
                          height: 100..h,
                          width: 100.w,
                          imageUrl: widget.message,
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
                              child: Center(
                                  child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ))),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ))
                    : SizedBox(
                        // width: 247.w,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 5.w, vertical: 2.h),
                          child: SelectionArea(
                            child: Text(widget.message,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontSize: 17,
                                    color: widget.sentByMe
                                        ? Colors.white
                                        : Colors.black)),
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
              fontColor: Color(0xFF828284),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Future<void> saveImageToGallery(String imageUrl) async {
//   try {
//     // Download the image from the URL
//     var response = await http.get(Uri.parse(imageUrl));

//     if (response.statusCode == 200) {
//       Uint8List bytes = response.bodyBytes;

//       // Get the application documents directory
//       final appDir = await getApplicationDocumentsDirectory();

//       // Generate a unique filename
//       String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.png';

//       // Create a new file with the generated filename
//       final file = File('${appDir.path}/$fileName');

//       // Write the image bytes to the file
//       await file.writeAsBytes(bytes);

//       print('Image saved locally: ${file.path}');

//       // Save the image to the gallery
//       final result = await ImageGallerySaverPlus.saveFile(file.path, isReturnPathOfIOS: true);

//       if (result != null && result.isNotEmpty) {
//         print('Image saved to gallery: $result');
//         errorAlertToast("Saved".tr);
//       } else {
//         print('Failed to save image to gallery. File path is null or empty.');
//       }
//     } else {
//       print('Failed to download image: ${response.statusCode}');
//     }
//   } catch (e) {
//     print('Error saving image to gallery: $e');
//   }
// }

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

class ImageView extends StatelessWidget {
  final String? image;
  const ImageView({super.key, this.image});
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
              onTap: () {
                // saveImageToGallery(image!);
              },
              child: Icon(Icons.file_download_rounded),
            ),
            SizedBox(width: 20),
            GestureDetector(
              onTap: () async {
                final response = await http.get(Uri.parse(image!));
                final directory = await getTemporaryDirectory();
                File file = await File('${directory.path}/Image.png')
                    .writeAsBytes(response.bodyBytes);
                await Share.shareXFiles([XFile(file.path)], text: '');
                // Share.share(image!);
              },
              child: Icon(Icons.share),
            ),
            SizedBox(width: 20)
          ],
        ),
        body: Center(
          child: PhotoView(
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            imageProvider: NetworkImage(image!),
            // child: Image.network(
            //   image ?? "",
            //   height: double.infinity,
            //   width: double.infinity,
            //   fit: BoxFit.contain,
            // ),
          ),
        ));
  }
}
