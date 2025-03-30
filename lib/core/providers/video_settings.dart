import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoSettingsProvider with ChangeNotifier {
  bool autoPlay = false;
  bool looping = false;
  bool fullscreenByDefault = false;

  VideoSettingsProvider();

  Future<void> init() async {
    await _loadFromPrefs();
  }

  void changeSettings({
    bool? autoPlay,
    bool? looping,
    bool? fullscreenByDefault,
  }) {
    this.autoPlay = autoPlay ?? this.autoPlay;
    this.looping = looping ?? this.looping;
    this.fullscreenByDefault = fullscreenByDefault ?? this.fullscreenByDefault;
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("auto_play", autoPlay);
    await prefs.setBool("looping", looping);
    await prefs.setBool("fullscreen_by_default", fullscreenByDefault);
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    autoPlay = prefs.getBool("auto_play") ?? false;
    looping = prefs.getBool("looping") ?? false;
    fullscreenByDefault = prefs.getBool("fullscreen_by_default") ?? false;
    notifyListeners();
  }
}
