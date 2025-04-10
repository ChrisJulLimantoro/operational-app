import 'package:flutter/material.dart';
import 'package:operational_app/model/transaction_operation.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/item_card_detail.dart';
import 'package:operational_app/widget/text_card_detail.dart';

class TransactionOperationSection extends StatelessWidget {
  final String title;
  final List<TransactionOperation> operations;
  final double totalPrice;
  final Function(int index)? onRemove;
  final bool readonly;

  const TransactionOperationSection({
    super.key,
    required this.title,
    required this.operations,
    required this.totalPrice,
    this.onRemove,
    this.readonly = true,
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
              (operation) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ItemCardDetail(
                          name: operation.name.split(' - ')[1],
                          code: operation.name.split(' - ')[0],
                          totalPrice: operation.totalPrice,
                        ),
                      ),
                      if (!readonly)
                        IconButton(
                          icon: Icon(Icons.delete, color: AppColors.error),
                          onPressed: () {
                            if (onRemove != null) {
                              onRemove?.call(operations.indexOf(operation));
                            }
                          },
                        ),
                    ],
                  ),
                ],
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
