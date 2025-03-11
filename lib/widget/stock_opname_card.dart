import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:operational_app/model/stock_opname.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/text_card_detail.dart';

class StockOpnameCard extends StatelessWidget {
  final StockOpname stockOpname;
  const StockOpnameCard({super.key, required this.stockOpname});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        GoRouter.of(context).push('/stock-opname-detail', extra: stockOpname);
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
                    '${stockOpname.category?.code} | ${stockOpname.category?.name}',
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
                          stockOpname.status == 0
                              ? "Draft"
                              : "Done", // This text can expand dynamically
                          style: AppTextStyles.labelPink,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ), // Space between status and button
                      // Approve/Disapprove Button
                      !stockOpname.isApproved
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
                              },
                            ),
                          )
                          : Container(
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
                                debugPrint("Approve Button Clicked");
                              },
                            ),
                          ),
                    ],
                  ),
                ],
              ),
              Divider(),
              TextCardDetail(
                label: 'Cabang',
                value: '${stockOpname.store?.name}',
                type: 'text',
              ),
              TextCardDetail(
                label: 'Tanggal',
                value: stockOpname.date,
                type: 'date',
              ),
              TextCardDetail(
                label: 'Barang yang telah di-scan',
                value: '${stockOpname.details.where((d) => d.scanned).length}',
                type: 'text',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
