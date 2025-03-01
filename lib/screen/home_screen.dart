import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/search_bar.dart';
import 'qr_scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  int _selectedTabIndex = 0;

  /// Dummy menu data (can be fetched from API)
  final Map<int, List<Map<String, dynamic>>> _menuData = {
    0: [
      {"title": "Usaha", "icon": Icons.store, "route": "/usaha"},
      {"title": "Cabang", "icon": Icons.business, "route": "/cabang"},
      {"title": "Pegawai", "icon": Icons.people, "route": "/pegawai"},
      {"title": "Produk", "icon": Icons.shopping_cart, "route": "/produk"},
      {"title": "Kategori", "icon": Icons.category, "route": "/kategori"},
    ],
    1: [
      {"title": "Penjualan", "icon": Icons.sell, "route": "/penjualan"},
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

  String? scannedData;

  void _openScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => QRScannerScreen(
              onScanned: (data) {
                setState(() {
                  scannedData = data;
                });
              },
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredMenu =
        _menuData[_selectedTabIndex] ?? [];

    return Scaffold(
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
                    Text("SA | Store A", style: AppTextStyles.headingWhite),
                    Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications),
                      color: Colors.white,
                    ),
                    IconButton(
                      onPressed: () {},
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
                      // Expanded(
                      //   child: ListView(
                      //     children: [
                      //       GridView.count(
                      //         shrinkWrap:
                      //             true, // ✅ This now works because it's inside ListView
                      //         physics:
                      //             NeverScrollableScrollPhysics(), // Prevents nested scrolling issues
                      //         crossAxisCount: 3,
                      //         crossAxisSpacing: 12,
                      //         mainAxisSpacing: 12,
                      //         childAspectRatio: 1,
                      //         children:
                      //             filteredMenu
                      //                 .map((item) => _buildMenuItem(item))
                      //                 .toList(),
                      //       ),
                      //     ],
                      //   ),
                      // ),
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
    );
  }

  /// Build a menu button
  Widget _buildMenuItem(Map<String, dynamic> item) {
    return InkWell(
      onTap: () {
        GoRouter.of(context).go(item["route"]); // Navigate to the route
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
