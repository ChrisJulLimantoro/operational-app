import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:operational_app/api/stock_opname.dart';
import 'package:operational_app/bloc/permission_bloc.dart';
import 'package:operational_app/model/stock_opname.dart';
import 'package:operational_app/notifier/stock_opname_notifier.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/text_card_detail.dart';
import 'package:provider/provider.dart';

class StockOpnameCard extends StatefulWidget {
  final StockOpname stockOpname;
  const StockOpnameCard({super.key, required this.stockOpname});

  @override
  State<StockOpnameCard> createState() => _StockOpnameCardState();
}

class _StockOpnameCardState extends State<StockOpnameCard> {
  bool approve = false;
  int status = 0;

  Future<void> _toogleApprove(BuildContext context, bool approve) async {
    // Implement your approve logic here
    if (!context.mounted) return;
    final response =
        approve
            ? await StockOpnameAPI.approve(context, widget.stockOpname.id)
            : await StockOpnameAPI.disapprove(context, widget.stockOpname.id);
    if (response) {
      // Refresh the stock opname list
      Provider.of<StockOpnameNotifier>(context, listen: false).markForRefresh();
    }
  }

  @override
  void initState() {
    super.initState();
    approve = widget.stockOpname.approve;
    status = widget.stockOpname.status;
  }

  @override
  Widget build(BuildContext context) {
    final actions = context.read<PermissionCubit>().state.actions(
      'inventory/stock-opname',
    );

    return InkWell(
      onTap: () {
        if (actions.contains('detail')) {
          GoRouter.of(
            context,
          ).push('/stock-opname-detail', extra: widget.stockOpname);
        }
      },
      child: Card(
        color: Colors.white,
        elevation: 1,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.stockOpname.category?.code} | ${widget.stockOpname.category?.name}',
                    style: AppTextStyles.headingBlue,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Row(
                    children: [
                      // Expandable Status Container
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, // More padding for dynamic text
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.pinkTertiary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          widget.stockOpname.status == 0
                              ? "Draft"
                              : "Done", // This text can expand dynamically
                          style: AppTextStyles.labelPink,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ), // Space between status and button
                      // Approve/Disapprove Button
                      !widget.stockOpname.approve && actions.contains('approve')
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
                              onPressed: () {
                                debugPrint("Approve Button Clicked");
                                _toogleApprove(context, true);
                              },
                            ),
                          )
                          : widget.stockOpname.approve &&
                              actions.contains('disapprove')
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
                                _toogleApprove(context, false);
                              },
                            ),
                          )
                          : SizedBox(),
                    ],
                  ),
                ],
              ),
              Divider(),
              TextCardDetail(
                label: 'Cabang',
                value: '${widget.stockOpname.store?.name}',
                type: 'text',
              ),
              TextCardDetail(
                label: 'Tanggal',
                value: widget.stockOpname.date,
                type: 'date',
              ),
              TextCardDetail(
                label: 'Barang yang telah di-scan',
                value:
                    '${widget.stockOpname.details.where((d) => d.scanned).length}',
                type: 'text',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
