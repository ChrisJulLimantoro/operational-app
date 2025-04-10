import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:operational_app/api/stock_out.dart';
import 'package:operational_app/helper/format_date.dart';
import 'package:operational_app/model/stock_out.dart';
import 'package:operational_app/notifier/stock_out_notifier.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/search_bar.dart';
import 'package:operational_app/widget/text_card_detail.dart';
import 'package:provider/provider.dart';

class StockOutScreen extends StatefulWidget {
  const StockOutScreen({super.key});

  @override
  State<StockOutScreen> createState() => _StockOutScreenState();
}

class _StockOutScreenState extends State<StockOutScreen> {
  final _scroll = ScrollController();
  final search = TextEditingController();
  List<StockOut> stockOuts = List.empty(growable: true);
  Map<DateTime, List<StockOut>> groupedStockOuts = {}; // Grouped by date
  int page = 1;
  bool isLoading = false;
  bool isRefresh = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _fetchStockOuts();
  }

  @override
  void dispose() {
    _scroll.dispose();
    search.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final notifier = Provider.of<StockOutNotifier>(context);
    if (notifier.shouldRefresh) {
      _refreshStockOuts();
      notifier.resetRefresh();
    }
  }

  Future<void> _fetchStockOuts() async {
    if (isLoading || !hasMore) return;

    setState(() => isLoading = true);

    try {
      List<StockOut> newStockOuts = await StockOutAPI.fetchStockOuts(
        context,
        page: page,
        limit: 10,
        search: search.text,
      );
      debugPrint("New Stock Opnames: $newStockOuts");

      if (newStockOuts.isEmpty) {
        setState(() => hasMore = false);
      } else {
        Set<String> existingIds = stockOuts.map((p) => p.id).toSet();

        List<StockOut> uniqueStockOuts =
            newStockOuts.where((p) => !existingIds.contains(p.id)).toList();

        if (uniqueStockOuts.isNotEmpty) {
          page++; // Increase page only if there's new data
          stockOuts.addAll(uniqueStockOuts);
          _groupStockOpnames();
        } else {
          hasMore = false;
        }
      }
    } catch (e) {
      debugPrint("Error fetching stockOuts: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> _refreshStockOuts() async {
    if (isLoading) return;
    isRefresh = true;
    setState(() {
      isLoading = true;
      page = 1; // 🔄 Reset page to 1
      hasMore = true;
      stockOuts.clear(); // 🧹 Clear old data
      groupedStockOuts.clear();
    });

    _scroll.removeListener(_onScroll);

    try {
      List<StockOut> latestStockOuts = await StockOutAPI.fetchStockOuts(
        context,
        page: page,
        limit: 10,
        search: search.text,
      );

      if (latestStockOuts.isNotEmpty) {
        page++;
        stockOuts.addAll(latestStockOuts);
        _groupStockOpnames();
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

  void _groupStockOpnames() {
    groupedStockOuts.clear();
    for (var so in stockOuts) {
      groupedStockOuts.putIfAbsent(so.takenOutAt, () => []).add(so);
    }
  }

  Future<void> _unstockOut(String id) async {
    bool success = await StockOutAPI.unstockOut(context, id);
    if (success) {
      setState(() {
        stockOuts.removeWhere((so) => so.id == id);
        _groupStockOpnames();
      });
    }
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
        _fetchStockOuts();
      }

      if (offset <= -40) {
        _refreshStockOuts();
      }
    });
  }

  void _onSearchChanged() {
    _scroll.jumpTo(0);
    if (isLoading) return;

    _refreshStockOuts();
  }

  @override
  Widget build(BuildContext context) {
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
            title: Text('Stock Out', style: AppTextStyles.headingWhite),
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
              padding: EdgeInsets.only(left: 20, top: 4, bottom: 24, right: 20),
              child: Column(
                spacing: 0,
                children: [
                  SearchBarWidget(
                    controller: search,
                    onChanged: _onSearchChanged,
                  ),
                  ...groupedStockOuts.entries.map(
                    (so) => Column(
                      spacing: 12,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            DateHelper.formatDate(so.key),
                            style: AppTextStyles.subheadingBlue,
                          ),
                        ), //
                        ...so.value.map(
                          (stockOut) => Card(
                            color: Colors.white,
                            elevation: 1,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 8,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        stockOut.barcode,
                                        style: AppTextStyles.subheadingBlue,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          // Delete Stock Out / Cancel
                                          _unstockOut(stockOut.id);
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8.0,
                                          ),
                                          child: Container(
                                            color: AppColors.error,
                                            padding: EdgeInsets.all(8.0),
                                            child: Icon(
                                              CupertinoIcons.trash,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(),
                                  TextCardDetail(
                                    label: 'Nama',
                                    value: stockOut.name.split(' - ')[1],
                                    type: 'text',
                                  ),
                                  TextCardDetail(
                                    label: 'SubKategori',
                                    value: stockOut.type,
                                    type: 'text',
                                  ),
                                  TextCardDetail(
                                    label: 'Harga',
                                    value: stockOut.price,
                                    type: 'currency',
                                  ),
                                  TextCardDetail(
                                    label: 'Alasan',
                                    value:
                                        stockOut.takenOutReason == 1
                                            ? 'Sedang diperbaiki'
                                            : stockOut.takenOutReason == 2
                                            ? 'Hilang'
                                            : 'Lainnya',
                                    type: 'text',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // No Data Indicator
          if (stockOuts.isEmpty && !isLoading)
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
                        "Tidak ada stock out ditemukan",
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/stock-out/add');
        },
        backgroundColor: AppColors.pinkPrimary,
        child: const Icon(CupertinoIcons.add, color: Colors.white),
      ),
    );
  }
}
