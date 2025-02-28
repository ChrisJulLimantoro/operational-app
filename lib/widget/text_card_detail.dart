import 'package:flutter/material.dart';
import 'package:operational_app/helper/format_currency.dart';
import 'package:operational_app/helper/format_date.dart';
import 'package:operational_app/theme/text.dart';

class TextCardDetail extends StatelessWidget {
  final String label;
  final dynamic value;
  final String type;
  final bool isLong;
  final TextStyle textStyle;
  const TextCardDetail({
    super.key,
    required this.label,
    required this.value,
    required this.type,
    this.isLong = false,
    this.textStyle = AppTextStyles.labelBlue,
  });

  @override
  Widget build(BuildContext context) {
    return isLong
        ? Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Text(label, style: AppTextStyles.subheadingBlue),
            Text(
              type == 'currency'
                  ? CurrencyHelper.formatRupiah(value)
                  : type == 'date'
                  ? DateHelper.formatDate(value)
                  : value,
              style: AppTextStyles.labelBlue,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        )
        : Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(label, style: AppTextStyles.subheadingBlue),
            Text(
              type == 'currency'
                  ? CurrencyHelper.formatRupiah(value)
                  : type == 'date'
                  ? DateHelper.formatDate(value)
                  : value,
              style: textStyle,
            ),
          ],
        );
  }
}
