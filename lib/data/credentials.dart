import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Credentials {
  static Future<String?> getSelected() async {
    final prefs = await SharedPreferences.getInstance();
    String? selectedClientEmail = prefs.getString("selected_client_email");
    return selectedClientEmail;
      return null;
  }

  static Future<void> setSelected(String clientEmail) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("selected_client_email", clientEmail);
  }

  static Future<void> save(String credString) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> credList = prefs.getStringList("gauth_credentials") ?? [];

    var newCred = jsonDecode(credString);

    bool updated = false;
    for (int i = 0; i < credList.length; i++) {
      var existingCred = jsonDecode(credList[i]);
      if (existingCred['client_email'] == newCred['client_email']) {
        // Update the existing credential
        credList[i] = credString;
        updated = true;
        break;
      }
    }

    if (!updated) {
      credList.add(credString);
    }

    await prefs.setStringList("gauth_credentials", credList);
  }

  static Future<Map?> get(String clientEmail) async {
    List credList = await Credentials.list();
    for (var cred in credList) {
      if (cred['client_email'] == clientEmail) {
        return cred;
      }
    }
    return null;
  }

  static Future<String?> delete(String clientEmail) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> credList = prefs.getStringList("gauth_credentials") ?? [];
    for (var cred in credList) {
      var jsonCred = jsonDecode(cred);
      if (jsonCred['client_email'] == clientEmail) {
        credList.remove(cred);
        await prefs.setStringList("gauth_credentials", credList);
        return clientEmail;
      }
    }
    return null;
  }

  static Future<List<Map>> list() async {
    final prefs = await SharedPreferences.getInstance();
    List credList = prefs.getStringList("gauth_credentials") ?? [];
    List<Map> returnCredList = [];
    for (var cred in credList) {
      Map jsonCred = jsonDecode(cred);
      returnCredList.add(jsonCred);
    }
    return returnCredList;
  }
}
