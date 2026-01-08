import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:manydrive/app/app.dart';
import 'package:manydrive/app/common/permissions.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Làm cho thanh trạng thái và thanh điều hướng trong suốt
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Cho phép UI tràn lên vùng thanh trạng thái và thanh điều hướng
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  requestPermissions();

  runApp(_Main());
}

class _Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ManyDrive',
      home: Builder(
        builder: (context) {
          return App();
        },
      ),
    );
  }
}
