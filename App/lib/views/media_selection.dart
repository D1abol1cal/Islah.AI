import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:Islah.AI/views/processing_screen.dart';

class VideoSelectionWidget extends StatefulWidget {
  const VideoSelectionWidget({Key? key}) : super(key: key);

  @override
  State<VideoSelectionWidget> createState() => _VideoSelectionWidgetState();
}

class _VideoSelectionWidgetState extends State<VideoSelectionWidget> {
  late File media;
  final ImagePicker _picker = ImagePicker();
  VideoPlayerController _controller = VideoPlayerController.file(File(''));

  void pickVideoFromCamera() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
    if (video == null) return;

    setState(() {
      media = File(video.path);
    });

    _controller = VideoPlayerController.file(media);
    _controller.initialize();
    _controller.setLooping(true);
    _controller.play();
  }

  void pickVideoFromGallery() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video == null) return;

    setState(() {
      media = File(video.path);
    });

    _controller = VideoPlayerController.file(media);
    _controller.initialize();
    _controller.setLooping(true);
    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Selection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 480,
              width: 270,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: VideoPlayer(_controller, key: UniqueKey()),
              ),
            ),
            const SizedBox(height: 0),
            ElevatedButton.icon(
                onPressed: () {
                  pickVideoFromCamera();
                },
                icon: const Icon(Icons.camera),
                label: const Text('Camera')),
            const SizedBox(height: 20),
            ElevatedButton.icon(
                onPressed: () {
                  pickVideoFromGallery();
                },
                icon: const Icon(Icons.browse_gallery),
                label: const Text('Gallery')),
            const SizedBox(height: 20),
            ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ProcessingScreen(
                              media: media,
                            )),
                  );
                },
                icon: const Icon(Icons.watch_outlined),
                label: const Text('Process'))
          ],
        ),
      ),
    );
  }
}
