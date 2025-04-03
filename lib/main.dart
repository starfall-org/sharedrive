import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/app.dart';
import 'src/models/app_model.dart';
import 'src/common/permissions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  requestPermissions();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppModel())],
      child: const App(),
    ),
  );
}
