
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreenFile extends StatefulWidget {
 final File file;
  VideoPlayerScreenFile({required this.file});
  @override
  _VideoPlayerScreenFileState createState() => _VideoPlayerScreenFileState();
}

class _VideoPlayerScreenFileState extends State<VideoPlayerScreenFile> {
  late VideoPlayerController _controller;
  double _progressValue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        setState(() {});
        _controller.addListener(() {
          setState(() {
            _progressValue = _controller.value.position.inSeconds.toDouble();
          });
        });
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Center(
        child:  _controller.value.isInitialized
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),

            Slider(
              value: _progressValue,
              min: 0.0,
              activeColor: Colors.blue,
              max: _controller.value.duration.inSeconds.toDouble(),
              onChanged: (value) {
                setState(() {
                  _progressValue = value;
                });
                _controller.seekTo(Duration(seconds: value.toInt()));
              },
            ),
            InkWell(
              onTap: () {
                setState(() {
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                  }
                });
              },

              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue
                ),
                child: Icon(
                  color: Colors.white,
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                ) ,
              ),
            )
          ],
        )
            : CircularProgressIndicator(),),


    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      actions: [
        InkWell(
          onTap: (){
            Get.back();
          },
          child: Text("Next",

          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600
          ),
          ),
        ),
        SizedBox(width: 20,)
      ],
    );
  }



}
