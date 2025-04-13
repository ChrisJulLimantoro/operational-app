import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:operational_app/api/accounts.dart';
import 'package:operational_app/api/stock_out.dart';
import 'package:operational_app/bloc/permission_bloc.dart';
import 'package:operational_app/helper/format_date.dart';
import 'package:operational_app/helper/notification.dart';
import 'package:operational_app/model/account.dart';
import 'package:operational_app/model/stock_out.dart';
import 'package:operational_app/notifier/stock_out_notifier.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/modal_sheet.dart';
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

  Map<String, dynamic> formRepaired = {
    'weight': 0,
    'expense': 0,
    'account_id': null,
    'id': null,
  };

  Future<void> _approveRepair(stockOutID) async {
    await _fetchAccounts();
    formRepaired['id'] = stockOutID;
    await modalSheet(
      context: context,
      primaryColor: AppColors.pinkPrimary,
      icon: Icons.error_outline,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text("Selesai perbaikan ?", style: AppTextStyles.labelPink),
        ],
      ),
      message: "Apakah emas telah selesai diperbaiki dan ingin dikembalikan ke barang siap jual ?",
      inputs: [
        // Weight
        TextFormField(
          initialValue: formRepaired['weight'].toString(),
          decoration: const InputDecoration(
            labelText: 'Berat terbaru',
            hintText: 'Berat terbaru',
            prefixIcon: Icon(Icons.scale),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            formRepaired['weight'] = double.tryParse(value) ?? 0;
          },
        ),
        // Expense
        TextFormField(
          initialValue: formRepaired['expense'].toString(),
          decoration: const InputDecoration(
            labelText: 'Biaya Perbaikan',
            hintText: 'Biaya Perbaikan',
            prefixIcon: Icon(Icons.money),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            formRepaired['expense'] = double.tryParse(value) ?? 0;
          },
        ),
        // Dropdown
        DropdownButtonFormField(
          value: formRepaired['account_id'],
          decoration: const InputDecoration(
            labelText: 'Akun',
            hintText: 'Pilih Akun',
            prefixIcon: Icon(Icons.account_balance),
          ),
          isExpanded: true,
          items: accounts
                  .map(
                    (item) => DropdownMenuItem(
                      value: item.id,
                      child: Text('${item.code} - ${item.name}', overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            formRepaired['account_id'] = value;
          },
        ),
      ],
      actions: [
        // Ya
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pinkPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            onPressed: () {
              _submitRepaired();
            },
            child: Text(
              'Ya',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        // Batal
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pinkSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitRepaired() async {
    if (formRepaired['weight'] == 0) {
        NotificationHelper.showNotificationSheet(
          context: context, 
          title: "Perhatian", 
          message: "Berat tidak boleh kosong", 
          primaryButtonText: "OK", 
          onPrimaryPressed: () {
            context.pop();
          },
        );
        return;
      }
      if (formRepaired['account_id'] == null) {
        NotificationHelper.showNotificationSheet(
          context: context, 
          title: "Perhatian", 
          message: "Silahkan pilih akun", 
          primaryButtonText: "OK", 
          onPrimaryPressed: () {
            context.pop();
          },
        );
        return;
      }
      if (formRepaired['expense'] == 0) {
        NotificationHelper.showNotificationSheet(
          context: context, 
          title: "Perhatian", 
          message: "Biaya tidak boleh kosong", 
          primaryButtonText: "OK", 
          onPrimaryPressed: () {
            context.pop();
          },
        );
        return;
      }
      // Approve Repair
      final res = await StockOutAPI.approveRepair(
        context,
        formRepaired,
      );
      if (res) {
        NotificationHelper.showNotificationSheet(
          context: context,
          title: "Berhasil",
          message: "Stock out berhasil diperbaiki",
          primaryColor: AppColors.success,
          primaryButtonText: "OK",
          onPrimaryPressed: () {
            context.pop();
          },
        );
        setState(() {
          // refresh data
          stockOuts.removeWhere((so) => so.id == formRepaired['id']);
          _groupStockOpnames();
          formRepaired = {'weight': 0, 'expense': 0, 'account_id': null};
        });
      }
  }

  // Fetch Accounts for tukar kurang TODOELLA
  List<Account> accounts = [];
  Future<void> _fetchAccounts() async {
    debugPrint('fetching accounts...');
    final res = await AccountsApi.fetchAccountFromAPI(context, 
      accountTypeId: '1',
    );
    setState(() {
      accounts = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    final actions = context.read<PermissionCubit>().state.actions(
      'inventory/stock-out',
    );
    debugPrint('Actions: $actions');
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
                                      Row(
                                        children: [
                                          // Delete
                                          if (actions.contains('delete'))
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
                                          // Gap
                                          if (actions.contains('delete') && stockOut.takenOutReason == 1)
                                            const SizedBox(width: 8),
                                          // Approve
                                          if (stockOut.takenOutReason == 1)
                                            InkWell(
                                              onTap: () {
                                                _approveRepair(stockOut.id);
                                              },
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(
                                                  8.0,
                                                ),
                                                child: Container(
                                                  color: AppColors.success,
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    CupertinoIcons.checkmark,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
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
          if (actions.contains('add')) {
            context.push('/stock-out/add');
          }
        },
        backgroundColor:
            actions.contains('add') ? AppColors.pinkPrimary : Colors.grey,
        child: const Icon(CupertinoIcons.add, color: Colors.white),
      ),
    );
  }
}
