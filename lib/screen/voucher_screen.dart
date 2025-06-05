import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal dan mata uang
import 'package:operational_app/api/voucher.dart'; // Import VoucherAPI
import 'package:operational_app/model/voucher.dart'; // Import model Voucher
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/search_bar.dart';
import 'package:operational_app/widget/text_card_detail.dart';

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  final _scroll = ScrollController();
  final search = TextEditingController();
  List<Voucher> vouchers = List.empty(growable: true);
  bool isLoading = false;
  bool isRefresh = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _fetchVouchers(); // Panggil fungsi fetchVouchers
  }

  @override
  void dispose() {
    _scroll.dispose();
    search.dispose();
    super.dispose();
  }

  Future<void> _fetchVouchers() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      List<Voucher> newVouchers = await VoucherAPI.fetchVouchers(
        context,
        search: search.text,
      );

      // Karena tidak ada pagination, kita hanya akan mengganti list secara penuh
      setState(() {
        vouchers = newVouchers;
      });
    } catch (e) {
      debugPrint("Error fetching vouchers: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> _refreshVouchers() async {
    if (isLoading) return;
    isRefresh = true;
    setState(() {
      isLoading = true;
      vouchers.clear(); // Hapus data lama
    });

    _scroll.removeListener(_onScroll);

    try {
      List<Voucher> latestVouchers = await VoucherAPI.fetchVouchers(
        context,
        search: search.text,
      );

      setState(() {
        vouchers = latestVouchers;
      });

      await Future.delayed(const Duration(milliseconds: 200));
      _scroll.jumpTo(1);
    } catch (e) {
      debugPrint("Error refreshing vouchers: $e");
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
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (isLoading) return;

      double offset = _scroll.position.pixels;

      // Trigger refresh saat scroll ke atas (pull to refresh)
      if (offset <= -40) {
        _refreshVouchers();
      }
    });
  }

  void _onSearchChanged() {
    // Mengubah parameter onChanged menjadi String value
    _scroll.jumpTo(0);
    if (isLoading) return;
    _refreshVouchers();
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
            pinned: true,
            floating: false,
            elevation: 0,
            title: Text('Vouchers', style: AppTextStyles.headingWhite),
            leading: IconButton(
              icon: const Icon(CupertinoIcons.arrow_left, color: Colors.white),
              onPressed: () {
                _scroll.jumpTo(0);
                context.pop();
              },
            ),
            // actions: [
            //   IconButton(
            //     icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            //     onPressed: () {
            //       // Tambahkan navigasi ke halaman tambah Voucher jika ada
            //       GoRouter.of(context)
            //           .push("/voucher/add"); // Sesuaikan rute Anda
            //     },
            //   ),
            // ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Column(
                children: [
                  // SearchBarWidget(
                  //   controller: search,
                  //   onChanged: _onSearchChanged,
                  // ),
                  const SizedBox(height: 10),
                  ...vouchers.map(
                    (voucher) => Card(
                      color: Colors.white,
                      elevation: 1,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: InkWell(
                        onTap: () {
                          // // Navigasi ke detail Voucher jika ada
                          // GoRouter.of(context).push(
                          //     "/voucher/detail/${voucher.id}"); // Sesuaikan rute Anda
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${voucher.name}',
                                style: AppTextStyles.headingBlue,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const Divider(),
                              TextCardDetail(
                                  label: 'Diskon',
                                  value:
                                      '${voucher.discountAmount.toString()}%',
                                  type: 'text'),
                              TextCardDetail(
                                label: 'Harga Poin',
                                value: voucher.poinPrice.toString(),
                                type: 'text',
                              ),
                              TextCardDetail(
                                label: 'Min. Pembelian',
                                value: NumberFormat.currency(
                                  locale: 'id_ID',
                                  symbol: 'Rp ',
                                  decimalDigits: 0,
                                ).format(voucher.minPurchase),
                                type: 'text',
                              ),
                              TextCardDetail(
                                label: 'Max. Diskon',
                                value: NumberFormat.currency(
                                  locale: 'id_ID',
                                  symbol: 'Rp ',
                                  decimalDigits: 0,
                                ).format(voucher.maxDiscount),
                                type: 'text',
                              ),
                              TextCardDetail(
                                label: 'Periode',
                                value:
                                    '${DateFormat('dd MMM yy').format(voucher.startDate)} - ${DateFormat('dd MMM yy').format(voucher.endDate)}',
                                type: 'text',
                              ),
                              TextCardDetail(
                                label: 'Status',
                                value:
                                    voucher.isActive ? 'Aktif' : 'Tidak Aktif',
                                type: 'text',
                                textStyle: TextStyle(color: voucher.isActive ? Colors.green : Colors.red, fontWeight: FontWeight.w800),
                              ),
                              if (voucher.description != null &&
                                  voucher.description!.isNotEmpty)
                                TextCardDetail(
                                  label: 'Deskripsi',
                                  value: voucher.description!,
                                  type: 'text',
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
          if (vouchers.isEmpty && !isLoading)
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
                      const SizedBox(height: 20),
                      Text(
                        "Tidak ada Voucher ditemukan",
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
