// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:Islah.AI/views/processed_video_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final File media;
  late File recievedVideo;

  ProcessingScreen({Key? key, required this.media}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ProcessingScreenState createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  late VideoPlayerController _controller;
  bool _processing = false;
  String _processedVideoUrl = '';

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.media);
    _controller.initialize().then((_) {
      setState(() {});
      _controller.play();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _uploadVideo() async {
    setState(() {
      _processing = true;
    });

    // Send the video file to your Flask server for processing
    final url = Uri.parse('http://192.168.1.107:5000//upload');
    final request = http.MultipartRequest('POST', url);
    request.files
        .add(await http.MultipartFile.fromPath('video', widget.media.path));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _processedVideoUrl = data['processed_video_url'];
        });
      } else {
        // Handle error
        print('Failed to process video: ${response.statusCode}');
      }
    } catch (e) {
      // Handle error
      print('Error processing video: $e');
    }

    setState(() {
      _processing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Processing Screen'),
      ),
      body: Center(
        child: _processing
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 480,
                    width: 270,
                    child: _controller.value.isInitialized
                        ? VideoPlayer(_controller)
                        : const CircularProgressIndicator(),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _uploadVideo,
                    child: const Text('Upload Video'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProcessedVideoScreen(
                            processedVideoUrl:
                                'http://192.168.1.107:5000//process',
                          ),
                        ),
                      );
                    },
                    child: const Text('View Processed Video'),
                  ),
                ],
              ),
      ),
    );
  }
}
