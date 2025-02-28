import 'package:flutter/material.dart';
import 'qr_scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? scannedData;

  void _openScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => QRScannerScreen(
              onScanned: (data) {
                setState(() {
                  scannedData = data;
                });
              },
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code Scanner')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            scannedData != null
                ? Column(
                  children: [
                    Text(
                      "Scanned QR: $scannedData",
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _openScanner,
                      child: const Text('Scan Again'),
                    ),
                  ],
                )
                : ElevatedButton(
                  onPressed: _openScanner,
                  child: const Text('Scan QR Code'),
                ),
          ],
        ),
      ),
    );
  }
}
