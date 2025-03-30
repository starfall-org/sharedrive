import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mediaplus/core/providers/video_settings.dart';
import 'package:mediaplus/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final videoSettingsProvider = VideoSettingsProvider();
  await videoSettingsProvider.init();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => videoSettingsProvider)],
      child: const App(),
    ),
  );
}
