import 'package:flutter/material.dart';

class DetailNotifier extends ChangeNotifier {
  bool shouldRefresh = false;

  void markForRefresh() {
    shouldRefresh = true;
    notifyListeners();
  }

  void resetRefresh() {
    shouldRefresh = false;
  }
}
