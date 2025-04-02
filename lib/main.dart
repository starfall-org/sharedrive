import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

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

  void _loadVideos() async {
    try {
      var apiUrl = Uri.parse("https://collection-api.deno.dev/api/files");
      var response = await http.get(apiUrl);
      log('API Response: ${response.body}');
      var data = jsonDecode(response.body);
      setState(() {
        _videos = data;
        _selectedController.text = data[0];
      });
    } catch (e) {
      log('Error loading videos: $e');
    }
  }

  @override
  void dispose() {
    _selectedController.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
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
                  Padding(padding: const EdgeInsets.all(8.0)),
                  const Divider(color: Colors.white30),

                  Expanded(
                    child: ListView.builder(
                      itemCount: _videos.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            _videos[index],
                            style: const TextStyle(color: Colors.white70),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => log('Selected video: ${_videos[index]}'),
                        );
                      },
                    ),
                  ),
                ],
              )
              : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                SafeArea(
                  child: Center(
                    child: Text(
                      _selectedController.text,
                      style: const TextStyle(color: Colors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
=======
import 'package:provider/provider.dart';

import 'src/app.dart';
import 'src/settings/credentials.dart';
import 'src/settings/video.dart';
import 'src/common/permissions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  checkAndRequestPermissions();
  final videoSettingsProvider = VideoSettingsProvider();
  await videoSettingsProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VideoSettingsNotifier()),
        ChangeNotifierProvider(create: (_) => CredentialsNotifier()),
      ],
      child: const App(),
    ),
  );
>>>>>>> 2edc21a27587656410baae26ff3c3e24e0453548
}
