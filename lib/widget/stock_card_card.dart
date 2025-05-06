import 'package:flutter/material.dart';
import 'package:operational_app/model/stock_card.dart';
import 'package:operational_app/theme/text.dart';
import 'package:intl/intl.dart';

class StockCardCard extends StatelessWidget {
  final StockCard stockCard;
  const StockCardCard({super.key, required this.stockCard});

String formatCustomDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year} '
         '${date.hour.toString().padLeft(2, '0')}.'
         '${date.minute.toString().padLeft(2, '0')}.'
         '${date.second.toString().padLeft(2, '0')}';
}

  @override
  Widget build(BuildContext context) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

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
                style: AppTextStyles.bodyBlue,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                gram,
                textAlign: TextAlign.right,
                style: AppTextStyles.bodyBlue,
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () {
        // Navigation logic here
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      stockCard.name,
                      style: AppTextStyles.headingBlue,
                      softWrap: true,
                    ),
                  ),
                  const SizedBox(width: 12), // jarak antar teks
                  Text(
                    formatCustomDate(stockCard.date),
                    style: AppTextStyles.headingBlue,
                    softWrap: true,
                  ),
                ],
              ),
              const Divider(),
              // Tanggal Transaksi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tanggal Transaksi',
                    style: AppTextStyles.labelBlue,
                  ),
                  Text(
                    formatCustomDate(stockCard.date),
                    style: AppTextStyles.bodyBlue,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kode Produk',
                    style: AppTextStyles.labelBlue,
                  ),
                  Text(
                    stockCard.code,
                    style: AppTextStyles.bodyBlue,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Deskripsi',
                    style: AppTextStyles.labelBlue,
                  ),
                  Text(
                    stockCard.description,
                    style: AppTextStyles.bodyBlue,
                  ),
                ],
              ),

              // DETAILS
              buildRow('Masuk', '${stockCard.inQty}', '${stockCard.weightIn} gr'),
              buildRow('Keluar', '${stockCard.outQty}', '${stockCard.weightOut} gr'),
              buildRow('Saldo', '${stockCard.balance}', '${stockCard.balanceWeight} gr'),

              const SizedBox(height: 12),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Harga per gram',
                    style: AppTextStyles.labelBlue.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formatter.format(double.tryParse(stockCard.avgPricePerWeight) ?? 0),
                    style: AppTextStyles.bodyBlue.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nilai Stock',
                    style: AppTextStyles.bodyBlue.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formatter.format(
                      (double.tryParse(stockCard.avgPricePerWeight) ?? 0) *
                          (double.tryParse(stockCard.balanceWeight) ?? 0),
                    ),
                    style: AppTextStyles.bodyBlue.copyWith(fontWeight: FontWeight.bold),
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