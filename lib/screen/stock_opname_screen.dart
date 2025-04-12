import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:operational_app/api/category.dart';
import 'package:operational_app/api/stock_opname.dart';
import 'package:operational_app/bloc/auth_bloc.dart';
import 'package:operational_app/bloc/permission_bloc.dart';
import 'package:operational_app/helper/format_date.dart';
import 'package:operational_app/model/category.dart';
import 'package:operational_app/model/stock_opname.dart';
import 'package:operational_app/notifier/stock_opname_notifier.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/stock_opname_card.dart';
import 'package:provider/provider.dart';

class StockOpnameScreen extends StatefulWidget {
  const StockOpnameScreen({super.key});

  @override
  State<StockOpnameScreen> createState() => _StockOpnameScreenState();
}

class _StockOpnameScreenState extends State<StockOpnameScreen> {
  final _scroll = ScrollController();
  final search = TextEditingController();
  List<StockOpname> stockOpnames = List.empty(growable: true);
  Map<DateTime, List<StockOpname>> groupedStockOpnames = {}; // Grouped by date
  List<Category> categories = List.empty(growable: true);
  int page = 1;
  bool isLoading = false;
  bool isRefresh = false;
  bool hasMore = true;
  final dateController = TextEditingController();
  Category? selectedCategory;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _fetchStockOpnames();
    _fetchCategories();
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
    final notifier = Provider.of<StockOpnameNotifier>(context);
    if (notifier.shouldRefresh) {
      _refreshStockOpnames();
      notifier.resetRefresh();
    }
  }

  Future<void> _fetchStockOpnames() async {
    if (isLoading || !hasMore) return;

    setState(() => isLoading = true);

    try {
      List<StockOpname> newStockOpnames =
          await StockOpnameAPI.fetchStockOpnames(context, page, 10);
      debugPrint("New Stock Opnames: $newStockOpnames");

      if (newStockOpnames.isEmpty) {
        setState(() => hasMore = false);
      } else {
        Set<String> existingIds = stockOpnames.map((p) => p.id).toSet();

        List<StockOpname> uniqueStockOpnames =
            newStockOpnames.where((p) => !existingIds.contains(p.id)).toList();

        if (uniqueStockOpnames.isNotEmpty) {
          page++; // Increase page only if there's new data
          stockOpnames.addAll(uniqueStockOpnames);
          _groupStockOpnames();
        } else {
          hasMore = false;
        }
      }
    } catch (e) {
      debugPrint("Error fetching stockOpnames: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> _refreshStockOpnames() async {
    if (isLoading) return;
    isRefresh = true;
    setState(() {
      isLoading = true;
      page = 1; // 🔄 Reset page to 1
      hasMore = true;
      stockOpnames.clear(); // 🧹 Clear old data
      groupedStockOpnames.clear();
    });

    _scroll.removeListener(_onScroll);

    try {
      List<StockOpname> latestStockOpnames =
          await StockOpnameAPI.fetchStockOpnames(context, page, 10);

      if (latestStockOpnames.isNotEmpty) {
        stockOpnames.addAll(latestStockOpnames);
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
    groupedStockOpnames.clear();
    for (var so in stockOpnames) {
      groupedStockOpnames.putIfAbsent(so.date!, () => []).add(so);
    }
  }

  Future<void> _fetchCategories() async {
    final authCubit = context.read<AuthCubit>();
    List<Category> newCategories = await CategoryAPI.fetchCategories(
      context,
      storeId: authCubit.state.storeId,
    );
    setState(() => categories = newCategories);
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
        _fetchStockOpnames();
      }

      if (offset <= -40) {
        _refreshStockOpnames();
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      dateController.text = "${picked.toLocal()}".split(' ')[0]; // Format date
    }
  }

  Future<void> _createStockOpname(BuildContext context) async {
    if (selectedCategory != null && dateController.text.isNotEmpty) {
      try {
        final so = await StockOpnameAPI.createStockOpname(
          context,
          dateController.text,
          selectedCategory!.id,
        );
        if (!context.mounted) {
          return;
        }

        if (so == null) {
          return;
        }

        GoRouter.of(context).push('/stock-opname-detail', extra: so);
      } catch (e) {
        debugPrint("Error creating stock opname: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final actions = context.read<PermissionCubit>().state.actions(
      'inventory/stock-opname',
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
            title: Text('Stock Opname', style: AppTextStyles.headingWhite),
            leading: IconButton(
              icon: const Icon(CupertinoIcons.arrow_left, color: Colors.white),
              onPressed: () {
                _scroll.jumpTo(0);
                context.pop();
              },
            ),
          ),
          groupedStockOpnames.isNotEmpty || isLoading
              ? SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    spacing: 12,
                    children: [
                      ...groupedStockOpnames.entries.map(
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
                              (stockOpname) =>
                                  StockOpnameCard(stockOpname: stockOpname),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : SliverFillRemaining(
                child: Center(child: Text('No Stock Opname for this Store')),
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
          if (!actions.contains('add')) {
            return;
          }
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                    left: 24,
                    right: 24,
                    top: 28,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add New Stock Opname',
                        style: AppTextStyles.headingBlue,
                      ),
                      SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: dateController,
                            readOnly: true, // Prevent manual input
                            decoration: InputDecoration(
                              icon: Icon(Icons.calendar_today),
                              labelText: "Select Date",
                            ),
                            onTap: () => _selectDate(context),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Select Category",
                        style: AppTextStyles.subheadingBlue,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButton<Category?>(
                            key: ValueKey(selectedCategory),
                            value:
                                categories.contains(selectedCategory)
                                    ? selectedCategory
                                    : null,
                            hint: Text("Select a category"),
                            isExpanded:
                                true, // Makes the dropdown take full width
                            items:
                                categories.map((Category item) {
                                  return DropdownMenuItem<Category>(
                                    value: item,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(item.name),
                                        if (selectedCategory?.id == item.id)
                                          Icon(
                                            Icons.check,
                                            color: AppColors.bluePrimary,
                                          ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                            onChanged: (Category? newValue) {
                              setState(() {
                                selectedCategory = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.pinkPrimary,
                                borderRadius: BorderRadius.circular(
                                  8,
                                ), // Optional for rounded corners
                              ),
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white, // Text color
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text('Cancel'),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.bluePrimary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  // Handle form submission
                                  Navigator.pop(context);
                                  _createStockOpname(context);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text('Save'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              );
            },
          );
        },
        backgroundColor:
            actions.contains('add') ? AppColors.pinkPrimary : Colors.grey,
        child: const Icon(CupertinoIcons.add, color: Colors.white),
      ),
    );
  }
}
