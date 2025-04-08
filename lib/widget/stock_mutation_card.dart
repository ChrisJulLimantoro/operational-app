import 'package:flutter/material.dart';
import 'package:operational_app/model/stock_mutation.dart';
import 'package:operational_app/theme/text.dart';
import 'package:intl/intl.dart';

class StockMutationCard extends StatelessWidget {
  final StockMutation stockMutation;
  const StockMutationCard({super.key, required this.stockMutation});

  @override
  Widget build(BuildContext context) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    // Helper to build row with 3 columns, right-aligned values
    Widget buildRow(String label, String value, String gram) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Text(label, style: AppTextStyles.labelBlue),
            ),
            Expanded(
              flex: 2,
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: AppTextStyles.labelBlue,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                gram,
                textAlign: TextAlign.right,
                style: AppTextStyles.labelBlue,
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () {
        // GoRouter.of(context).push('/stock-mutation-detail', extra: stockMutation);
      },
      child: Card(
        color: Colors.white,
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Text(
                ' ${stockMutation.categoryName ?? "Not yet assigned category"}',
                style: AppTextStyles.headingBlue,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const Divider(),

              // DETAILS
              buildRow('Stok Awal', '${stockMutation.initialStock}', '${stockMutation.initialStockGram} gr'),
              buildRow('Masuk', '${stockMutation.inGoods}', '${stockMutation.inGoodsGram} gr'),
              buildRow('Penjualan', '${stockMutation.sales}', '${stockMutation.salesGram} gr'),
              buildRow('Keluar', '${stockMutation.outGoods}', '${stockMutation.outGoodsGram} gr'),
              buildRow('Pembelian', '${stockMutation.purchase}', '${stockMutation.purchaseGram} gr'),
              buildRow('Tukar tambah/ tukar kurang', '${stockMutation.trade}', '${stockMutation.tradeGram} gr'),
              buildRow('Stok Akhir', '${stockMutation.finals}', '${stockMutation.finalGram} gr'),

              const SizedBox(height: 12),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Harga per gram',
                    style: AppTextStyles.subheadingBlue.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formatter.format(double.parse(stockMutation.unitPrice)),
                    style: AppTextStyles.subheadingBlue.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nilai Stock',
                    style: AppTextStyles.subheadingBlue.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formatter.format(
                      double.parse(stockMutation.unitPrice) * double.parse(stockMutation.finals),
                    ),
                    style: AppTextStyles.subheadingBlue.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}