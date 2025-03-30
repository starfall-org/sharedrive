import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/side_menu.dart';
import '../widgets/top_bar.dart';
import '../widgets/bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
        appBar: const TopBarWidget(screen: "Home"),
        body: Stack(children: [Center(child: Text("Home"))]),
        bottomNavigationBar: const BottomBarWidget(),
      ),
    );
  }
}
