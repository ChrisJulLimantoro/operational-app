import 'package:flutter/material.dart';

class SalesNotifier extends ChangeNotifier {
  bool shouldRefresh = false;

  void markForRefresh() {
    shouldRefresh = true;
    notifyListeners();
  }

  void resetRefresh() {
    shouldRefresh = false;
  }
}
