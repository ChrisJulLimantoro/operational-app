import 'package:flutter/material.dart';

class StockOpnameNotifier extends ChangeNotifier {
  bool shouldRefresh = false;

  void markForRefresh() {
    shouldRefresh = true;
    notifyListeners();
  }

  void resetRefresh() {
    shouldRefresh = false;
  }
}
