import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/app.dart';
import 'src/settings/credentials.dart';
import 'src/settings/video.dart';
import 'src/common/permissions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  requestPermissions();
  final videoSettingsProvider = VideoSettingsNotifier();
  await videoSettingsProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VideoSettingsNotifier()),
        ChangeNotifierProvider(create: (_) => CredentialsNotifier()),
      ],
      child: const App(),
    ),
  );
}
