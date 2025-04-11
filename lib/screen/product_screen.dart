import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:operational_app/api/product.dart';
import 'package:operational_app/bloc/permission_bloc.dart';
import 'package:operational_app/model/product.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:go_router/go_router.dart';
import 'package:operational_app/widget/search_bar.dart';
import 'package:operational_app/widget/text_card_detail.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final _scroll = ScrollController();
  final search = TextEditingController();
  List<Product> products = List.empty(growable: true);
  int page = 1;
  bool isLoading = false;
  bool isRefresh = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _fetchProducts();
  }

  @override
  void dispose() {
    _scroll.dispose();
    search.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    if (isLoading || !hasMore) return;

    setState(() => isLoading = true);

    try {
      List<Product> newProducts = await ProductAPI.fetchProducts(
        context,
        page: page,
        limit: 10,
        search: search.text,
      );

      if (newProducts.isEmpty) {
        setState(() => hasMore = false);
      } else {
        Set<String> existingIds = products.map((p) => p.id).toSet();

        List<Product> uniqueProducts =
            newProducts.where((p) => !existingIds.contains(p.id)).toList();

        if (uniqueProducts.isNotEmpty) {
          page++; // Increase page only if there's new data
          products.addAll(uniqueProducts);
        } else {
          hasMore = false;
        }
      }
    } catch (e) {
      debugPrint("Error fetching products: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> _refreshProducts() async {
    if (isLoading) return;
    isRefresh = true;
    setState(() {
      isLoading = true;
      page = 1; // 🔄 Reset page to 1
      hasMore = true;
      products.clear(); // 🧹 Clear old data
    });

    _scroll.removeListener(_onScroll);

    try {
      List<Product> latestProducts = await ProductAPI.fetchProducts(
        context,
        page: page,
        limit: 10,
        search: search.text,
      );

      if (latestProducts.isNotEmpty) {
        page++;
        products.addAll(latestProducts);
      } else {
        hasMore = false;
      }

      await Future.delayed(Duration(milliseconds: 200)); // 🚀 Ensure UI updates
      _scroll.jumpTo(1);
    } catch (e) {
      debugPrint("Error fetching newest transactions: $e");
    }

    _scroll.addListener(_onScroll);
    setState(() => isLoading = false);
    isRefresh = false;
  }

  Timer? _debounce;

  void _onScroll() {
    if (isLoading || isRefresh || (_debounce?.isActive ?? false)) {
      return;
    }
    _debounce = Timer(Duration(milliseconds: 300), () {
      if (isLoading) return; // Avoid duplicate API calls

      double offset = _scroll.position.pixels;
      double maxScroll = _scroll.position.maxScrollExtent;

      if (offset >= maxScroll - 100 && hasMore) {
        _fetchProducts();
      }

      if (offset <= -40) {
        _refreshProducts();
      }
    });
  }

  void _onSearchChanged() {
    _scroll.jumpTo(0);
    if (isLoading) return;

    _refreshProducts();
  }

  @override
  Widget build(BuildContext context) {
    final actions = context.read<PermissionCubit>().state.actions(
      'inventory/product',
    );
    return Scaffold(
      body: CustomScrollView(
        scrollBehavior: const CupertinoScrollBehavior(),
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scroll,
        slivers: [
          SliverAppBar(
            pinned: true, // Ensures the app bar remains visible when scrolling
            floating: false, // No snap effect
            elevation: 0,
            title: Text('Products', style: AppTextStyles.headingWhite),
            leading: IconButton(
              icon: const Icon(CupertinoIcons.arrow_left, color: Colors.white),
              onPressed: () {
                _scroll.jumpTo(0);
                context.pop();
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Column(
                spacing: 0,
                children: [
                  SearchBarWidget(
                    controller: search,
                    onChanged: _onSearchChanged,
                  ),
                  ...products.map(
                    (product) => InkWell(
                      onTap: () {
                        if (actions.contains('detail')) {
                          GoRouter.of(
                            context,
                          ).push('/product-detail', extra: product);
                        }
                      },
                      child: Card(
                        color: Colors.white,
                        elevation: 1,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 4,
                            children: [
                              Text(
                                '${product.code} | ${product.name}',
                                style: AppTextStyles.headingBlue,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Divider(),
                              TextCardDetail(
                                label: 'Category',
                                value:
                                    '${product.type.category?.code ?? ''} | ${product.type.category?.name ?? ''}',
                                type: 'text',
                              ),
                              TextCardDetail(
                                label: 'Jumlah dalam stock',
                                value:
                                    '${product.productCodes.where((pc) => pc.status == 0).length}',
                                type: 'text',
                              ),
                              TextCardDetail(
                                label: 'Jumlah terjual',
                                value:
                                    '${product.productCodes.where((pc) => pc.status == 1).length}',
                                type: 'text',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // No Data Indicator
          if (products.isEmpty && !isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 52),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        CupertinoIcons.xmark_circle_fill,
                        size: 70,
                        color: AppColors.error,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Tidak ada Produk ditemukan",
                        style: AppTextStyles.headingBlue,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Loading Indicator
          if (isLoading)
            SliverToBoxAdapter(
              child: const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 52),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
