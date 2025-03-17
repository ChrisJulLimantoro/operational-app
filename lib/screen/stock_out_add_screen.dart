import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:operational_app/api/product.dart';
import 'package:operational_app/api/stock_out.dart';
import 'package:operational_app/helper/notification.dart';
import 'package:operational_app/notifier/stock_out_notifier.dart';
import 'package:operational_app/screen/qr_scanner_screen.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:provider/provider.dart';

class StockOutAddScreen extends StatefulWidget {
  const StockOutAddScreen({super.key});

  @override
  State<StockOutAddScreen> createState() => _StockOutAddScreenState();
}

class _StockOutAddScreenState extends State<StockOutAddScreen> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController dateController = TextEditingController();
  List<Map<String, dynamic>> reasons = [
    {'id': 1, 'value': 'Perbaikan'},
    {'id': 2, 'value': 'Hilang'},
    {'id': 3, 'value': 'Lainnya'},
  ];
  Map<String, dynamic> selectedReason = {};
  List<Map<String, dynamic>> products = [];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      dateController.text = "${picked.toLocal()}".split(' ')[0]; // Format date
    }
  }

  Future<void> _onScannedQR(BuildContext context) async {
    final scannedResult = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );

    if (scannedResult != null) {
      if (context.mounted) {
        debugPrint(scannedResult);
        try {
          final response = await ProductAPI.fetchProductCode(
            context,
            scannedResult.split(';')[0],
          );
          if (!context.mounted) return;
          if (response != null) {
            // Do something with the response
            if (response['status'] == 1) {
              throw Exception("Product telah terjual!");
            } else if (response['status'] > 0) {
              throw Exception("Product sedang dikeluarkan!");
            }

            setState(() {
              products.add(response);
            });
          } else {
            throw Exception("Product not found");
          }
        } catch (e) {
          NotificationHelper.showNotificationSheet(
            context: context,
            title: "Gagal",
            message: "$e",
            primaryButtonText: "OK",
            onPrimaryPressed: () {},
          );
        }
      }
    }
  }

  Future<void> _onSave(BuildContext context) async {
    // Saving Logic
    try {
      if (products.isEmpty) {
        throw Exception("Tidak ada barang yang ditarik");
      }
      if (selectedReason.isEmpty) {
        throw Exception("Alasan tidak boleh kosong");
      }

      final response = await StockOutAPI.saveStockOut(context, {
        'date': dateController.text,
        'taken_out_reason': selectedReason['id'],
        'codes': products,
      });

      if (!context.mounted) return;
      if (response) {
        NotificationHelper.showNotificationSheet(
          context: context,
          title: "Berhasil",
          message: "Berhasil melakukan stock out",
          icon: Icons.check_circle_outline,
          primaryColor: AppColors.success,
          primaryButtonText: "OK",
          onPrimaryPressed: () {
            _scroll.jumpTo(0);
            Provider.of<StockOutNotifier>(
              context,
              listen: false,
            ).markForRefresh();
            context.pop();
          },
        );
      }
    } on Exception catch (e) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal",
        message: "$e",
        primaryButtonText: "OK",
        onPrimaryPressed: () {},
      );
    }
  }

  @override
  void initState() {
    super.initState();
    dateController.text = "${DateTime.now().toLocal()}".split(' ')[0];
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
            title: Text('Tambah', style: AppTextStyles.headingWhite),
            leading: IconButton(
              icon: const Icon(CupertinoIcons.arrow_left, color: Colors.white),
              onPressed: () {
                _scroll.jumpTo(0);
                context.pop();
              },
            ),
            actions: [
              TextButton(
                child: Text("Simpan", style: AppTextStyles.labelWhite),
                onPressed: () {
                  // Saving Logic
                  _onSave(context);
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 24.0,
              ),
              child: Column(
                spacing: 24,
                children: [
                  Card(
                    elevation: 1,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 20.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Text(
                            "Detail Stock Out",
                            style: AppTextStyles.headingBlue,
                          ),
                          Divider(),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              controller: dateController,
                              readOnly: true, // Prevent manual input
                              decoration: InputDecoration(
                                icon: Icon(Icons.calendar_today),
                                labelText: "Select Date",
                              ),
                              onTap: () => _selectDate(context),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Pilih Alasan",
                            style: AppTextStyles.subheadingBlue,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<Map<String, dynamic>>(
                              key: ValueKey(selectedReason),
                              value:
                                  reasons.contains(selectedReason)
                                      ? selectedReason
                                      : null,
                              hint: Text("Pilih Alasan"),
                              isExpanded:
                                  true, // Makes the dropdown take full width
                              items:
                                  reasons.map((Map<String, dynamic> item) {
                                    return DropdownMenuItem<
                                      Map<String, dynamic>
                                    >(
                                      value: item,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            item['value'] ?? 'Select a Item',
                                          ),
                                          if (selectedReason['id'] ==
                                              item['id'])
                                            Icon(
                                              Icons.check,
                                              color: AppColors.bluePrimary,
                                            ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (Map<String, dynamic>? newValue) {
                                setState(() {
                                  selectedReason = newValue!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      // Open Scanner
                      _onScannedQR(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                  Card(
                    elevation: 1,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 20.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Text(
                            "Barang Stock Out",
                            style: AppTextStyles.headingBlue,
                          ),
                          Divider(),
                          ...products.map((product) {
                            return ListTile(
                              title: Text(
                                '${product['name'].split(' - ')[1]} (${product['weight']} gr)',
                              ),
                              subtitle: Text('${product['barcode']}'),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: AppColors.error,
                                ),
                                onPressed: () {
                                  setState(() {
                                    products.remove(product);
                                  });
                                },
                              ),
                            );
                          }),
                        ],
                      ),
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
