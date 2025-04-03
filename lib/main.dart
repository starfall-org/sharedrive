import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/app.dart';
import 'src/models/app_model.dart';
import 'src/common/permissions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  requestPermissions();

  runApp(ChangeNotifierProvider(create: (_) => AppModel(), child: _Main()));
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
