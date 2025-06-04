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
  final Function(int index)? onRemove;
  final Function(int index)? onEdit;
  final bool? readonly;
  final bool isFlex;

  const TransactionProductSection({
    super.key,
    required this.title,
    required this.products,
    required this.totalWeight,
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
            if (products.isEmpty)
              Center(
                child: Text("Belum ada produk", style: AppTextStyles.labelPink),
              ),
            ...products.map(
              (product) => TransactionDetailCard(
                transactionProduct: product,
                onRemove: onRemove,
                onEdit: onEdit,
                index: products.indexOf(product),
                readonly: readonly ?? true,
                isFlex: isFlex,
              ),
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
