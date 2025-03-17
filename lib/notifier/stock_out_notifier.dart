import 'package:flutter/material.dart';

class StockOutNotifier extends ChangeNotifier {
  bool shouldRefresh = false;

  void markForRefresh() {
    shouldRefresh = true;
    notifyListeners();
  }

  void resetRefresh() {
    shouldRefresh = false;
  }
}
