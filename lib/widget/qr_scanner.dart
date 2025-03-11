import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScannerView extends StatelessWidget {
  final GlobalKey qrKey;
  final Function(QRViewController) onQRViewCreated;
  final String? scannedData;

  const QRScannerView({
    super.key,
    required this.qrKey,
    required this.onQRViewCreated,
    this.scannedData,
  });

  @override
  Widget build(BuildContext context) {
    if (scannedData != null) {
      Future.delayed(Duration(milliseconds: 500), () {
        if (!context.mounted) return;
        Navigator.pop(context, scannedData); // Auto-confirm after scan
      });
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Column(
        children: [
          Expanded(
            flex: 4,
            child: QRView(key: qrKey, onQRViewCreated: onQRViewCreated),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child:
                  scannedData != null
                      ? Text(
                        "Detected: $scannedData",
                        style: const TextStyle(fontSize: 18),
                      )
                      : const Text(
                        "Scanning...",
                        style: TextStyle(fontSize: 18),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
