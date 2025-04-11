import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:operational_app/api/transaction.dart';
import 'package:operational_app/bloc/permission_bloc.dart';
import 'package:operational_app/helper/format_date.dart';
import 'package:operational_app/model/transaction.dart';
import 'package:operational_app/notifier/sales_notifier.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/search_bar.dart';
import 'package:operational_app/widget/transaction_card.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class TransactionScreen extends StatefulWidget {
  final int type;
  const TransactionScreen({super.key, required this.type});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final _scroll = ScrollController();
  final search = TextEditingController();
  List<Transaction> transactions = List.empty(growable: true);
  Map<DateTime, List<Transaction>> groupedTransactions = {}; // Grouped by date
  int page = 1;
  bool isLoading = false;
  bool isRefresh = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _fetchTransactions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final notifier = Provider.of<SalesNotifier>(context);
    if (notifier.shouldRefresh) {
      _refreshTransactions();
      notifier.resetRefresh();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    search.dispose();
    super.dispose();
  }

  Future<void> _fetchTransactions() async {
    if (isLoading || !hasMore) return;

    setState(() => isLoading = true);

    try {
      List<Transaction> newTransactions =
          await TransactionAPI.fetchTransactionsFromAPI(
            context,
            widget.type,
            page: page,
            limit: 10,
            search: search.text,
          );

      debugPrint('Fetched ${newTransactions.length} transactions');

      if (newTransactions.isEmpty) {
        setState(() => hasMore = false);
      } else {
        Set<String> existingIds = transactions.map((trans) => trans.id).toSet();

        List<Transaction> uniqueTransactions =
            newTransactions
                .where((trans) => !existingIds.contains(trans.id))
                .toList();

        if (uniqueTransactions.isNotEmpty) {
          page++; // Increase page only if there's new data
          transactions.addAll(uniqueTransactions);
          _groupTransactions();
        } else {
          hasMore = false;
        }
      }
    } catch (e) {
      debugPrint("Error fetching transactions: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> _refreshTransactions() async {
    if (isLoading) return;
    isRefresh = true;
    setState(() {
      isLoading = true;
      page = 1; // 🔄 Reset page to 1
      hasMore = true;
      transactions.clear(); // 🧹 Clear old data
      groupedTransactions.clear();
    });

    _scroll.removeListener(_onScroll);

    try {
      List<Transaction> latestTransactions =
          await TransactionAPI.fetchTransactionsFromAPI(
            context,
            widget.type,
            page: page,
            limit: 10,
            search: search.text,
          );

      if (latestTransactions.isNotEmpty) {
        transactions.addAll(latestTransactions);
        _groupTransactions();
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

  void _groupTransactions() {
    groupedTransactions.clear();
    for (var trans in transactions) {
      groupedTransactions.putIfAbsent(trans.date, () => []).add(trans);
    }
    debugPrint('Grouped transactions: ');
    for (var entry in groupedTransactions.entries) {
      debugPrint('${entry.key}: ${entry.value.length} transactions');
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
        _fetchTransactions();
      }

      if (offset <= -40) {
        _refreshTransactions();
      }
    });
  }

  void _onSearchChanged() {
    _scroll.jumpTo(0);
    if (isLoading) return;

    _refreshTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final feature =
        widget.type == 1
            ? 'transaction/sales'
            : widget.type == 2
            ? 'transaction/purchase'
            : 'transaction/trade';
    final permissionAdd = context.read<PermissionCubit>().state.hasPermission(
      feature,
      'add',
    );

    final actions = context.read<PermissionCubit>().state.actions(feature);
    return Scaffold(
      body: CustomScrollView(
        scrollBehavior: CupertinoScrollBehavior(),
        controller: _scroll,
        slivers: [
          SliverAppBar(
            pinned: true, // Ensures the app bar remains visible when scrolling
            floating: false, // No snap effect
            elevation: 0,
            title: Text(
              widget.type == 1
                  ? 'Penjualan'
                  : widget.type == 2
                  ? 'Pembelian'
                  : 'Tukar Tambah',
              style: AppTextStyles.headingWhite,
            ),
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
                  ...groupedTransactions.entries.map(
                    (entry) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12,
                      children: [
                        Text(
                          DateHelper.formatDate(entry.key),
                          style: AppTextStyles.subheadingBlue,
                        ), // Date header
                        ...entry.value.map(
                          (trans) =>
                              TransactionCard(trans: trans, actions: actions),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // No Data Indicator
          if (transactions.isEmpty && !isLoading)
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
                        "Tidak ada transaksi ditemukan",
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
          // Check permission level for adding transactions
          if (permissionAdd) {
            context.push('/transaction/add', extra: widget.type);
          }
        },
        backgroundColor: permissionAdd ? AppColors.pinkPrimary : Colors.grey,
        child: const Icon(CupertinoIcons.add, color: Colors.white),
      ),
    );
  }
}
