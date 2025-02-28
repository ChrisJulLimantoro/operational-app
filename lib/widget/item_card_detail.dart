import 'package:flutter/material.dart';
import 'package:operational_app/helper/format_currency.dart';
import 'package:operational_app/theme/text.dart';

class ItemCardDetail extends StatelessWidget {
  final String name;
  final String code;
  final double totalPrice;
  const ItemCardDetail({
    super.key,
    required this.name,
    required this.code,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: AppTextStyles.subheadingBlue,
              overflow: TextOverflow.ellipsis,
            ),
            Text(code, style: AppTextStyles.labelBlueItalic),
          ],
        ),
        // Total Harga
        Text(
          CurrencyHelper.formatRupiah(totalPrice),
          style: AppTextStyles.labelPink,
        ),
      ],
    );
  }
}
