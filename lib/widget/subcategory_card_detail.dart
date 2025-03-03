import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:operational_app/model/type.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/text_card_detail.dart';

class SubCategoryDetailCard extends StatefulWidget {
  final Type type;

  const SubCategoryDetailCard({super.key, required this.type});

  @override
  State<SubCategoryDetailCard> createState() => _SubCategoryDetailCardState();
}

class _SubCategoryDetailCardState extends State<SubCategoryDetailCard> {
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
                  Text(widget.type.name, style: AppTextStyles.labelBlue),
                  Text(widget.type.code, style: AppTextStyles.labelBlueItalic),
                ],
              ),
              Icon(
                isOpen
                    ? CupertinoIcons.chevron_up
                    : CupertinoIcons.chevron_down,
                color: AppColors.pinkPrimary,
                size: 20.0,
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
                    label: 'Kode',
                    value: widget.type.code,
                    type: "string",
                  ),
                  TextCardDetail(
                    label: 'Name',
                    value: widget.type.name,
                    type: "string",
                  ),
                  TextCardDetail(
                    label: 'Dibuat Pada',
                    value: widget.type.createdAt,
                    type: "date",
                  ),
                  TextCardDetail(
                    label: "Deskripsi",
                    value: widget.type.description,
                    type: "text",
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
