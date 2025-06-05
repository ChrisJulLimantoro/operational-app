import 'package:flutter/material.dart';
import 'package:operational_app/model/transaction_operation.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/text_card_detail.dart';
import 'package:operational_app/widget/transaction_operation_detail_card.dart';

class TransactionOperationSection extends StatelessWidget {
  final String title;
  final List<TransactionOperation> operations;
  final double totalPrice;
  final Function(int index)? onRemove;
  final Function(int index)? onEdit;
  final bool readonly;
  final bool isFlex;

  const TransactionOperationSection({
    super.key,
    required this.title,
    required this.operations,
    required this.totalPrice,
    this.onRemove,
    this.onEdit,
    this.readonly = true,
    this.isFlex = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Text(title, style: AppTextStyles.headingBlue),
            Divider(),
            if (operations.isEmpty)
              Center(
                child: Text("Belum ada jasa", style: AppTextStyles.labelPink),
              ),
            ...operations.map(
              (operation) => TransactionOperationDetailCard(
                transactionOperation: operation,
                onRemove: onRemove,
                onEdit: onEdit,
                index: operations.indexOf(operation),
                readonly: readonly,
                isFlex: isFlex,
              ),
            ),
            Divider(),
            TextCardDetail(
              label: "Total Harga Jasa",
              value: totalPrice,
              type: "currency",
              textStyle: AppTextStyles.labelPink,
            ),
          ],
        ),
      ),
    );
  }
}
