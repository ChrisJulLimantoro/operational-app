import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:operational_app/helper/api.dart';
import 'package:operational_app/helper/notification.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PDFViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String fileName;

  const PDFViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.fileName,
  });

  @override
  PDFViewerScreenState createState() => PDFViewerScreenState();
}

class PDFViewerScreenState extends State<PDFViewerScreen> {
  PDFViewController? _pdfViewController;
  bool _isPDFLoaded = false;
  String? filePath;
  int _totalPages = 0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadPDF();
  }

  @override
  void dispose() {
    _pdfViewController = null;
    super.dispose();
  }

  Future<void> _loadPDF() async {
    try {
      var response = await ApiHelper.get(
        context,
        '/nota/${widget.pdfUrl}',
        options: Options(responseType: ResponseType.bytes),
      );

      List<int> pdfBytes;
      if (response.data is String) {
        // If the API returns a base64-encoded string, decode it
        pdfBytes = Uint8List.fromList(response.data.codeUnits);
      } else if (response.data is List<int>) {
        pdfBytes = response.data;
      } else {
        throw Exception(
          "Unexpected response type: ${response.data.runtimeType}",
        );
      }

      // ✅ 4. Save PDF to Temporary Storage
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = "${tempDir.path}/nota.pdf";

      File file = File(tempPath);
      await file.create(recursive: true);
      await file.writeAsBytes(pdfBytes, flush: true);

      // ✅ 5. Verify File Size
      debugPrint("Saved PDF Size: ${file.lengthSync()} bytes");

      // ✅ 6. Update UI State
      setState(() {
        filePath = tempPath;
      });

      debugPrint("PDF saved at: $filePath");
    } catch (e) {
      debugPrint("Error loading PDF: $e");
    }
  }

  Future<void> _downloadPDF() async {
    try {
      if (Platform.isAndroid) {
        var status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          debugPrint("Storage permission denied.");
          return;
        }
      }

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory(
          '/storage/emulated/0/Download',
        ); // Save to Downloads
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        debugPrint("Failed to get directory.");
        return;
      }

      String downloadPath = "${directory.path}/${widget.fileName}.pdf";

      File file = File(downloadPath);
      await file.create(recursive: true);
      await file.writeAsBytes(await File(filePath!).readAsBytes());

      if (!context.mounted) return;
      NotificationHelper.showNotificationSheet(
        context: context,
        title: 'Sukses',
        message: 'File saved at $downloadPath',
        primaryButtonText: "OK",
        onPrimaryPressed: () {},
        primaryColor: AppColors.success,
        icon: Icons.check_circle_outline,
      );
    } catch (e) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: 'Gagal',
        message: 'error $e',
        primaryButtonText: "OK",
        onPrimaryPressed: () {},
        primaryColor: AppColors.error,
      );
      debugPrint("Error downloading PDF: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName, style: AppTextStyles.headingWhite),
      ),
      body:
          filePath == null
              ? Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  // 📄 Main PDF Viewer
                  PDFView(
                    filePath: filePath,
                    enableSwipe: true,
                    autoSpacing: true,
                    pageFling: true,
                    swipeHorizontal: false,
                    onRender: (pages) {
                      setState(() {
                        _isPDFLoaded = true;
                        _totalPages = pages ?? 0;
                      });
                    },
                    onViewCreated: (PDFViewController pdfViewController) {
                      _pdfViewController = pdfViewController;
                    },
                    onPageChanged: (currentPage, totalPages) {
                      setState(() {
                        _currentPage = currentPage ?? 0;
                        _totalPages = totalPages ?? 0;
                      });
                    },
                  ),

                  // 🔍 Custom UI Overlay
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      children: [
                        // 📄 Page Indicator
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Page ${_currentPage + 1} / $_totalPages",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _downloadPDF,
        child: Icon(Icons.download),
      ),
    );
  }
}
