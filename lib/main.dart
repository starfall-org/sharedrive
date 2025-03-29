import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

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
  final TextEditingController _selectedController = TextEditingController();
  List<String> _videos = [];
  bool _showDrawer = false;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  @override
  void dispose() {
    _selectedController.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  void _loadVideos() async {
    try {
      var apiUrl = Uri.parse("https://collection-api.deno.dev/api/files");
      var response = await http.get(
        apiUrl,
        headers: {"Accept": "application/json"},
      );

      var data = jsonDecode(response.body);
      setState(() {
        data.forEach((video) {
          _videos.add(video);
        });
        loadVideo(_videos[0]);
      });
    } catch (e) {
      showAlertDialog(title: "Error", message: e.toString());
    }
  }

  void loadVideo(String videoName) async {
    var apiUrl = Uri.parse(
      "https://collection-api.deno.dev/api/presigned-url/$videoName",
    );
    var response = await http.get(
      apiUrl,
      headers: {"Accept": "application/json"},
    );
    var data = jsonDecode(response.body);
    setState(() {
      _selectedController.text = data['url'];
    });
  }

  void showAlertDialog({String? title, String? message}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title ?? "Alert"),
          content: Text(message ?? ""),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDrawer() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _showDrawer ? 250 : 0,
      color: Colors.black87,
      child:
          _showDrawer
              ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _selectedController.text,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  const Divider(color: Colors.white70),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _videos.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            _videos[index],
                            style: TextStyle(
                              color:
                                  _selectedController.text == _videos[index]
                                      ? Color.fromARGB(255, 241, 168, 10)
                                      : Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap:
                              () => setState(() {
                                loadVideo(_videos[index]);
                              }),
                        );
                      },
                    ),
                  ),
                ],
              )
              : null,
    );
  }

  Widget _buildVideoPlayer() {
    Uri uri = Uri.parse(_selectedController.text);
    return Expanded(
      child: Center(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: VideoPlayer(VideoPlayerController.networkUrl(uri)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Row(
          children: [
            _buildDrawer(),
            Flexible(
              flex: 1,
              child: Stack(
                children: [
                  IconButton(
                    padding: const EdgeInsets.all(8.0),
                    icon: Icon(
                      _showDrawer ? Icons.close : Icons.menu,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      setState(() {
                        _showDrawer = !_showDrawer;
                      });
                    },
                  ),
                  Center(child: _buildVideoPlayer()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
