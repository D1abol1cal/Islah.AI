import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class ProcessedVideoScreen extends StatefulWidget {
  final String processedVideoUrl;

  const ProcessedVideoScreen({Key? key, required this.processedVideoUrl})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ProcessedVideoScreenState createState() => _ProcessedVideoScreenState();
}

class _ProcessedVideoScreenState extends State<ProcessedVideoScreen> {
  VideoPlayerController _controller = VideoPlayerController.file(File(''));

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final videoFile = await _downloadVideo(widget.processedVideoUrl);
    _controller = VideoPlayerController.file(videoFile)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  Future<File> _downloadVideo(String url) async {
    final response = await http.get(Uri.parse(url));
    final tempDir = await getTemporaryDirectory();
    final videoFile = File('${tempDir.path}/processed_video.mp4');
    await videoFile.writeAsBytes(response.bodyBytes);
    return videoFile;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Processed Video'),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
