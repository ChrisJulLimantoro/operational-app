import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScannerView extends StatelessWidget {
  final GlobalKey qrKey;
  final Function(QRViewController) onQRViewCreated;
  final String? scannedData;
  final VoidCallback onScanAgain;
  final VoidCallback onConfirm;

  const QRScannerView({
    Key? key,
    required this.qrKey,
    required this.onQRViewCreated,
    this.scannedData,
    required this.onScanAgain,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: QRView(key: qrKey, onQRViewCreated: onQRViewCreated),
        ),
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              scannedData != null
                  ? Column(
                    children: [
                      Text(
                        "Detected: $scannedData",
                        style: const TextStyle(fontSize: 10),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: onScanAgain,
                        child: const Text('Scan Again'),
                      ),
                      ElevatedButton(
                        onPressed: onConfirm,
                        child: const Text('Confirm'),
                      ),
                    ],
                  )
                  : const Text("Scanning...", style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ],
    );
  }
}
