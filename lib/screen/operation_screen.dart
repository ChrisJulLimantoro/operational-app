import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:operational_app/api/operation.dart';
import 'package:operational_app/model/operation.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/search_bar.dart';
import 'package:operational_app/widget/text_card_detail.dart';

class OperationScreen extends StatefulWidget {
  const OperationScreen({super.key});

  @override
  State<OperationScreen> createState() => _OperationScreenState();
}

class _OperationScreenState extends State<OperationScreen> {
  final _scroll = ScrollController();
  final search = TextEditingController();
  List<Operation> operations = List.empty(growable: true);
  int page = 1;
  bool isLoading = false;
  bool isRefresh = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _fetchOperations();
  }

  @override
  void dispose() {
    _scroll.dispose();
    search.dispose();
    super.dispose();
  }

  Future<void> _fetchOperations() async {
    if (isLoading || !hasMore) return;

    setState(() => isLoading = true);

    try {
      List<Operation> newOperations = await OperationAPI.fetchOperations(
        context,
        page: page,
        limit: 10,
        search: search.text,
      );

      if (newOperations.isEmpty) {
        setState(() => hasMore = false);
      } else {
        Set<String> existingIds = operations.map((p) => p.id).toSet();

        List<Operation> uniqueOperations =
            newOperations.where((p) => !existingIds.contains(p.id)).toList();

        if (uniqueOperations.isNotEmpty) {
          page++; // Increase page only if there's new data
          operations.addAll(uniqueOperations);
        } else {
          hasMore = false;
        }
      }
    } catch (e) {
      debugPrint("Error fetching operations: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> _refreshOperations() async {
    if (isLoading) return;
    isRefresh = true;
    setState(() {
      isLoading = true;
      page = 1; // 🔄 Reset page to 1
      hasMore = true;
      operations.clear(); // 🧹 Clear old data
    });

    _scroll.removeListener(_onScroll);

    try {
      List<Operation> latestOperations = await OperationAPI.fetchOperations(
        context,
        page: page,
        limit: 10,
        search: search.text,
      );

      if (latestOperations.isNotEmpty) {
        page++;
        operations.addAll(latestOperations);
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
        _fetchOperations();
      }

      if (offset <= -40) {
        _refreshOperations();
      }
    });
  }

  void _onSearchChanged() {
    _scroll.jumpTo(0);
    if (isLoading) return;

    _refreshOperations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        scrollBehavior: CupertinoScrollBehavior(),
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scroll,
        slivers: [
          SliverAppBar(
            pinned: true, // Ensures the app bar remains visible when scrolling
            floating: false, // No snap effect
            elevation: 0,
            title: Text('Operations', style: AppTextStyles.headingWhite),
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
                  ...operations.map(
                    (op) => Card(
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
                              '${op.code} | ${op.name}',
                              style: AppTextStyles.headingBlue,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Divider(),
                            TextCardDetail(
                              label: 'Satuan',
                              value: op.uom,
                              type: 'text',
                            ),
                            TextCardDetail(
                              label: 'Harga per satuan',
                              value: op.price,
                              type: 'currency',
                            ),
                            TextCardDetail(
                              label: 'Deskripsi',
                              value: op.description ?? "-",
                              type: 'text',
                              isLong: true,
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
          // No Data Indicator
          if (operations.isEmpty && !isLoading)
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
                        "Tidak ada Operasi ditemukan",
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
