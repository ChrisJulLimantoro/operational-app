import 'package:flutter/material.dart';
import 'package:operational_app/model/transaction_product.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/text_card_detail.dart';
import 'package:operational_app/widget/transaction_detail_card.dart';

class TransactionProductSection extends StatelessWidget {
  final String title;
  final List<TransactionProduct> products;
  final double totalWeight;
  final double totalPrice;

  const TransactionProductSection({
    super.key,
    required this.title,
    required this.products,
    required this.totalWeight,
    required this.totalPrice,
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
            ...products.map(
              (product) => TransactionDetailCard(transactionProduct: product),
            ),
            Divider(),
            TextCardDetail(
              label: "Berat Total",
              value: "$totalWeight g",
              type: "string",
              textStyle: AppTextStyles.labelPink,
            ),
            TextCardDetail(
              label: "Total Harga",
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
