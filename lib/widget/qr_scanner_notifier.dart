import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScannerNotifier extends ChangeNotifier {
  QRViewController? controller;
  String? scannedData;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  void onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      scannedData = scanData.code;
      controller.pauseCamera(); // Pause after scan
      notifyListeners();
    });
  }

  void restartScanner() {
    scannedData = null;
    controller?.resumeCamera();
    notifyListeners();
  }

  void disposeController() {
    controller?.dispose();
  }
}
