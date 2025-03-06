import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:operational_app/api/category.dart';
import 'package:operational_app/model/category.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/text_card_detail.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _scroll = ScrollController();
  List<Category> companies = List.empty(growable: true);
  bool isLoading = false;
  bool isRefresh = false;
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    super.dispose();
    _scroll.dispose();
  }

  Future<void> _fetchCategories() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      List<Category> newCompanies = await CategoryAPI.fetchCategories(context);

      debugPrint('Fetched ${newCompanies.length} companies');

      Set<String> existingIds =
          companies.map((category) => category.id).toSet();

      List<Category> uniqueCompanies =
          newCompanies
              .where((category) => !existingIds.contains(category.id))
              .toList();

      if (uniqueCompanies.isNotEmpty) {
        companies.addAll(uniqueCompanies);
      }
    } catch (e) {
      debugPrint("Error fetching companies: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> _refreshCategories() async {
    if (isLoading) return;
    isRefresh = true;
    setState(() {
      isLoading = true;
      companies.clear();
    });

    _scroll.removeListener(_onScroll);

    try {
      List<Category> latestCompanies = await CategoryAPI.fetchCategories(
        context,
      );

      if (latestCompanies.isNotEmpty) {
        companies.addAll(latestCompanies);
      }

      await Future.delayed(Duration(milliseconds: 200)); // 🚀 Ensure UI updates
      _scroll.jumpTo(1);
    } catch (e) {
      debugPrint("Error fetching newest companies: $e");
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

      if (offset <= -40) {
        _refreshCategories();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true, // Ensures the app bar remains visible when scrolling
            floating: false, // No snap effect
            elevation: 0,
            title: Text('Kategori', style: AppTextStyles.headingWhite),
            leading: IconButton(
              icon: Icon(CupertinoIcons.arrow_left, color: Colors.white),
              onPressed: () {
                context.pop();
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 0,
                children: [
                  // SearchBarWidget(controller: search),
                  // Companies
                  ...companies.map(
                    (category) => InkWell(
                      onTap: () {
                        context.push('/category-detail', extra: category);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                        child: Card(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 16.0,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 6,
                              children: [
                                Text(
                                  "${category.code} | ${category.name}",
                                  style: AppTextStyles.headingBlue,
                                ),
                                Divider(),
                                TextCardDetail(
                                  label: 'Karat',
                                  value: category.purity,
                                  type: "text",
                                ),
                                TextCardDetail(
                                  label: 'Jenis Logam',
                                  value: category.metalType.name,
                                  type: "text",
                                ),
                                TextCardDetail(
                                  label: 'Sub Categories',
                                  value: '${category.types?.length ?? 0}',
                                  type: "text",
                                ),
                                TextCardDetail(
                                  label: 'Dibuat pada',
                                  value: category.createdAt,
                                  type: "date",
                                ),
                                TextCardDetail(
                                  label: 'Deskripsi',
                                  value: category.description,
                                  type: "text",
                                  isLong: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
