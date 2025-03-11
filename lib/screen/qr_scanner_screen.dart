import 'package:flutter/material.dart';
import 'package:operational_app/widget/qr_scanner.dart';
import 'package:operational_app/notifier/qr_scanner_notifier.dart';
import 'package:provider/provider.dart';

class QRScannerScreen extends StatelessWidget {
  const QRScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => QRScannerNotifier(),
      child: Scaffold(
        appBar: AppBar(title: const Text("QR Scanner")),
        body: Consumer<QRScannerNotifier>(
          builder: (context, qrScannerNotifier, child) {
            return QRScannerView(
              qrKey: qrScannerNotifier.qrKey,
              onQRViewCreated: qrScannerNotifier.onQRViewCreated,
              scannedData: qrScannerNotifier.scannedData,
            );
          },
        ),
      ),
    );
  }
}
