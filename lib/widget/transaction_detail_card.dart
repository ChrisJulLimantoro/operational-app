import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:operational_app/model/transaction_product.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/text_card_detail.dart';
import 'package:operational_app/helper/format_currency.dart';

class TransactionDetailCard extends StatefulWidget {
  final TransactionProduct transactionProduct;
  final Function(int index)? onRemove;
  final int? index;
  final bool readonly;

  const TransactionDetailCard({
    super.key,
    required this.transactionProduct,
    this.onRemove,
    this.index,
    this.readonly = true,
  });

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
            children: [
              // Kiri (judul), pakai Expanded supaya dia mengisi sisa ruang
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.transactionProduct.productCodeId != '' && widget.transactionProduct.name.contains(' - ')
                          ? widget.transactionProduct.name.split(' - ')[1]
                          : 'Outside Product',
                      style: AppTextStyles.labelBlue,
                    ),
                    Text(
                      widget.transactionProduct.productCodeId != '' && widget.transactionProduct.name.contains(' - ')
                          ? widget.transactionProduct.name.split(' - ')[0]
                          : '-',
                      style: AppTextStyles.labelBlueItalic,
                    ),
                  ],
                ),
              ),

              // Kanan (harga + icon), pakai IntrinsicWidth dan ConstrainedBox untuk batasi max lebar teks
              IntrinsicWidth(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 100), // sesuaikan maxWidth-nya
                      child: Text(
                        CurrencyHelper.formatRupiah(widget.transactionProduct.totalPrice),
                        style: AppTextStyles.labelPink,
                        softWrap: true,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isOpen ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
                      color: AppColors.pinkPrimary,
                      size: 20.0,
                    ),
                  ],
                ),
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
                  if (widget.transactionProduct.isBroken)
                    TextCardDetail(
                      label: "Kondisi",
                      value: "Rusak",
                      type: "string",
                    ),
                  TextCardDetail(
                    label: "Keterangan",
                    value: widget.transactionProduct.comment,
                    type: "string",
                    isLong: true,
                  ),
                  if (!widget.readonly) const Divider(),
                  if (!widget.readonly)
                    InkWell(
                      onTap: () {
                        // Scan QR pembelian Produk
                        widget.onRemove?.call(widget.index ?? -1);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 4,
                          children: [
                            Icon(
                              CupertinoIcons.trash,
                              size: 18,
                              color: Colors.white,
                            ),
                            Text(
                              "Hapus",
                              style: AppTextStyles.labelWhite,
                              softWrap: true,
                              maxLines: 2,
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
    );
  }
}
