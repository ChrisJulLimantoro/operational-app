import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:operational_app/api/transaction.dart';
import 'package:operational_app/helper/format_currency.dart';
import 'package:operational_app/helper/notification.dart';
import 'package:operational_app/model/transaction.dart';
import 'package:operational_app/notifier/sales_notifier.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/item_card_detail.dart';
import 'package:provider/provider.dart';

class TransactionCard extends StatefulWidget {
  final Transaction trans;
  final List<String> actions;

  const TransactionCard({
    super.key,
    required this.trans,
    required this.actions,
  });

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  late Transaction trans;

Future<void> _approveDisapprove(context,int prevStatus, transactionType, transId) async {
    var newStatus = (prevStatus == 0) ? 1 : 0;
    var message = newStatus == 1 ? 'Apakah anda yakin approve transaksi ${trans.code}' : 'Apakah anda yakin disapprove transaksi ${trans.code}';
    // Submit Transaction
    NotificationHelper.showNotificationSheet(
      context: context,
      title: "Konfirmasi",
      primaryColor: AppColors.pinkPrimary,
      message: message,
      primaryButtonText: "Ya",
      secondaryButtonText: "Batalkan",
      onPrimaryPressed: () async {
        debugPrint('apprpve lanjut');
        final response = await TransactionAPI.approveDisapprove(context, newStatus, transId);
        debugPrint(response.toString());
        if (response) {
          NotificationHelper.showNotificationSheet(
            context: context,
            title: "Berhasil",
            message: "Transaksi berhasil di-${newStatus == 1 ? 'approve' : 'disapprove'}",
            icon: Icons.check_circle_outline,
            primaryColor: AppColors.success,
            primaryButtonText: "OK",
            onPrimaryPressed: () {
              Provider.of<SalesNotifier>(context, listen: false).markForRefresh();
              context.pop();
            },
          );
        }

      },
    );
  }

  @override
  void initState() {
    super.initState();
    trans = widget.trans; // Store the received parameter
    debugPrint(trans.toString());
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(widget.actions.toString());
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap:
            () => {
              if (widget.actions.contains('detail'))
                {context.push('/transaction-detail', extra: trans)},
            },
        borderRadius: BorderRadius.circular(8),

        child: Card(
          color: Colors.white,
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween, // Ensures left-right alignment
                  children: [
                    // Transaction Code on the Left
                    Text(trans.code, style: AppTextStyles.subheadingBlue),

                    // Right-side status and button grouped together
                    Row(
                      spacing: 8,
                      children: [
                        // Delete Button
                        // trans.approve == 0 && widget.actions.contains('delete')
                        //     ? Container(
                        //       height: 32,
                        //       width: 48,
                        //       decoration: BoxDecoration(
                        //         color: AppColors.error,
                        //         borderRadius: BorderRadius.circular(8),
                        //       ),
                        //       child: IconButton(
                        //         icon: Icon(CupertinoIcons.delete),
                        //         iconSize: 16.0,
                        //         color: AppColors.textWhite,
                        //         padding: EdgeInsets.all(0),
                        //         onPressed: () {
                        //           debugPrint("Approve Button Clicked");
                        //         },
                        //       ),
                        //     )
                        //     : SizedBox(),
                        // Approve/Disapprove Button
                        trans.approve == 0 && widget.actions.contains('approve')
                            ? Container(
                              height: 32,
                              width: 48,
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: Icon(CupertinoIcons.check_mark),
                                iconSize: 16.0,
                                color: AppColors.textWhite,
                                padding: EdgeInsets.all(0),
                                onPressed:  () async {
                                  debugPrint("Approve Button Clicked");
                                  debugPrint(this.trans.transactionType.toString());              
                                  _approveDisapprove(context,trans.approve, this.trans.transactionType, trans.id);
                  
                                },
                              ),
                            )
                            : widget.actions.contains('disapprove') &&
                                trans.approve == 1
                            ? Container(
                              height: 32,
                              width: 48,
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: Icon(CupertinoIcons.xmark),
                                iconSize: 16.0,
                                color: AppColors.textWhite,
                                padding: EdgeInsets.all(0),
                                onPressed: () {
                                  debugPrint("Disapprove Button Clicked");
                                  _approveDisapprove(context,trans.approve, this.trans.transactionType, trans.id);
                                },
                              ),
                            )
                            : SizedBox(),
                      ],
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Transaction Employee Name
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Text("Sales", style: AppTextStyles.labelPink),
                          Text(
                            trans.employee?.name ?? "-",
                            style: AppTextStyles.bodyBlue,
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Text("Customer", style: AppTextStyles.labelPink),
                          Text(
                            trans.customer?.name ?? "-",
                            style: AppTextStyles.bodyBlue,
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Text("Payment", style: AppTextStyles.labelPink),
                          Text(
                            trans.paymentMethod == 1
                                ? "Cash"
                                : trans.paymentMethod == 2
                                ? "Transfer"
                                : "Debit",
                            style: AppTextStyles.bodyBlue,
                          ),
                        ],
                      ),
                    ),
                    // Transaction Customer Name
                  ],
                ),
                // Description / comment
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text("Comment", style: AppTextStyles.labelPink),
                    Text(
                      trans.comment,
                      style: AppTextStyles.bodyBlue,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                // Separator
                const Divider(color: Colors.grey, thickness: 0.3),

                // Sales Details (Only if Products Exist)
                if (trans.transactionProducts.isNotEmpty) ...[
                  Text("Penjualan", style: AppTextStyles.labelPink),
                  Column(
                    children:
                        trans.transactionProducts
                            .map(
                              (product) =>
                                  product.productCodeId != ''
                                      ? ItemCardDetail(
                                        name: product.name.split(' - ')[1],
                                        code: product.name.split(' - ')[0],
                                        totalPrice: product.totalPrice,
                                      )
                                      : ItemCardDetail(
                                        name: 'Outside Product',
                                        code: '${product.weight} gr',
                                        totalPrice: product.totalPrice,
                                      ),
                            )
                            .toList(),
                  ),
                ],
                if (trans.transactionOperations.isNotEmpty) ...[
                  Text("Layanan Jasa", style: AppTextStyles.labelPink),
                  Column(
                    children:
                        trans.transactionOperations
                            .map(
                              (operation) => ItemCardDetail(
                                name: operation.name.split(' - ')[1],
                                code: operation.name.split(' - ')[0],
                                totalPrice: operation.totalPrice,
                              ),
                            )
                            .toList(),
                  ),
                ],

                // Separator
                const Divider(color: Colors.grey, thickness: 0.3),
                // Sub total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Subtotal", style: AppTextStyles.labelBlueItalic),
                    Text(
                      CurrencyHelper.formatRupiah(trans.subTotalPrice),
                      style: AppTextStyles.labelPink,
                    ),
                  ],
                ),
                // Tax
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Tax", style: AppTextStyles.labelBlueItalic),
                    Text(
                      CurrencyHelper.formatRupiah(trans.taxPrice),
                      style: AppTextStyles.labelPink,
                    ),
                  ],
                ),
                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total", style: AppTextStyles.subheadingBlue),
                    Text(
                      CurrencyHelper.formatRupiah(trans.totalPrice),
                      style: AppTextStyles.subheadingBlue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
