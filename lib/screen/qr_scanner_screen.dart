import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widget/qr_scanner_notifier.dart';
import '../widget/qr_scanner.dart';

class QRScannerScreen extends StatelessWidget {
  final Function(String) onScanned;
  const QRScannerScreen({Key? key, required this.onScanned}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QRScannerNotifier(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Scan QR Code')),
        body: Consumer<QRScannerNotifier>(
          builder: (context, controller, _) {
            return QRScannerView(
              qrKey: controller.qrKey,
              onQRViewCreated: controller.onQRViewCreated,
              scannedData: controller.scannedData,
              onScanAgain: controller.restartScanner,
              onConfirm: () {
                onScanned(controller.scannedData!);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    );
  }
}
