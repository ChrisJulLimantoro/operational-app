import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:operational_app/api/store_balance.dart';
import 'package:operational_app/model/balance_logs.dart';
import 'package:operational_app/model/bank_account.dart';
import 'package:operational_app/model/payout_requests.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/text_card_detail.dart';

class PayoutScreen extends StatefulWidget {
  const PayoutScreen({super.key});

  @override
  State<PayoutScreen> createState() => _PayoutScreenState();
}

class _PayoutScreenState extends State<PayoutScreen> {
  final _scroll = ScrollController();

  double _currentBalance = 0.0;
  List<PayoutRequest> _payoutRequests = [];
  List<BalanceLog> _balanceLogs = [];

  bool isLoading = false;
  bool isRefreshing = false;

  bool _showProofModal = false;
  String _proofImageUrl = '';

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _fetchStoreBalanceData();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _fetchStoreBalanceData() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      final data = await StoreBalanceAPI.fetchStoreBalanceData(context);
      if (data != null) {
        setState(() {
          _currentBalance = data.balance;

          _payoutRequests = data.payoutRequests.toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          _balanceLogs = data.balanceLogs.toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        });
      }
    } catch (e) {
      debugPrint("Error fetching store balance data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _refreshStoreBalanceData() async {
    if (isRefreshing) return;
    setState(() {
      isRefreshing = true;
      _currentBalance = 0.0;
      _payoutRequests.clear();
      _balanceLogs.clear();
    });

    try {
      final data = await StoreBalanceAPI.fetchStoreBalanceData(context);
      if (data != null) {
        setState(() {
          _currentBalance = data.balance;
          _payoutRequests = data.payoutRequests.toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _balanceLogs = data.balanceLogs.toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        });
      }
    } catch (e) {
      debugPrint("Error refreshing store balance data: $e");
    } finally {
      setState(() => isRefreshing = false);
    }
  }

  Timer? _debounce;

  void _onScroll() {
    if (isLoading || isRefreshing || (_debounce?.isActive ?? false)) {
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (isRefreshing) return;

      double offset = _scroll.position.pixels;
      if (offset <= -40) {
        _refreshStoreBalanceData();
      }
    });
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  void _showProof(String imageUrl) {
    setState(() {
      _proofImageUrl = imageUrl;
      _showProofModal = true;
    });
  }

  void _closeProofModal() {
    setState(() {
      _showProofModal = false;
      _proofImageUrl = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredPayouts = _payoutRequests.where((req) {
      return true;
    }).toList();

    final filteredBalanceLogs = _balanceLogs.where((log) {
      return true;
    }).toList();

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            scrollBehavior: const CupertinoScrollBehavior(),
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _scroll,
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: false,
                elevation: 0,
                title: Text('Store Balance', style: AppTextStyles.headingWhite),
                leading: IconButton(
                  icon: const Icon(CupertinoIcons.arrow_left,
                      color: Colors.white),
                  onPressed: () {
                    _scroll.jumpTo(0);
                    context.pop();
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Balance: ${_formatCurrency(_currentBalance)}',
                        style: AppTextStyles.headingBlue,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Payout Requests',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (filteredPayouts.isEmpty && !isLoading)
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Center(
                            child: Text(
                              'Tidak ada permintaan payout yang ditemukan.',
                            ),
                          ),
                        )
                      else
                        ...filteredPayouts.map(
                          // FIX: Explicitly cast `request` to PayoutRequest
                          (dynamic requestItem) {
                            final request = requestItem as PayoutRequest;
                            return Card(
                              color: Colors.white,
                              elevation: 1,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextCardDetail(
                                      label: 'Jumlah',
                                      value: request.formattedAmount,
                                      type: 'text',
                                    ),
                                    TextCardDetail(
                                      label: 'Status',
                                      value: request.formattedStatus,
                                      type: 'text',
                                    ),
                                    if (request.reason != null &&
                                        request.reason!.isNotEmpty)
                                      TextCardDetail(
                                        label: 'Alasan',
                                        value: request.reason!,
                                        type: 'text',
                                        isLong: true,
                                      ),
                                    TextCardDetail(
                                      label: 'Tanggal',
                                      value: request.formattedCreatedAt,
                                      type: 'text',
                                    ),
                                    if (request.proof != null &&
                                        request.proof!.isNotEmpty)
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton(
                                          onPressed: () => _showProof(
                                              'http://127.0.0.1:3000/${request.proof!}'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.pinkPrimary,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text(
                                            'Lihat Bukti',
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 20),
                      Text(
                        'Balance Logs',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (filteredBalanceLogs.isEmpty && !isLoading)
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Center(
                            child: Text(
                              'Tidak ada log saldo ditemukan.',
                            ),
                          ),
                        )
                      else
                        ...filteredBalanceLogs.map(
                          // FIX: Explicitly cast `log` to BalanceLog
                          (dynamic logItem) {
                            final log = logItem as BalanceLog;
                            return Card(
                              color: Colors.white,
                              elevation: 1,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextCardDetail(
                                      label: 'Jumlah',
                                      value: log.formattedAmount,
                                      type: 'text',
                                    ),
                                    TextCardDetail(
                                      label: 'Tipe',
                                      value: log.type,
                                      type: 'text',
                                      textStyle: TextStyle(
                                        color: log.type == 'INCOME'
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextCardDetail(
                                      label: 'Informasi',
                                      value: log.information,
                                      type: 'text',
                                      isLong: true,
                                    ),
                                    TextCardDetail(
                                      label: 'Tanggal',
                                      value: log.formattedCreatedAt,
                                      type: 'text',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
              if (isLoading &&
                  _currentBalance == 0.0 &&
                  _payoutRequests.isEmpty &&
                  _balanceLogs.isEmpty)
                SliverFillRemaining(
                  child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.bluePrimary)),
                ),
            ],
          ),
          if (_showProofModal)
            GestureDetector(
              onTap: _closeProofModal,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Bukti Payout',
                            style: AppTextStyles.headingBlue,
                          ),
                          const SizedBox(height: 16),
                          _proofImageUrl.isNotEmpty
                              ? Image.network(
                                  _proofImageUrl,
                                  fit: BoxFit.contain,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Text(
                                        'Gagal memuat gambar bukti.',
                                        style: TextStyle(color: Colors.red));
                                  },
                                )
                              : const Text('Tidak ada bukti tersedia.'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _closeProofModal,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.pinkPrimary,
                            ),
                            child: Text(
                              'Tutup',
                            ),
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
    );
  }
}
