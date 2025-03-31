import 'package:driveplus/common/popup_login.dart';
import 'package:driveplus/screens/files.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:driveplus/themes/theme_data.dart';
import 'package:driveplus/widgets/bottom_bar.dart';
import 'package:driveplus/widgets/side_menu.dart';
import 'package:driveplus/widgets/top_bar.dart';
import 'package:driveplus/screens/share_with_me.dart';
import 'package:driveplus/core/services/googleapis_auth.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  int _selectedIndex = 0;
  List<String> accounts = [];

  final List<Widget> _widgetOptions = <Widget>[
    const FilesScreen(),
    const ShareWithMeScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    var tempAccountsList = await GapisAuth.listCredentials();
    if (tempAccountsList.isNotEmpty) {
      setState(() {
        accounts = tempAccountsList;
      });
    } else {
      popupLogin(context);
      var newAccountsList = await GapisAuth.listCredentials();
      if (newAccountsList.isNotEmpty) {
        setState(() {
          accounts = newAccountsList;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          theme: lightTheme(lightDynamic),
          darkTheme: darkTheme(darkDynamic),
          themeMode: ThemeMode.system,

          home: SafeArea(
            child: Scaffold(
              drawer: const SideMenuWidget(),
              appBar: TopBarWidget(
                screen: _selectedIndex == 0 ? "Files" : "Share with me",
              ),
              body: Center(child: _widgetOptions[_selectedIndex]),
              bottomNavigationBar: BottomBarWidget(
                selectedIndex: _selectedIndex,
                onItemTapped: _onItemTapped,
              ),
            ),
          ),
        );
      },
    );
  }
}
