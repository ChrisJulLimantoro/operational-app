import 'package:flutter/material.dart';
import 'package:operational_app/model/product.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:operational_app/widget/text_card_detail.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true, // Ensures the app bar remains visible when scrolling
            floating: false, // No snap effect
            elevation: 0,
            title: Text(widget.product.name, style: AppTextStyles.headingWhite),
            leading: IconButton(
              icon: const Icon(CupertinoIcons.arrow_left, color: Colors.white),
              onPressed: () {
                context.pop();
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: Colors.white,
                    elevation: 1,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Text(
                            'Detail Produk',
                            style: AppTextStyles.headingBlue,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Divider(),
                          TextCardDetail(
                            label: 'Kode',
                            value: widget.product.code,
                            type: "text",
                          ),
                          TextCardDetail(
                            label: 'Kategori',
                            value:
                                '${widget.product.type.category?.code ?? ''} | ${widget.product.type.category?.name ?? ''}',
                            type: 'text',
                          ),
                          TextCardDetail(
                            label: 'Sub Kategori',
                            value:
                                '${widget.product.type.code} | ${widget.product.type.name}',
                            type: 'text',
                          ),
                          TextCardDetail(
                            label: 'Jumlah Barang',
                            value:
                                widget.product.productCodes.length.toString(),
                            type: 'text',
                          ),
                          TextCardDetail(
                            label: 'Jumlah Barang di stok',
                            value:
                                widget.product.productCodes
                                    .where((pc) => pc.status == 0)
                                    .length
                                    .toString(),
                            type: 'text',
                          ),
                          TextCardDetail(
                            label: 'Jumlah Barang terjual',
                            value:
                                widget.product.productCodes
                                    .where((pc) => pc.status == 1)
                                    .length
                                    .toString(),
                            type: 'text',
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 16.0,
                    ),
                    child: Text(
                      'Daftar Barang (${widget.product.productCodes.length})',
                      style: AppTextStyles.headingBlue,
                    ),
                  ),
                  ...widget.product.productCodes.map(
                    (pc) => Card(
                      color: Colors.white,
                      elevation: 1,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  pc.barcode,
                                  style: AppTextStyles.subheadingBlue,
                                ),
                                IntrinsicHeight(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ), // Adjust padding
                                    decoration: BoxDecoration(
                                      color:
                                          pc.status == 0
                                              ? AppColors.success
                                              : pc.status == 2
                                              ? AppColors.pinkPrimary
                                              : AppColors
                                                  .error, // Change based on status
                                      borderRadius: BorderRadius.circular(
                                        8,
                                      ), // Rounded corners
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      pc.status == 0
                                          ? 'Stok'
                                          : pc.status == 1
                                          ? 'Terjual'
                                          : pc.status == 2
                                          ? 'Kembali'
                                          : 'Ditarik',
                                      style: AppTextStyles.labelWhite,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Divider(),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child:
                                  pc.image != null
                                      ? Image.network(
                                        'http://localhost:3000/${pc.image}',
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.scaleDown,
                                      )
                                      : Container(
                                        color: AppColors.pinkTertiary,
                                        height: 200,
                                        child: Center(
                                          child: Text(
                                            'No Image',
                                            style: AppTextStyles.labelPink,
                                          ),
                                        ),
                                      ),
                            ),
                            Divider(),
                            TextCardDetail(
                              label: 'Berat',
                              value: pc.weight.toString(),
                              type: 'text',
                            ),
                            TextCardDetail(
                              label: 'Harga Beli',
                              value: pc.buyPrice,
                              type: 'currency',
                            ),
                            TextCardDetail(
                              label: 'Pajak Pembelian',
                              value: pc.taxPurchase,
                              type: 'currency',
                            ),
                            TextCardDetail(
                              label: 'Harga Jual per gram',
                              value: pc.fixedPrice,
                              type: 'currency',
                            ),
                          ],
                        ),
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
