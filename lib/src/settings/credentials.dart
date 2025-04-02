import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CredentialsNotifier extends ChangeNotifier {
  String? _clientEmail;

  String? get clientEmail => _clientEmail;

  CredentialsNotifier() {
    _loadFromPrefs();
  }

  set clientEmail(String? value) {
    _clientEmail = value;
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _clientEmail = prefs.getString("selected_client_email");
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("selected_client_email", _clientEmail ?? "");
  }
}
