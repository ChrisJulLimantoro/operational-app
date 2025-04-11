import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:operational_app/api/category.dart';
import 'package:operational_app/bloc/permission_bloc.dart';
import 'package:operational_app/model/category.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/search_bar.dart';
import 'package:operational_app/widget/text_card_detail.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final search = TextEditingController();
  final _scroll = ScrollController();
  List<Category> categories = List.empty(growable: true);
  int page = 1;
  bool isLoading = false;
  bool isRefresh = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    super.dispose();
    search.dispose();
    _scroll.dispose();
  }

  Future<void> _fetchCategories() async {
    if (isLoading || !hasMore) return;

    setState(() => isLoading = true);

    try {
      List<Category> newCategories = await CategoryAPI.fetchCategories(
        context,
        page: page,
        limit: 10,
        search: search.text,
      );

      debugPrint('Fetched ${newCategories.length} categories');
      if (newCategories.isEmpty) {
        setState(() => hasMore = false);
      } else {
        Set<String> existingIds =
            categories.map((category) => category.id).toSet();

        List<Category> uniqueCategories =
            newCategories
                .where((category) => !existingIds.contains(category.id))
                .toList();

        if (uniqueCategories.isNotEmpty) {
          page++;
          await Future.delayed(
            Duration(milliseconds: 400),
          ); // 🚀 Ensure UI updates
          categories.addAll(uniqueCategories);
        } else {
          setState(() => hasMore = false);
        }
      }
    } catch (e) {
      debugPrint("Error fetching categories: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> _refreshCategories() async {
    if (isLoading) return;
    isRefresh = true;
    setState(() {
      isLoading = true;
      categories.clear();
      page = 1;
      hasMore = true;
    });

    _scroll.removeListener(_onScroll);

    try {
      List<Category> latestCategories = await CategoryAPI.fetchCategories(
        context,
        page: page,
        limit: 10,
        search: search.text,
      );

      if (latestCategories.isNotEmpty) {
        page++;
        categories.addAll(latestCategories);
      } else {
        setState(() => hasMore = false);
      }

      await Future.delayed(Duration(milliseconds: 400)); // 🚀 Ensure UI updates
      _scroll.jumpTo(1);
    } catch (e) {
      debugPrint("Error fetching newest categories: $e");
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
        _fetchCategories();
      }

      if (offset <= -40) {
        _refreshCategories();
      }
    });
  }

  void _onSearchChanged() {
    _scroll.jumpTo(0);
    if (isLoading) return;

    _refreshCategories();
  }

  @override
  Widget build(BuildContext context) {
    final actions = context.read<PermissionCubit>().state.actions(
      'master/category',
    );
    return Scaffold(
      body: CustomScrollView(
        controller: _scroll,
        physics: const BouncingScrollPhysics(),
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
                  SearchBarWidget(
                    controller: search,
                    onChanged: _onSearchChanged,
                  ),
                  // Categories
                  ...categories.map(
                    (category) => InkWell(
                      onTap: () {
                        if (actions.contains('detail')) {
                          context.push('/category-detail', extra: category);
                        }
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
          // No Data Indicator
          if (categories.isEmpty && !isLoading)
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
                        "Tidak ada kategori ditemukan",
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
