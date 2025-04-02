import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';

import './common/themes/material.dart';
import './screens/main.dart';
import './widgets/dialogs/login.dart';
import 'widgets/navbars/bottom.dart';
import './widgets/side_menu.dart';
import 'widgets/navbars/top.dart';
import './services/gauth.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  int _selectedIndex = 0;
  List<String> accounts = [];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    var tempAccountsList = await GAuthService.savedCredentialsList();
    if (tempAccountsList.isNotEmpty) {
      setState(() {
        accounts = tempAccountsList;
      });
    } else {
      popupLogin(context);
      var newAccountsList = await GAuthService.savedCredentialsList();
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
              drawer: SideMenu(),
              appBar: TopBarWidget(
                screen: _selectedIndex == 0 ? "Files" : "Share with me",
              ),
              body: Center(child: MainScreen()),
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
