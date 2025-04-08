import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:operational_app/api/store.dart';
import 'package:operational_app/model/store.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/search_bar.dart';
import 'package:operational_app/widget/text_card_detail.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final search = TextEditingController();
  final _scroll = ScrollController();
  List<Store> stores = List.empty(growable: true);
  int page = 1;
  bool isLoading = false;
  bool isRefresh = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchStores();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    super.dispose();
    _scroll.dispose();
  }

  Future<void> _fetchStores() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      List<Store> newStores = await StoreAPI.fetchStores(
        context,
        page: page,
        limit: 10,
        search: search.text,
      );

      debugPrint('Fetched ${newStores.length} companies');

      if (newStores.isEmpty) {
        setState(() => hasMore = false);
      } else {
        Set<String> existingIds = stores.map((store) => store.id).toSet();

        List<Store> uniqueStores =
            newStores
                .where((company) => !existingIds.contains(company.id))
                .toList();

        if (uniqueStores.isNotEmpty) {
          page++;
          await Future.delayed(
            Duration(milliseconds: 400),
          ); // 🚀 Ensure UI updates
          stores.addAll(uniqueStores);
        } else {
          setState(() => hasMore = false);
        }
      }
    } catch (e) {
      debugPrint("Error fetching stores: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> _refreshStores() async {
    if (isLoading) return;
    isRefresh = true;
    setState(() {
      isLoading = true;
      stores.clear();
      page = 1;
      hasMore = true;
    });

    _scroll.removeListener(_onScroll);

    try {
      List<Store> latestStores = await StoreAPI.fetchStores(
        context,
        page: page,
        limit: 10,
        search: search.text,
      );

      if (latestStores.isNotEmpty) {
        page++;
        stores.addAll(latestStores);
      } else {
        setState(() => hasMore = false);
      }

      await Future.delayed(Duration(milliseconds: 400)); // 🚀 Ensure UI updates
      _scroll.jumpTo(1);
    } catch (e) {
      debugPrint("Error fetching newest stores: $e");
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
        _refreshStores();
      }
    });
  }

  void _onSearchChanged() {
    _scroll.jumpTo(0);
    if (isLoading) return;

    _refreshStores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scroll,
        physics: const BouncingScrollPhysics(),
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
                  ), // Companies
                  ...stores.map(
                    (store) => InkWell(
                      onTap:
                          () => {context.push('/store-detail', extra: store)},
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
                                  "${store.code} | ${store.name}",
                                  style: AppTextStyles.headingBlue,
                                ),
                                Divider(),
                                TextCardDetail(
                                  label: "NPWP",
                                  value: store.npwp,
                                  type: "text",
                                ),
                                TextCardDetail(
                                  label: "Usaha",
                                  value:
                                      "${store.company?.code} | ${store.company?.name}",
                                  type: "text",
                                ),
                                TextCardDetail(
                                  label: 'Dibuat pada',
                                  value: store.openDate,
                                  type: "date",
                                ),
                                TextCardDetail(
                                  label: 'Alamat',
                                  value: store.address,
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
          if (stores.isEmpty && !isLoading)
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
                        "Tidak ada cabang ditemukan",
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
