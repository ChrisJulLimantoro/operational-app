import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:operational_app/model/transaction_product.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/text_card_detail.dart';
import 'package:operational_app/helper/format_currency.dart';

class TransactionDetailCard extends StatefulWidget {
  final TransactionProduct transactionProduct;

  const TransactionDetailCard({super.key, required this.transactionProduct});

  @override
  State<TransactionDetailCard> createState() => _TransactionDetailCardState();
}

class _TransactionDetailCardState extends State<TransactionDetailCard> {
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.transactionProduct.name.split(' - ')[1],
                    style: AppTextStyles.labelBlue,
                  ),
                  Text(
                    widget.transactionProduct.name.split(' - ')[0],
                    style: AppTextStyles.labelBlueItalic,
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    CurrencyHelper.formatRupiah(
                      widget.transactionProduct.price,
                    ),
                    style: AppTextStyles.labelPink,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Icon(
                      isOpen
                          ? CupertinoIcons.chevron_up
                          : CupertinoIcons.chevron_down,
                      color: AppColors.pinkPrimary,
                      size: 20.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          onTap: () {
            setState(() => isOpen = !isOpen);
          },
        ),
        if (isOpen)
          Card(
            color: Colors.white,
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextCardDetail(
                    label: 'Berat',
                    value: '${widget.transactionProduct.weight} g',
                    type: "string",
                  ),
                  TextCardDetail(
                    label: 'Jenis',
                    value: widget.transactionProduct.type,
                    type: "string",
                  ),
                  TextCardDetail(
                    label: "Harga per gram",
                    value: widget.transactionProduct.price,
                    type: "currency",
                  ),
                  TextCardDetail(
                    label: "Penyesuaian Harga",
                    value: widget.transactionProduct.adjustmentPrice,
                    type: "currency",
                  ),
                  TextCardDetail(
                    label: "Sub Total",
                    value: widget.transactionProduct.totalPrice,
                    type: "currency",
                  ),
                  const Divider(),
                  TextCardDetail(
                    label: "Keterangan",
                    value: widget.transactionProduct.comment,
                    type: "string",
                    isLong: true,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
