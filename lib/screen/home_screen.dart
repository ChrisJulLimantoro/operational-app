import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:operational_app/api/store.dart';
import 'package:operational_app/bloc/auth_bloc.dart';
import 'package:operational_app/model/store.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  int _selectedTabIndex = 0;
  Store? activeStore;

  /// Dummy menu data (can be fetched from API)
  final Map<int, List<Map<String, dynamic>>> _menuData = {
    0: [
      {"title": "Usaha", "icon": Icons.store, "route": "/company"},
      {"title": "Cabang", "icon": Icons.business, "route": "/store"},
      {"title": "Pegawai", "icon": Icons.people, "route": "/employee"},
      {"title": "Kategori", "icon": Icons.category, "route": "/category"},
    ],
    1: [
      {"title": "Penjualan", "icon": Icons.sell, "route": "/transaction"},
      {"title": "Pembelian", "icon": Icons.shopping_bag, "route": "/pembelian"},
      {"title": "Retur", "icon": Icons.undo, "route": "/retur"},
    ],
    2: [
      {"title": "Pendapatan", "icon": Icons.bar_chart, "route": "/pendapatan"},
      {
        "title": "Pengeluaran",
        "icon": Icons.money_off,
        "route": "/pengeluaran",
      },
      {
        "title": "Keuangan",
        "icon": Icons.account_balance,
        "route": "/keuangan",
      },
      {"title": "Inventory", "icon": Icons.inventory, "route": "/inventory"},
    ],
  };

  final List<Color> _tabColors = [
    AppColors.bluePrimary, // Master
    AppColors.pinkPrimary, // Transaksi
    AppColors.pinkSecondary, // Laporan
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  Future<void> _fetchStore() async {
    Store? store;

    if (context.read<AuthCubit>().state.storeId.isEmpty) {
      return;
    }

    store = await StoreAPI.fetchStore(
      context,
      context.read<AuthCubit>().state.storeId,
    );
    setState(() => activeStore = store);
  }

  @override
  void initState() {
    super.initState();
    _fetchStore();
  }

  String? scannedData;

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredMenu =
        _menuData[_selectedTabIndex] ?? [];

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (prev, state) => prev.storeId != state.storeId,
      listener: (context, state) {
        _fetchStore();
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.grey.shade300,
            ),

            /// Background
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.bluePrimary,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(8),
                ),
              ),
            ),

            /// Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100), // Space for status bar
                /// Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "${activeStore?.code ?? "-"} | ${activeStore?.name ?? "-"}",
                        style: AppTextStyles.headingWhite,
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications),
                        color: Colors.white,
                      ),
                      IconButton(
                        onPressed: () {
                          GoRouter.of(context).push("/setting");
                        },
                        icon: const Icon(Icons.settings),
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                /// Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SearchBarWidget(controller: _searchController),
                ),

                /// Menu Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 28,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                        bottom: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Menu Title
                        Text(
                          _selectedTabIndex == 0
                              ? "Menu Master"
                              : _selectedTabIndex == 1
                              ? "Menu Transaksi"
                              : "Menu Laporan",
                          style: AppTextStyles.headingBlue,
                        ),
                        SizedBox(height: 28),

                        /// Grid Menu Items
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var i = 0; i < filteredMenu.length; i += 3)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 24.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      for (var j = i; j < i + 3; j++)
                                        if (j < filteredMenu.length)
                                          Expanded(
                                            child: _buildMenuItem(
                                              filteredMenu[j],
                                            ),
                                          )
                                        else
                                          const Expanded(
                                            child: SizedBox(),
                                          ), // Empty slot to align layout
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        /// Bottom Navigation Bar
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedTabIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          selectedItemColor: _tabColors[_selectedTabIndex],
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.file_open_rounded),
              label: "Master",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tab_rounded),
              label: "Transaksi",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.file_download_rounded),
              label: "Laporan",
            ),
          ],
        ),
      ),
    );
  }

  /// Build a menu button
  Widget _buildMenuItem(Map<String, dynamic> item) {
    return InkWell(
      onTap: () {
        GoRouter.of(context).push(item["route"]); // Navigate to the route
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _tabColors[_selectedTabIndex],
              shape: BoxShape.circle,
            ),
            child: Icon(item["icon"], size: 30, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(item["title"], style: AppTextStyles.labelBlue),
        ],
      ),
    );
  }
}
