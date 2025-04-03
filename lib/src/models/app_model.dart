import 'package:flutter/foundation.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrentFolder {
  String? folderId;
  bool sharedWithMe = false;
  bool trashed = false;
}

class AppModel extends ChangeNotifier {
  String? _selectedClientEmail;
  AuthClient? _authClient;
  List<String?>? _accounts;
  List<File?>? _files;
  CurrentFolder? _currentFolder;
  List<String?> _folderHistory = [];
  final List<String> _navigationStack = ['root'];

  String? get selectedClientEmail => _selectedClientEmail;
  AuthClient? get authClient => _authClient;
  List<String?>? get accounts => _accounts;
  List<File?>? get files => _files;
  CurrentFolder? get currentFolder => _currentFolder;
  String get currentFolderId => _navigationStack.last;

  AppModel() {
    _loadFromPrefs();
  }

  set selectedClientEmail(String? value) {
    _selectedClientEmail = value;
    _saveToPrefs();
    notifyListeners();
  }

  set authClient(AuthClient? value) {
    _authClient = value;
    notifyListeners();
  }

  set accounts(List<String?>? value) {
    _accounts = value;
    notifyListeners();
  }

  set files(List<File?>? value) {
    _files = value;
    notifyListeners();
  }

  set currentFolder(CurrentFolder? value) {
    _currentFolder = value;
    notifyListeners();
  }

  void addFolderToHistory(String folderId) {
    _folderHistory.add(folderId);
    notifyListeners();
  }

  void removeFolderFromHistory(String folderId) {
    _folderHistory.remove(folderId);
    notifyListeners();
  }

  void navigateToFolder(String folderId) {
    _navigationStack.add(folderId);
    notifyListeners();
  }

  bool get canGoBack => _navigationStack.length > 1;

  String? goBack() {
    if (canGoBack) {
      _navigationStack.removeLast();
      return currentFolderId;
    }
    return null;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedClientEmail = prefs.getString("selected_client_email");
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("selected_client_email", _selectedClientEmail ?? "");
  }

  void updateClientEmail(String email) {
    selectedClientEmail = email;
    notifyListeners();
  }
}
