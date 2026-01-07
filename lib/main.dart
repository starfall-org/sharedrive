import 'package:flutter/material.dart';

import 'package:letdrive/app/app.dart';
import 'package:letdrive/app/common/permissions.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  requestPermissions();
  WidgetsFlutterBinding.ensureInitialized();

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
