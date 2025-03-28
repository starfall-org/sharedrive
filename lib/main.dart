import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const VideoPlayerScreen(),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializePlayer(_urlController.text);
  }

  void _initializePlayer(String url) {
    _controller?.dispose();
    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        setState(() {});
        _controller?.play();
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _changeSource(String sourceUrl) {
    setState(() {
      _initializePlayer(sourceUrl);
    });
  }

  void _showUrlDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Video URL'),
          content: TextField(
            controller: _urlController,
            decoration: const InputDecoration(hintText: 'Enter video URL here'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _changeSource(_urlController.text);
                Navigator.pop(context);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(icon: const Icon(Icons.link), onPressed: _showUrlDialog),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[playerWidget()],
        ),
      ),
    );
  }

  Widget playerWidget() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    double aspectRatio = _controller!.value.aspectRatio;
    aspectRatio =
        aspectRatio > 2.0 ? 16 / 9 : (aspectRatio < 0.5 ? 9 / 16 : aspectRatio);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(aspectRatio: aspectRatio, child: VideoPlayer(_controller!)),
        VideoProgressIndicator(_controller!, allowScrubbing: true),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.replay_10),
              onPressed: () {
                _controller!.seekTo(
                  _controller!.value.position - const Duration(seconds: 10),
                );
              },
            ),
            IconButton(
              icon: Icon(
                _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
              onPressed: () {
                setState(() {
                  _controller!.value.isPlaying
                      ? _controller!.pause()
                      : _controller!.play();
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.forward_10),
              onPressed: () {
                _controller!.seekTo(
                  _controller!.value.position + const Duration(seconds: 10),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
