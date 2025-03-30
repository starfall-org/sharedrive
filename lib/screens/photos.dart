import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhotosScreen extends StatefulWidget {
  const PhotosScreen({super.key});

  @override
  State<PhotosScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<PhotosScreen> {
  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [Center(child: Text("Home"))]);
  }
}
