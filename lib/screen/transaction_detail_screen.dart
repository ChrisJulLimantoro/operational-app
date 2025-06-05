import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:operational_app/api/transaction.dart';
import 'package:operational_app/model/transaction.dart';
import 'package:operational_app/model/transaction_operation.dart';
import 'package:operational_app/model/transaction_product.dart';
import 'package:operational_app/notifier/detail_notifier.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/text_card_detail.dart';
import 'package:operational_app/widget/transaction_operation_section.dart';
import 'package:operational_app/widget/transaction_product_section.dart';
import 'package:provider/provider.dart';

class TransactionDetailScreen extends StatefulWidget {
  final String transactionId;
  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  Transaction? transaction;
  bool isLoading = true;

  List<Map<String, dynamic>> items = [];
  List<TransactionProduct> itemSold = [];
  List<TransactionProduct> itemBought = [];
  List<TransactionOperation> operations = [];

  @override
  void initState() {
    super.initState();
    _fetchTransaction();
  }

  Future<void> _fetchTransaction() async {
    setState(() => isLoading = true);
    try {
      final result = await TransactionAPI.fetchTransactionById(
        context,
        widget.transactionId,
      );
      setState(() {
        transaction = result;
        _prepareTransactionData();
      });
    } catch (e) {
      debugPrint('Failed to fetch transaction: $e');
      // Show error UI or Snackbar
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _prepareTransactionData() {
    if (transaction == null) return;

    items = [
      {
        "label": "Kode",
        "value": transaction!.code,
        "type": "string",
        "isLong": false,
      },
      {
        "label": "Tanggal",
        "value": transaction!.date,
        "type": "date",
        "isLong": false,
      },
      {
        "label": "Sales",
        "value": transaction!.employee?.name ?? '-',
        "type": "string",
        "isLong": false,
      },
      {
        "label": "Jenis",
        "value": transaction!.transactionType == 1 ? 'Penjualan' : 'Pembelian',
        "type": "string",
        "isLong": false,
      },
      {
        "label": "Customer",
        "value": transaction!.customer?.name ?? '-',
        "type": "string",
        "isLong": false,
      },
      {
        "label": "Customer Email",
        "value": transaction!.customer?.email ?? '-',
        "type": "string",
        "isLong": false,
      },
      {
        "label": "Keterangan",
        "value": transaction!.comment,
        "type": "string",
        "isLong": true,
      },
    ];

    itemSold =
        transaction!.transactionProducts
            .where((item) => item.transactionType == 1)
            .toList();

    itemBought =
        transaction!.transactionProducts
            .where((item) => item.transactionType == 2)
            .toList();

    operations = transaction!.transactionOperations;
  }

  void _viewNota() {
    if (transaction?.notaLink == null) {
      debugPrint("Nota link is null.");
      return;
    }

    context.push(
      '/pdf-viewer',
      extra: {
        'pdfUrl': transaction!.id,
        'fileName': 'nota-${transaction!.code}',
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final notifier = Provider.of<DetailNotifier>(context);
    if (notifier.shouldRefresh) {
      _fetchTransaction();
      notifier.resetRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || transaction == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(transaction!.code, style: AppTextStyles.headingWhite),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            GoRouter.of(
                              context,
                            ).push('/transaction/edit', extra: transaction);
                          },
                          child: Container(
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.bluePrimary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Edit Transaksi",
                              style: AppTextStyles.labelWhite,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: _viewNota,
                          child: Container(
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.pinkPrimary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Delete Transaksi",
                              style: AppTextStyles.labelWhite,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _viewNota,
                          child: Container(
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.pinkPrimary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "View Nota",
                              style: AppTextStyles.labelWhite,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // --- Details Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 6,
                        children: [
                          Text(
                            "Detail Transaksi",
                            style: AppTextStyles.headingBlue,
                          ),
                          Divider(),
                          ...items.map(
                            (item) => TextCardDetail(
                              label: item['label'],
                              value: item['value'],
                              type: item['type'],
                              isLong: item['isLong'],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (itemSold.isNotEmpty)
                    TransactionProductSection(
                      title: "Detail Penjualan",
                      products: itemSold,
                      totalWeight: itemSold.fold(0.0, (p, e) => p + e.weight),
                      totalPrice: itemSold.fold(
                        0.0,
                        (p, e) => p + e.totalPrice,
                      ),
                    ),
                  if (itemBought.isNotEmpty)
                    TransactionProductSection(
                      title: "Detail Pembelian",
                      products: itemBought,
                      totalWeight: itemBought.fold(0.0, (p, e) => p + e.weight),
                      totalPrice: itemBought.fold(
                        0.0,
                        (p, e) => p + e.totalPrice,
                      ),
                    ),
                  if (operations.isNotEmpty)
                    TransactionOperationSection(
                      title: "Detail Jasa",
                      operations: operations,
                      totalPrice: operations.fold(
                        0.0,
                        (p, e) => p + e.totalPrice,
                      ),
                    ),
                  Card(
                    color: Colors.white,
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: Column(
                        spacing: 6,
                        children: [
                          TextCardDetail(
                            label: "Subtotal",
                            value: transaction!.subTotalPrice,
                            type: "currency",
                            textStyle: AppTextStyles.labelPink,
                          ),
                          TextCardDetail(
                            label: "Pajak (${transaction!.taxPercent}%)",
                            value: transaction!.taxPrice,
                            type: "currency",
                            textStyle: AppTextStyles.labelPink,
                          ),
                          if (transaction!.transactionType == 3)
                            TextCardDetail(
                              label: "Biaya Tukar Tambah",
                              value: transaction!.adjustmentPrice,
                              type: "currency",
                              textStyle: AppTextStyles.labelPink,
                            ),
                          Divider(),
                          TextCardDetail(
                            label: "Total",
                            value: transaction!.totalPrice,
                            type: "currency",
                            textStyle: AppTextStyles.labelPink,
                          ),
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
