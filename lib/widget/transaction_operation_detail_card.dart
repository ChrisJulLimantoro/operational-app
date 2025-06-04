import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:operational_app/model/transaction_operation.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/text_card_detail.dart';
import 'package:operational_app/helper/format_currency.dart';

class TransactionOperationDetailCard extends StatefulWidget {
  final TransactionOperation transactionOperation;
  final Function(int index)? onRemove;
  final Function(int index)? onEdit;
  final int? index;
  final bool readonly;
  final bool isFlex;

  const TransactionOperationDetailCard({
    super.key,
    required this.transactionOperation,
    this.onRemove,
    this.onEdit,
    this.index,
    this.readonly = true,
    this.isFlex = false,
  });

  @override
  State<TransactionOperationDetailCard> createState() =>
      _TransactionDetailCardState();
}

class _TransactionDetailCardState
    extends State<TransactionOperationDetailCard> {
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
                      widget.transactionOperation.name.split(' - ')[1],
                      style: AppTextStyles.labelBlue,
                    ),
                    Text(
                      widget.transactionOperation.name.split(' - ')[0],
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
                      constraints: BoxConstraints(
                        maxWidth: 150,
                      ), // sesuaikan maxWidth-nya
                      child: Text(
                        CurrencyHelper.formatRupiah(
                          widget.transactionOperation.totalPrice,
                        ),
                        style: AppTextStyles.labelPink,
                        softWrap: true,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isOpen
                          ? CupertinoIcons.chevron_up
                          : CupertinoIcons.chevron_down,
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
                    label: 'Jumlah',
                    value: '${widget.transactionOperation.unit} mm',
                    type: "string",
                  ),
                  TextCardDetail(
                    label: 'Jenis',
                    value: widget.transactionOperation.type,
                    type: "string",
                  ),
                  TextCardDetail(
                    label: "Harga per satuan",
                    value: widget.transactionOperation.price,
                    type: "currency",
                  ),
                  TextCardDetail(
                    label: "Penyesuaian Harga",
                    value: widget.transactionOperation.adjustmentPrice,
                    type: "currency",
                  ),
                  TextCardDetail(
                    label: "Sub Total",
                    value: widget.transactionOperation.totalPrice,
                    type: "currency",
                  ),
                  const Divider(),
                  TextCardDetail(
                    label: "Keterangan",
                    value: widget.transactionOperation.comment,
                    type: "string",
                    isLong: true,
                  ),
                  if (!widget.readonly) const Divider(),
                  if (!widget.readonly && widget.isFlex)
                    InkWell(
                      onTap: () {
                        // Scan QR pembelian Produk
                        widget.onEdit?.call(widget.index ?? -1);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          color: AppColors.bluePrimary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 4,
                          children: [
                            Icon(
                              CupertinoIcons.pencil,
                              size: 18,
                              color: Colors.white,
                            ),
                            Text(
                              "Sunting",
                              style: AppTextStyles.labelWhite,
                              softWrap: true,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
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
