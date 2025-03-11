import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScannerNotifier extends ChangeNotifier {
  QRViewController? controller;
  String? scannedData;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  void onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scannedData == null) {
        scannedData = scanData.code;
        controller.pauseCamera(); // Pause immediately after first scan
        notifyListeners();

        // Automatically return scanned result
        Future.delayed(Duration(milliseconds: 500), () {
          controller.dispose();
          notifyListeners();
        });
      }
    });
  }

  void disposeController() {
    controller?.dispose();
  }
}
