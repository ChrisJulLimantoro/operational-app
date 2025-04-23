import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:operational_app/api/store.dart';
import 'package:operational_app/bloc/auth_bloc.dart';
import 'package:operational_app/bloc/permission_bloc.dart';
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
      {
        "group": "Menu Master",
        "items": [
          {
            "title": "Usaha",
            "icon": Icons.store,
            "route": "/company",
            "feature": "master/company",
          },
          {
            "title": "Cabang",
            "icon": Icons.business,
            "route": "/store",
            "feature": "master/store",
          },
          {
            "title": "Pegawai",
            "icon": Icons.people,
            "route": "/employee",
            "feature": "master/employee",
          },
          {
            "title": "Kategori",
            "icon": Icons.category,
            "route": "/category",
            "feature": "master/category",
          },
          {
            "title": "Produk",
            "icon": Icons.production_quantity_limits,
            "route": "/product",
            "feature": "inventory/product",
          },
          {
            "title": "Operasi",
            "icon": Icons.cases,
            "route": "/operation",
            "feature": "inventory/operation",
          },
        ],
      },
    ],
    1: [
      {
        "group": "Menu Inventory",
        "items": [
          {
            "title": "Stock Opname",
            "icon": Icons.check_box,
            "route": "/stock-opname",
            "feature": "inventory/stock-opname",
          },
          {
            "title": "Stock Out",
            "icon": Icons.outbond_sharp,
            "route": "/stock-out",
            "feature": "inventory/stock-out",
          },
          {
            "title": "Check Product",
            "icon": Icons.manage_search,
            "route": "/check-product",
            "feature": "inventory/check-product",
          }
        ],
      },
      {
        "group": "Menu Transaksi",
        "items": [
          {
            "title": "Penjualan",
            "icon": Icons.sell,
            "route": "/sales",
            "feature": "transaction/sales",
          },
          {
            "title": "Pembelian",
            "icon": Icons.shopping_bag,
            "route": "/purchase",
            "feature": "transaction/purchase",
          },
          {
            "title": "Trade",
            "icon": Icons.undo,
            "route": "/trade",
            "feature": "transaction/trade",
          },
        ],
      },
    ],
    2: [
      {
        "group": "Menu Laporan",
        "items": [
          {
            "title": "Laba rugi",
            "icon": Icons.bar_chart,
            "route": "/profit-loss",
            "feature": "finance/profit-loss",
          },
          {
            "title": "Mutasi Stok",
            "icon": Icons.inventory,
            "route": "/stock-mutation",
            "feature": "finance/stock-mutation",
          },
          {
            "title": "Kartu Stok",
            "icon": Icons.checklist,
            "route": "/stock-card",
            "feature": "finance/stock-card",
          },
        ],
      },
    ],
  };

  final List<Color> _tabColors = [
    AppColors.bluePrimary, // Master
    AppColors.pinkPrimary, // Transaksi
    AppColors.pinkPrimary, // Laporan
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
    _searchController.addListener(() {
      setState(() {}); // rebuild on search text change
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String query = _searchController.text.toLowerCase();

    List<Map<String, dynamic>> filteredMenu =
        (_menuData[_selectedTabIndex] ?? [])
            .map((group) {
              List<Map<String, dynamic>> filteredItems =
                  (group['items'] as List<Map<String, dynamic>>)
                      .where(
                        (item) => item['title'].toLowerCase().contains(query),
                      )
                      .toList();

              return {'group': group['group'], 'items': filteredItems};
            })
            .where((group) => (group['items'] as List).isNotEmpty)
            .toList();

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (prev, state) => prev.storeId != state.storeId,
      listener: (context, state) {
        if (state.storeId.isNotEmpty) {
          context.read<PermissionCubit>().fetchPermissions(context);
        }
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
                      IconButton(
                        icon: const Icon(
                          Icons.change_circle,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          GoRouter.of(context).push("/active-store");
                        },
                      ),
                      Spacer(),
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Loop through each group
                        for (var x = 0; x < filteredMenu.length; x++)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                filteredMenu[x]["group"],
                                style: AppTextStyles.headingBlue,
                              ),
                              const SizedBox(height: 28),
                              // Instead of Flexible, use a Column directly
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (filteredMenu[x]['items'].length == 0)
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Text("Menu tidak ditemukan!"),
                                      ),
                                    )
                                  else
                                    for (
                                      var i = 0;
                                      i < filteredMenu[x]['items'].length;
                                      i += 3
                                    )
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 24.0,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            for (var j = i; j < i + 3; j++)
                                              if (j <
                                                  filteredMenu[x]['items']
                                                      .length)
                                                Expanded(
                                                  child: _buildMenuItem(
                                                    filteredMenu[x]['items'][j],
                                                  ),
                                                )
                                              else
                                                const Expanded(
                                                  child: SizedBox(),
                                                ),
                                          ],
                                        ),
                                      ),
                                ],
                              ),
                            ],
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
    final condition = context.read<PermissionCubit>().state.hasPermission(
      item["feature"],
      'open',
    );
    return InkWell(
      onTap: () {
        // Check if the user has permission to access this feature
        if (condition) {
          GoRouter.of(context).push(item["route"]); // Navigate to the route
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  condition
                      ? _tabColors[_selectedTabIndex]
                      : Colors.grey.shade600,
              shape: BoxShape.circle,
            ),
            child: Icon(
              item["icon"],
              size: 30,
              color: condition ? Colors.white : Colors.grey.shade200,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item["title"],
            style:
                condition ? AppTextStyles.labelBlue : AppTextStyles.labelGrey,
          ),
        ],
      ),
    );
  }
}
