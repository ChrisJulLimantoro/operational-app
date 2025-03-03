import 'package:flutter/material.dart';
import 'package:operational_app/model/type.dart';
import 'package:operational_app/model/category.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/subcategory_card_detail.dart';
import 'package:operational_app/widget/text_card_detail.dart';

class CategoryDetailScreen extends StatefulWidget {
  final Category category;
  const CategoryDetailScreen({super.key, required this.category});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  List<Map<String, dynamic>> items = [];
  List<Type> types = [];
  bool isOpen = false;

  @override
  void initState() {
    super.initState();
    // Initialize items Details
    items = [
      {
        "label": "Kode",
        "value": widget.category.code,
        "type": "string",
        "isLong": false,
      },
      {
        "label": "Karat",
        "value": widget.category.purity,
        "type": "string",
        "isLong": false,
      },
      {
        "label": "Berat Nampan",
        "value": "${widget.category.weightTray} gr",
        "type": "text",
        "isLong": false,
      },
      {
        "label": "Berat Kitir",
        "value": "${widget.category.weightPaper} gr",
        "type": "text",
        "isLong": false,
      },
      {
        "label": "Berlaku untuk Usaha",
        "value":
            "${widget.category.company.code} | ${widget.category.company.name}",
        "type": "text",
        "isLong": false,
      },
      {
        "label": "Dibuat Pada",
        "value": widget.category.createdAt,
        "type": "date",
        "isLong": false,
      },
      {
        "label": "Deskripsi",
        "value": widget.category.description,
        "type": "string",
        "isLong": true,
      },
    ];
    types = widget.category.types;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(
              widget.category.name,
              style: AppTextStyles.headingWhite,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Card(
                    color: Colors.white,
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 6,
                        children: [
                          Text(
                            "Detail Transaksi",
                            style: AppTextStyles.headingBlue,
                          ),
                          Divider(),
                          ...items.map(
                            (item) => TextCardDetail(
                              label: item['label'],
                              value: item['value'],
                              type: item['type'],
                              isLong: item['isLong'],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.white,
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 6,
                        children: [
                          Text(
                            "Sub Kategori",
                            style: AppTextStyles.headingBlue,
                          ),
                          Divider(),
                          ...types.map(
                            (type) => SubCategoryDetailCard(type: type),
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
      ),
    );
  }
}
