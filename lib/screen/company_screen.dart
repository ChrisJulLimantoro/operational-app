import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:operational_app/api/company.dart';
import 'package:operational_app/model/company.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/search_bar.dart';
import 'package:operational_app/widget/text_card_detail.dart';

class CompanyScreen extends StatefulWidget {
  const CompanyScreen({super.key});

  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  final _scroll = ScrollController();
  final search = TextEditingController();
  List<Company> companies = List.empty(growable: true);
  int page = 1;
  bool isLoading = false;
  bool isRefresh = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchCompanies();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    super.dispose();
    _scroll.dispose();
  }

  Future<void> _fetchCompanies() async {
    if (isLoading || !hasMore) return;
    setState(() => isLoading = true);

    try {
      List<Company> newCompanies = await CompanyAPI.fetchCompanies(
        context,
        page: page,
        limit: 10,
        search: search.text,
      );

      debugPrint('Fetched ${newCompanies.length} companies');

      if (newCompanies.isEmpty) {
        setState(() => hasMore = false);
      } else {
        Set<String> existingIds =
            companies.map((company) => company.id).toSet();

        List<Company> uniqueCompanies =
            newCompanies
                .where((company) => !existingIds.contains(company.id))
                .toList();

        if (uniqueCompanies.isNotEmpty) {
          page++;
          companies.addAll(uniqueCompanies);
        } else {
          hasMore = false;
        }
      }
    } catch (e) {
      debugPrint("Error fetching companies: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> _refreshCompanies() async {
    if (isLoading) return;
    isRefresh = true;
    setState(() {
      // Reset page and clear companies list
      page = 1;
      hasMore = true;
      isLoading = true;
      companies.clear();
    });

    _scroll.removeListener(_onScroll);

    try {
      List<Company> latestCompanies = await CompanyAPI.fetchCompanies(
        context,
        page: page,
        limit: 10,
        search: search.text,
      );

      if (latestCompanies.isNotEmpty) {
        hasMore = true;
        page++;
        companies.addAll(latestCompanies);
      } else {
        hasMore = false;
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
      double maxScroll = _scroll.position.maxScrollExtent;

      if (offset >= maxScroll - 100 && hasMore) {
        _fetchCompanies();
      }

      if (offset <= -40) {
        _refreshCompanies();
      }
    });
  }

  void _onSearchChanged() {
    _scroll.jumpTo(0);
    if (isLoading) return;

    _refreshCompanies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        scrollBehavior: CupertinoScrollBehavior(),
        controller: _scroll,
        slivers: [
          SliverAppBar(
            pinned: true, // Ensures the app bar remains visible when scrolling
            floating: false, // No snap effect
            elevation: 0,
            title: Text('Usaha', style: AppTextStyles.headingWhite),
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
                  // Companies
                  ...companies.map(
                    (company) => Padding(
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
                                "${company.code} | ${company.name}",
                                style: AppTextStyles.headingBlue,
                              ),
                              Divider(),
                              TextCardDetail(
                                label: 'Dibuat pada',
                                value: company.createdAt,
                                type: "date",
                              ),
                              TextCardDetail(
                                label: 'Deskripsi',
                                value: company.description,
                                type: "text",
                                isLong: true,
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
          if (companies.isEmpty && !isLoading)
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
                        "Tidak ada usaha ditemukan",
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
