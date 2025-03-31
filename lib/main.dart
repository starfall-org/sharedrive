import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:driveplus/core/providers/credentials_provider.dart';
import 'package:driveplus/core/providers/video_settings.dart';
import 'package:driveplus/app.dart';
import 'package:driveplus/common/request_permissions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  checkAndRequestPermissions();
  final videoSettingsProvider = VideoSettingsProvider();
  await videoSettingsProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => videoSettingsProvider),
        ChangeNotifierProvider(create: (_) => SelectedCredentials()),
      ],
      child: const App(),
    ),
  );
}
