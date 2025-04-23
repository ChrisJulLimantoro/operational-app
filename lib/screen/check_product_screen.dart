import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:operational_app/api/product.dart';
import 'package:operational_app/api/stock_card.dart';
import 'package:operational_app/bloc/permission_bloc.dart';
import 'package:operational_app/helper/notification.dart';
import 'package:operational_app/model/product.dart';
import 'package:operational_app/model/product_code.dart';
import 'package:operational_app/model/stock_card.dart';
import 'package:operational_app/screen/qr_scanner_screen.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/form_sheet.dart';
import 'package:operational_app/widget/text_form.dart';
import 'package:provider/provider.dart';

class CheckProductScreen extends StatefulWidget {
  const CheckProductScreen({super.key});

  @override
  State<CheckProductScreen> createState() => _CheckProductScreenState();
}

class _CheckProductScreenState extends State<CheckProductScreen> {
  bool isLoading = false;
  ProductCode? productCode;
  List<StockCard> stockCards = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  // Open QR Scanner
  Future<void> _qrScan() async {
    final scanned = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );
    if (scanned == null) return;

    await _fetchProductHistory(scanned.split(';')[0]);
  }

  // Open Prompt to Insert Product Barcode
  Future<void> _showPromptProduct() async {
    String scannedBarcode = '';
    final scanned = await showModalBottomSheet(
      context: context,
      isDismissible: true, // Allows dismissing by tapping outside
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder:
          (context) => FormSheet(
            title: 'Cari Produk',
            form: TextForm(
              onChanged: (value) {
                scannedBarcode = value; // Update barcode value
              },
              label: 'Enter Barcode',
            ),
            onOkPressed: () {
              Navigator.pop(context, scannedBarcode);
            },
            primaryColor: AppColors.success,
          ),
    );
    if (scanned != null) {
      await _fetchProductHistory(scanned);
    }
  }

  Future<void> _fetchProductHistory(String barcode) async {
    // Fetch Product sold by ID
    setState(() {
      isLoading = true;
    });
    final fetchProduct = await ProductAPI.fetchCheckProduct(context, barcode);
    final fetchStockCards = await StockCardAPI.fetchStockCards(
      context,
      productCode: barcode,
    );
    debugPrint('this is check product fetch ${fetchProduct.toString()}');
    debugPrint(
      'this is check product stock card ${fetchStockCards.toString()}',
    );
    if (fetchProduct != null) {
      setState(() {
        productCode = ProductCode.fromJSON(fetchProduct);
        stockCards = fetchStockCards;
        isLoading = false;
      });
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Berhasil",
        message: "Produk Berhasil ditemukan",
        icon: Icons.check_circle_outline,
        primaryColor: AppColors.success,
        primaryButtonText: "OK",
        onPrimaryPressed: () {},
      );
    }
  }

  // widget for product details
  Widget productDetailCard() {
    if (productCode == null) {
      return const SizedBox.shrink(); // Return empty widget if no product
    }
    final code = productCode!; // Dart sekarang tahu ini tidak null
    final statusText = switch (code.status) {
      0 => "Status: In Stock",
      1 => "Status: Sold",
      2 => "Status: Bought Back",
      3 => "Status: Taken Out",
      _ => "Status: Unknown",
    };

    return Card(
      color: Colors.white,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            // small icon info with text Public information
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AppColors.pinkSecondary),
                const SizedBox(width: 8),
                Text(
                  "Public Information",
                  style: AppTextStyles.labelPink,
                ),
              ],
            ),
            // horizontal line
            const Divider(color: Colors.grey, thickness: 1),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween, // Ensures left-right alignment
              children: [
                // Transaction Code on the Left
                Text(code.barcode, style: AppTextStyles.subheadingBlue),

                // Right-side status and button grouped together
                Row(
                  spacing: 8,
                  children: [
                    // Status
                    Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.pinkPrimary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          statusText,
                          style: AppTextStyles.labelWhite,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // jarak 10
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text("Name", style: AppTextStyles.labelPink),
                      Text(code.product?.name ?? '-', style: AppTextStyles.bodyBlue),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text("Category", style: AppTextStyles.labelPink),
                      Text(code.product?.category?.name ?? '-', style: AppTextStyles.bodyBlue),
                    ],
                  ),
                ),
                 Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text("SubCategory", style: AppTextStyles.labelPink),
                      Text(code.product?.type.name ?? '-', style: AppTextStyles.bodyBlue),
                    ],
                  ),
                ),
              ],
            ),
            // harak 10
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text("Weight", style: AppTextStyles.labelPink),
                      Text( code.weight.toString(), style: AppTextStyles.bodyBlue),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text("Price/gram", style: AppTextStyles.labelPink),
                      Text(code.fixedPrice.toString(), style: AppTextStyles.bodyBlue),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text("Store", style: AppTextStyles.labelPink),
                      Text(code.product?.store?.name ?? '-', style: AppTextStyles.bodyBlue),
                    ],
                  ),
                ),
              ],
            ),
            // jarak 10
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text("Company", style: AppTextStyles.labelPink),
                      Text(code.product?.store?.company?.name ?? '-', style: AppTextStyles.bodyBlue),
                    ],
                  ),
                ),
                // empty expaned
                const Expanded(
                  child: SizedBox(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }
  String formatCurrency(double price) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID', 
      symbol: 'Rp. ', 
      decimalDigits: 2, // untuk dua angka di belakang koma
    );
    return formatter.format(price);
  }


  Widget productHistoryDetail() {
    return Card(
      color: Colors.white,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            // small icon info with text Public information
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AppColors.pinkSecondary),
                const SizedBox(width: 8),
                Text(
                  "Mutation Information",
                  style: AppTextStyles.labelPink,
                ),
              ],
            ),
            // horizontal line
            const Divider(color: Colors.grey, thickness: 1),
            // map through stock cards
            for (var stockCard in stockCards)...[
              Row(
                children: [
                  Expanded(child: Text( formatDateTime(stockCard.date), style: AppTextStyles.subheadingBlue)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Text("Description", style: AppTextStyles.labelPink),
                        Text(stockCard.description, style: AppTextStyles.bodyBlue),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Text("Gram", style: AppTextStyles.labelPink),
                        Container(
                          width: 80,
                          padding: EdgeInsets.symmetric(vertical: 3, horizontal: 3), // Padding di sekitar teks
                          decoration: BoxDecoration(
                            color: double.tryParse(stockCard.weightIn) != null && double.tryParse(stockCard.weightIn)! > 0
                                ? AppColors.success
                                : AppColors.error, // Background color
                            borderRadius: BorderRadius.circular(12), // Menambahkan border radius (melengkung)
                          ),
                          child: Text(
                            double.tryParse(stockCard.weightIn) != null && double.tryParse(stockCard.weightIn)! > 0
                                ? stockCard.weightIn
                                : '-${stockCard.weightOut}',
                            style: AppTextStyles.bodyWhite.copyWith(
                              fontWeight: FontWeight.w600, // Font weight
                            ),
                            // center
                            textAlign: TextAlign.center,
                          ),
                        ),



                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Text("Buy / Sold Price", style: AppTextStyles.labelPink),
                        Text( formatCurrency(stockCard.price ?? 0), style: AppTextStyles.bodyBlue),
                      ],
                    ),
                  ),
                ],
              ),
              // jarak antar next baris
              const SizedBox(height: 10),
            ]
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final actions = context.read<PermissionCubit>().state.actions(
      'inventory/check-product',
    );
    return Scaffold(
      body: CustomScrollView(
        scrollBehavior: const CupertinoScrollBehavior(),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true, // Ensures the app bar remains visible when scrolling
            floating: false, // No snap effect
            elevation: 0,
            title: Text('Check Product', style: AppTextStyles.headingWhite),
            leading: IconButton(
              icon: const Icon(CupertinoIcons.arrow_left, color: Colors.white),
              onPressed: () {
                context.pop();
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Button scan and search product
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Row(
                      children: [
                        // Button scan qr
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              // Scan QR penjualan Produk
                              _qrScan();
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.pinkPrimary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.qr_code, color: Colors.white),
                                  Text(
                                    "Scan QR\nPenjualan produk",
                                    style: AppTextStyles.labelWhite,
                                    softWrap: true,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12), // spacing antar tombol
                        // btn pencarian produk
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              // Search by notificationSheet penjualan Produk
                              _showPromptProduct();
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.bluePrimary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.search, color: Colors.white),
                                  Text(
                                    "Pencarian\nPenjualan produk",
                                    style: AppTextStyles.labelWhite,
                                    softWrap: true,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16), // jarak antar baris
                  // Widget Product Details di baris baru
                  if (productCode != null) productDetailCard(),
                  SizedBox(height: 16), // jarak antar baris
                  if (stockCards.isNotEmpty) productHistoryDetail(),
                ],
              ),
            ),
          ),

          // Loading Indicator
          if (isLoading)
            SliverToBoxAdapter(
              child: const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 52),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          if (!isLoading && productCode == null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 52),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        "Silahkan Cari Produk",
                        style: AppTextStyles.labelGrey,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
