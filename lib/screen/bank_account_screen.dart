import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:operational_app/api/bank_account.dart'; // Import BankAccountAPI
import 'package:operational_app/model/bank_account.dart'; // Import model BankAccount
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/search_bar.dart';
import 'package:operational_app/widget/text_card_detail.dart';

class BankAccountScreen extends StatefulWidget {
  const BankAccountScreen({super.key});

  @override
  State<BankAccountScreen> createState() => _BankAccountScreenState();
}

class _BankAccountScreenState extends State<BankAccountScreen> {
  final _scroll = ScrollController();
  final search = TextEditingController();
  List<BankAccount> bankAccounts = List.empty(growable: true);
  bool isLoading = false;
  bool isRefresh = false;
  // bool hasMore = true; // Tidak perlu hasMore karena tidak ada pagination

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _fetchBankAccounts(); // Panggil fungsi fetchBankAccounts
  }

  @override
  void dispose() {
    _scroll.dispose();
    search.dispose();
    super.dispose();
  }

  Future<void> _fetchBankAccounts() async {
    if (isLoading) return; // Hapus !hasMore

    setState(() => isLoading = true);

    try {
      List<BankAccount> newBankAccounts =
          await BankAccountAPI.fetchBankAccounts(
        context,
        search: search.text, // Teruskan parameter pencarian
      );

      print(newBankAccounts);

      // Karena tidak ada pagination, kita hanya akan mengganti list secara penuh
      // daripada menambahkan ke list yang sudah ada.
      setState(() {
        bankAccounts = newBankAccounts;
      });
    } catch (e) {
      debugPrint("Error fetching bank accounts: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> _refreshBankAccounts() async {
    if (isLoading) return;
    isRefresh = true;
    setState(() {
      isLoading = true;
      bankAccounts.clear(); // Hapus data lama
      // page = 1; // Tidak perlu reset page
      // hasMore = true; // Tidak perlu hasMore
    });

    _scroll.removeListener(_onScroll);

    try {
      List<BankAccount> latestBankAccounts =
          await BankAccountAPI.fetchBankAccounts(
        context,
        search: search.text,
      );

      setState(() {
        bankAccounts = latestBankAccounts;
      });

      await Future.delayed(
          const Duration(milliseconds: 200)); // Pastikan UI update
      _scroll.jumpTo(1); // Kembali ke atas
    } catch (e) {
      debugPrint("Error refreshing bank accounts: $e");
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
      // double maxScroll = _scroll.position.maxScrollExtent; // Tidak perlu maxScrollExtent untuk "load more"

      // Trigger refresh saat scroll ke atas (pull to refresh)
      if (offset <= -40) {
        _refreshBankAccounts();
      }
      // Hapus logika untuk "load more" karena tidak ada pagination
    });
  }

  void _onSearchChanged() {
    // Mengubah parameter onChanged menjadi String value
    _scroll.jumpTo(0);
    if (isLoading) return;
    _refreshBankAccounts();
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
            title: Text('Bank Accounts', style: AppTextStyles.headingWhite),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Column(
                // Menggunakan Column untuk daftar item
                children: [
                  // SearchBarWidget(
                  //   controller: search,
                  //   onChanged: _onSearchChanged, // Pastikan ini cocok
                  // ),
                  const SizedBox(height: 10), // Spasi setelah search bar
                  // Menampilkan daftar Bank Accounts
                  ...bankAccounts.map(
                    (bankAccount) => Card(
                      color: Colors.white,
                      elevation: 1,
                      margin: const EdgeInsets.symmetric(
                          vertical: 6), // Margin antar kartu
                      child: InkWell(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bankAccount.bankName,
                                style: AppTextStyles.headingBlue,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const Divider(),
                              TextCardDetail(
                                label: 'Nomor Akun',
                                value: bankAccount.accountNumber,
                                type: 'text',
                              ),
                              TextCardDetail(
                                label: 'Nama Pemegang Akun',
                                value: bankAccount.accountHolder,
                                type: 'text',
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
          if (bankAccounts.isEmpty && !isLoading)
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
                        "Tidak ada Akun Bank ditemukan",
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
