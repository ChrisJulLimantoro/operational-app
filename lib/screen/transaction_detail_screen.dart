import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:operational_app/model/transaction.dart';
import 'package:operational_app/model/transaction_operation.dart';
import 'package:operational_app/model/transaction_product.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/text_card_detail.dart';
import 'package:operational_app/widget/transaction_operation_section.dart';
import 'package:operational_app/widget/transaction_product_section.dart';

class TransactionDetailScreen extends StatefulWidget {
  final Transaction transaction;
  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  List<Map<String, dynamic>> items = [];
  List<TransactionProduct> itemSold = [];
  List<TransactionProduct> itemBought = [];
  List<TransactionOperation> operations = [];
  bool isOpen = false;

  void _viewNota() {
    if (widget.transaction.notaLink == null) {
      debugPrint("Nota link is null.");
      return;
    }

    context.push(
      '/pdf-viewer',
      extra: {
        'pdfUrl': widget.transaction.id,
        'fileName': 'nota-${widget.transaction.code}',
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Initialize items Details
    items = [
      {
        "label": "Kode",
        "value": widget.transaction.code,
        "type": "string",
        "isLong": false,
      },
      {
        "label": "Tanggal",
        "value": widget.transaction.date,
        "type": "date",
        "isLong": false,
      },
      {
        "label": "Sales",
        "value": widget.transaction.employee?.name ?? '-',
        "type": "string",
        "isLong": false,
      },
      {
        "label": "Jenis",
        "value":
            widget.transaction.transactionType == 1 ? 'Penjualan' : 'Pembelian',
        "type": "string",
        "isLong": false,
      },
      {
        "label": "Customer",
        "value": widget.transaction.customer?.name ?? '-',
        "type": "string",
        "isLong": false,
      },
      {
        "label": "Customer Email",
        "value": widget.transaction.customer?.email ?? '-',
        "type": "string",
        "isLong": false,
      },
      {
        "label": "Keterangan",
        "value": widget.transaction.comment,
        "type": "string",
        "isLong": true,
      },
    ];
    itemSold =
        widget.transaction.transactionProducts
            .where((item) => item.transactionType == 1)
            .toList();
    itemBought =
        widget.transaction.transactionProducts
            .where((item) => item.transactionType == 2)
            .toList();
    operations = widget.transaction.transactionOperations;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(
              widget.transaction.code,
              style: AppTextStyles.headingWhite,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            // Printing Nota
                            _viewNota();
                          },
                          child: Container(
                            height: 50, // Adjust height as needed
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
                  Card(
                    color: Colors.white,
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
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
                      totalWeight: itemSold.fold(
                        0.0,
                        (previousValue, element) =>
                            previousValue + element.weight,
                      ),
                      totalPrice: itemSold.fold(
                        0.0,
                        (previousValue, element) =>
                            previousValue + element.totalPrice,
                      ),
                    ),
                  if (itemBought.isNotEmpty)
                    TransactionProductSection(
                      title: "Detail Pembelian",
                      products: itemBought,
                      totalWeight: itemBought.fold(
                        0.0,
                        (previousValue, element) =>
                            previousValue + element.weight,
                      ),
                      totalPrice: itemBought.fold(
                        0.0,
                        (previousValue, element) =>
                            previousValue + element.totalPrice,
                      ),
                    ),
                  if (operations.isNotEmpty)
                    TransactionOperationSection(
                      title: "Detail Jasa",
                      operations: operations,
                      totalPrice: operations.fold(
                        0.0,
                        (previousValue, element) =>
                            previousValue + element.totalPrice,
                      ),
                    ),
                  Card(
                    color: Colors.white,
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 20.0,
                      ),
                      child: Column(
                        spacing: 6,
                        children: [
                          TextCardDetail(
                            label: "Subtotal",
                            value: widget.transaction.subTotalPrice,
                            type: "currency",
                            textStyle: AppTextStyles.labelPink,
                          ),
                          TextCardDetail(
                            label: "Pajak",
                            value: widget.transaction.taxPrice,
                            type: "currency",
                            textStyle: AppTextStyles.labelPink,
                          ),
                          widget.transaction.transactionType == 3
                              ? TextCardDetail(
                                label: "Biaya Tukar Tambah",
                                value: widget.transaction.adjustmentPrice,
                                type: "currency",
                                textStyle: AppTextStyles.labelPink,
                              )
                              : const SizedBox(),
                          Divider(),
                          TextCardDetail(
                            label: "Total",
                            value: widget.transaction.totalPrice,
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
