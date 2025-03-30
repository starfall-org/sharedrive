import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:mediaplus/screens/drive.dart';
import 'package:mediaplus/widgets/bottom_bar.dart';
import 'package:mediaplus/widgets/side_menu.dart';
import 'package:mediaplus/widgets/top_bar.dart';
import 'screens/home.dart';
import 'themes/theme_data.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    DriveScreen(),
    Text('Hồ sơ', style: TextStyle(fontSize: 24)),
  ];

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
                screen:
                    _selectedIndex == 0
                        ? "Home"
                        : _selectedIndex == 1
                        ? "Drive"
                        : "Photos",
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
