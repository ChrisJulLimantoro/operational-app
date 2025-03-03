import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:operational_app/api/company.dart';
import 'package:operational_app/model/company.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/text_card_detail.dart';

class CompanyScreen extends StatefulWidget {
  const CompanyScreen({super.key});

  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  final _scroll = ScrollController();
  List<Company> companies = List.empty(growable: true);
  bool isLoading = false;
  bool isRefresh = false;

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
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      List<Company> newCompanies = await CompanyAPI.fetchCompanies(context);

      debugPrint('Fetched ${newCompanies.length} companies');

      Set<String> existingIds = companies.map((company) => company.id).toSet();

      List<Company> uniqueCompanies =
          newCompanies
              .where((company) => !existingIds.contains(company.id))
              .toList();

      if (uniqueCompanies.isNotEmpty) {
        companies.addAll(uniqueCompanies);
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
      isLoading = true;
      companies.clear();
    });

    _scroll.removeListener(_onScroll);

    try {
      List<Company> latestCompanies = await CompanyAPI.fetchCompanies(context);

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
        _refreshCompanies();
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
                  // SearchBarWidget(controller: search),
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
