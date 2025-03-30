import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mediaplus/widgets/bottom_bar.dart';
import '../widgets/side_menu.dart';
import '../widgets/top_bar.dart';

class DriveScreen extends StatefulWidget {
  const DriveScreen({super.key});

  @override
  State<DriveScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<DriveScreen> {
  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: const SideMenuWidget(),
        appBar: const TopBarWidget(screen: "Drive"),
        body: Container(
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
          child: Stack(children: [Center(child: Text("Drive"))]),
        ),
        bottomNavigationBar: const BottomBarWidget(),
      ),
    );
  }
}
