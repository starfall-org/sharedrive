import 'package:flutter/material.dart';
import 'package:mediaplus/widgets/player.dart';

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
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String videoSource = "";
  final TextEditingController _urlController = TextEditingController();

  void _changeSource(String sourceUrl) {
    setState(() {
      videoSource = sourceUrl;
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
              onPressed: () {
                Navigator.pop(context);
              },
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
        actions: [
          IconButton(icon: const Icon(Icons.link), onPressed: _showUrlDialog),
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget>[VideoPlayerWidget(videoUrl: videoSource)],
        ),
      ),
    );
  }
}
