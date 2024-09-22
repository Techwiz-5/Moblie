import 'package:flutter/material.dart';

class UserStatusProvider with ChangeNotifier {
  bool _isOnline = false;

  bool get isOnline => _isOnline;

  void setOnline(bool value) {
    _isOnline = value;
    notifyListeners();
  }
}
