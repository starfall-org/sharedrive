import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/common/permissions.dart';

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
      title: 'GSA Drive',
      home: Builder(
        builder: (context) {
          return App();
        },
      ),
    );
  }
}
