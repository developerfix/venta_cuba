import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {




  late VideoPlayerController controller;
  double currentSliderValue = 0.0;

  final List<String> videoUrls= [];
  int currentVideoIndex = 0;
  void initializeVideoPlayer() {
    controller = VideoPlayerController.asset(Platform.isAndroid?"assets/video/android_instruction.mp4":"assets/video/iso_instruction.mp4");
    controller.addListener(() {
      currentSliderValue = controller.value.position.inSeconds.toDouble();
      setState(() {

      });
    });
    controller.setLooping(false);
    controller.initialize().then((_) {
     setState(() {

     });
    });
  }




  @override
  void initState() {

    super.initState();
   initializeVideoPlayer();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: (){
            Get.back();
          },
          child: Icon(Icons.arrow_back_ios,
          ),
        ),
      ),
      body:Center(
        child: controller.value.isInitialized
            ? Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              ),
            ),
            Column(
              children: [
                SizedBox(
                  height: 3.h,
                  child: Slider(
                    activeColor: Colors.blue,
                    value: currentSliderValue,
                    min: 0.0,
                    max: controller.value.duration.inSeconds.toDouble(),
                    onChanged: (value) {

                      currentSliderValue = value;
                      controller.seekTo(Duration(seconds: value.toInt()));
                  setState(() {

                  });
                    },
                  ),
                ),
                SizedBox(height: 15.h,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        controller.seekTo(Duration(seconds: (controller.value.position.inSeconds - 10).clamp(0, controller.value.duration.inSeconds)));
                      },
                      icon: Icon(Icons.replay_10,

                      ),
                    ),
                    InkWell(
                      onTap: (){
                        if (controller.value.isPlaying ) {
                          controller.pause();
                        } else {
                          controller.play();
                        }
                        print("good");

                      },
                      child: Container(height: 56.h,
                        width: 56.w,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          color: Colors.blue
                        ),
                        child:  Center(
                          child: Icon(
color: Colors.white,
                            controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        controller.seekTo(Duration(seconds: (controller.value.position.inSeconds + 10).clamp(0, controller.value.duration.inSeconds)));
                      },
                      icon: Icon(Icons.forward_10,

                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h,),
              ],
            ),
          ],
        )
            : CircularProgressIndicator(),
      )


    );
  }

  @override
  void dispose() {
    super.dispose();

    controller.dispose();
  }
}













// import 'dart:async';
// import 'package:chewie/chewie.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:video_player/video_player.dart';
//
// class VideoPlayerScreen extends StatefulWidget {
//   VideoPlayerScreen();
//
//   @override
//   _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
// }
//
// class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
//   VideoPlayerController? _controller;
//   late ChewieController chewieController;
//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.asset("assets/video/v.mp4")
//       ..initialize().then((_) {
//         print(".................");
//         setState(() {});
//       });
//     chewieController = ChewieController(
//       videoPlayerController: _controller!,
//       autoPlay: true,
//       looping: false,
//       // Add other options as per your requirement
//     showControls: true,
//       fullScreenByDefault: true,
//       // fullScreenByDefault: false,
//       aspectRatio: 9 / 16,
//       allowFullScreen: false,
//     );
//   }
//
//   @override
//   void dispose() {
//     // Ensure disposing of the VideoPlayerController to free up resources.
//     _controller?.dispose();
//
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           GestureDetector(
//               onTap: () => Get.back(),
//               child: Padding(
//                 padding: EdgeInsets.only(left: 20.0.w, top: 30.h),
//                 child: Icon(Icons.close),
//               )),
//           // SizedBox(height: 20),
//           Expanded(
//             child: Center(
//               child: Chewie(
//                 controller: chewieController,
//               ),
//             ),
//           ),
//           // Center(
//           //   child: _controller!.value.isInitialized
//           //       ? AspectRatio(
//           //           aspectRatio: _controller!.value.aspectRatio,
//           //           child: VideoPlayer(_controller!),
//           //         )
//           //       : Container(),
//           // ),
//         ],
//       ),
//       // floatingActionButton: FloatingActionButton(
//       //   onPressed: () {
//       //     setState(() {
//       //       _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
//       //     });
//       //   },
//       //   child: Icon(
//       //     _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
//       //   ),
//       // ),
//     );
//   }
//
//
//
//
// }
