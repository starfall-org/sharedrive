import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Credentials {
  static Future<void> save(String credString) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> credList = prefs.getStringList("gauth_credentials") ?? [];
    await prefs.setStringList("gauth_credentials", [...credList, credString]);
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

  static Future<List> list() async {
    final prefs = await SharedPreferences.getInstance();
    List credList = prefs.getStringList("gauth_credentials") ?? [];
    for (var cred in credList) {
      var jsonCred = jsonDecode(cred);
      credList.remove(cred);
      credList.add(jsonCred);
    }
    return credList;
  }
}
