import 'package:flutter/material.dart';

class Alert {
  static show(String message, BuildContext context) {
    final snackBar = SnackBar(
      content: Text(message),
      action: SnackBarAction(label: 'OK', onPressed: () {}),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
