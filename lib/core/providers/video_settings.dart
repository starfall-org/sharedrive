import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoSettingsProvider with ChangeNotifier {
  late bool? _autoPlay;
  late bool? _looping;
  late bool? _fullscreenByDefault;

  bool get autoPlay => _autoPlay ?? false;
  bool get looping => _looping ?? false;
  bool get fullscreenByDefault => _fullscreenByDefault ?? false;

  set autoPlay(bool value) {
    autoPlay = value;
    _saveToPrefs();
    notifyListeners();
  }

  set looping(bool value) {
    looping = value;
    _saveToPrefs();
    notifyListeners();
  }

  set fullscreenByDefault(bool value) {
    fullscreenByDefault = value;
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> init() async {
    await _loadFromPrefs();
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
