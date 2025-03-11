import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:operational_app/api/stock_opname.dart';
import 'package:operational_app/helper/notification.dart';
import 'package:operational_app/model/stock_opname.dart';
import 'package:operational_app/notifier/stock_opname_notifier.dart';
import 'package:operational_app/screen/qr_scanner_screen.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:provider/provider.dart';

class StockOpnameDetailScreen extends StatefulWidget {
  final StockOpname stockOpname;
  const StockOpnameDetailScreen({super.key, required this.stockOpname});

  @override
  State<StockOpnameDetailScreen> createState() =>
      _StockOpnameDetailScreenState();
}

class _StockOpnameDetailScreenState extends State<StockOpnameDetailScreen> {
  List<Map<String, dynamic>> stockOpnameDetails = [];
  final _scroll = ScrollController();
  String? scannedData;

  // Future<void> _fetchStockOpnameDetails() async {
  //   // Fetch stock opname details
  // }

  Future<void> _fetchProductCode(String categoryId) async {
    final data = await StockOpnameAPI.fetchProductCode(context, categoryId);

    setState(() {
      stockOpnameDetails =
          data.map((e) {
            return {
              ...e,
              'scanned':
                  widget.stockOpname.details
                      .where((d) => d.productCodeId == e['id'])
                      .map((d) => d.scanned)
                      .firstOrNull ??
                  false,
            };
          }).toList();
    });
  }

  Future<void> _onScannedQR(BuildContext context) async {
    final scannedResult = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );

    if (scannedResult != null) {
      final index = stockOpnameDetails.indexWhere(
        (e) => e['code'] == scannedResult.toString().split(';')[0],
      );
      if (context.mounted) {
        if (index == -1) {
          NotificationHelper.showNotificationSheet(
            context: context,
            title: 'Gagal',
            message: 'Barang tidak terdaftar dalam kategori ini',
            primaryButtonText: 'Cancel',
            primaryColor: AppColors.error,
            onPrimaryPressed: () {},
          );
        } else {
          if (stockOpnameDetails[index]['scanned']) {
            NotificationHelper.showNotificationSheet(
              context: context,
              title: 'Gagal',
              message: 'Barang telah di-scan',
              primaryButtonText: 'Cancel',
              primaryColor: AppColors.error,
              onPrimaryPressed: () {},
            );
          } else {
            final response = await StockOpnameAPI.scanProduct(
              context,
              widget.stockOpname.id,
              scannedResult.toString().split(';')[0],
            );
            if (response) {
              setState(() => stockOpnameDetails[index]['scanned'] = true);
            }
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    await _fetchProductCode(widget.stockOpname.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scroll,
        scrollBehavior: const CupertinoScrollBehavior(),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true, // Ensures the app bar remains visible when scrolling
            floating: false, // No snap effect
            elevation: 0,
            title: Text(
              'Stock Opname Detail',
              style: AppTextStyles.headingWhite,
            ),
            leading: IconButton(
              icon: const Icon(CupertinoIcons.arrow_left, color: Colors.white),
              onPressed: () {
                _scroll.jumpTo(0);
                Provider.of<StockOpnameNotifier>(
                  context,
                  listen: false,
                ).markForRefresh();
                context.pop();
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  // Button Approve and Scan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            // Approve Stock Opname
                          },
                          child: Container(
                            height: 50, // Adjust height as needed
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Approve',
                              style: AppTextStyles.labelWhite,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8), // Small gap between buttons
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            // Open Scanner
                            _onScannedQR(context);
                          },
                          child: Container(
                            height: 50, // Adjust height as needed
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.bluePrimary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Scan QR',
                              style: AppTextStyles.labelWhite,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Card Barang
                  Card(
                    color: Colors.white,
                    elevation: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 24),
                          child: Text(
                            "Barang",
                            style: AppTextStyles.headingBlue,
                          ),
                        ),
                        Divider(),
                        ...stockOpnameDetails.map(
                          (detail) => ListTile(
                            title: Text(
                              detail['name'],
                              style: AppTextStyles.subheadingBlue,
                            ),
                            subtitle: Text(
                              detail['code'],
                              style: AppTextStyles.labelBlueItalic,
                            ),
                            trailing: Text(
                              detail['scanned']
                                  ? 'Sudah Di-Scan'
                                  : 'Belum Di-Scan',
                              style:
                                  detail['scanned']
                                      ? AppTextStyles.labelBlue
                                      : AppTextStyles.labelPink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
