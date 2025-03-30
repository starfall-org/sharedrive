import 'package:flutter/material.dart';

class DriveScreen extends StatefulWidget {
  const DriveScreen({super.key});

  @override
  State<DriveScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<DriveScreen> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [Center(child: Text("Drive"))]);
  }
}
