import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoSettingsProvider with ChangeNotifier {
  late bool _autoPlay;
  late bool _looping;
  late bool _fullscreenByDefault;

  VideoSettingsProvider() {
    _autoPlay = false;
    _looping = false;
    _fullscreenByDefault = false;
    init();
  }

  bool get autoPlay => _autoPlay;
  bool get looping => _looping;
  bool get fullscreenByDefault => _fullscreenByDefault;

  set autoPlay(bool value) {
    if (_autoPlay != value) {
      _autoPlay = value;
      _saveToPrefs();
      notifyListeners();
    }
  }

  set looping(bool value) {
    if (_looping != value) {
      _looping = value;
      _saveToPrefs();
      notifyListeners();
    }
  }

  set fullscreenByDefault(bool value) {
    if (_fullscreenByDefault != value) {
      _fullscreenByDefault = value;
      _saveToPrefs();
      notifyListeners();
    }
  }

  Future<void> init() async {
    await _loadFromPrefs();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("auto_play", _autoPlay);
    await prefs.setBool("looping", _looping);
    await prefs.setBool("fullscreen_by_default", _fullscreenByDefault);
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _autoPlay = prefs.getBool("auto_play") ?? false;
    _looping = prefs.getBool("looping") ?? false;
    _fullscreenByDefault = prefs.getBool("fullscreen_by_default") ?? false;
    notifyListeners();
  }
}
