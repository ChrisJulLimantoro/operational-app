import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:operational_app/api/category.dart';
import 'package:operational_app/api/stock_mutation.dart';
import 'package:operational_app/api/store.dart';
import 'package:operational_app/bloc/auth_bloc.dart';
import 'package:operational_app/model/category.dart';
import 'package:operational_app/model/stock_mutation.dart';
import 'package:operational_app/model/store.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/stock_mutation_card.dart';
import 'package:provider/provider.dart';

class StockMutationScreen extends StatefulWidget {
  const StockMutationScreen({super.key});

  @override
  State<StockMutationScreen> createState() => _StockMutationScreenState();
}

class _StockMutationScreenState extends State<StockMutationScreen> {
  List<StockMutation> stockMutations = [];
  List<Category> categories = [];
  bool isLoading = false;
  String? selectedCategory;
  String? selectedStore;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  final search = TextEditingController();
  bool isLoadingStores = false;
  List<Store> stores = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    startDate = DateTime(now.year, now.month, 1);
    endDate = DateTime(now.year, now.month + 1, 0);
    _fetchCategories();
    _fetchStores();
    _fetchStockMutations();

    search.addListener(() {
      setState(() {
        searchQuery = search.text.toLowerCase();
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _fetchStockMutations() async {
    setState(() => isLoading = true);
    try {
      stockMutations = await StockMutationAPI.fetchStockMutations(
        context,
        dateStart: startDate,
        dateEnd: endDate,
        categoryID: selectedCategory,
        store: selectedStore
      );
    } catch (e) {
      debugPrint("Error fetching stock mutations: $e");
    }
    setState(() => isLoading = false);
  }

  Future<void> _fetchCategories() async {
    final authCubit = context.read<AuthCubit>();
    List<Category> newCategories = await CategoryAPI.fetchCategories(
      context,
      storeId: authCubit.state.storeId,
    );
    setState(() => categories = newCategories);
  }
  Future<void> _fetchStores() async {
    if (isLoadingStores) return;
    setState(() => isLoadingStores = true);

    try {
      List<Store> newStores = await StoreAPI.fetchStores(context);
      debugPrint('Fetched ${newStores.length} stores');

      if (newStores.isNotEmpty) {
        setState(() => stores = newStores);
      } else {}
    } catch (e) {
      debugPrint("Error fetching stores: $e");
    }

    setState(() => isLoadingStores = false);
  }

  void _openFilterSheet(BuildContext context) {
    // Temporary filter values
    DateTime tempStartDate = startDate;
    DateTime tempEndDate = endDate;
    String? tempSelectedCategory = selectedCategory;
    String? tempSelectedStore = selectedStore;

    final startDateController = TextEditingController(
      text: '${tempStartDate.day}/${tempStartDate.month}/${tempStartDate.year}',
    );
    final endDateController = TextEditingController(
      text: '${tempEndDate.day}/${tempEndDate.month}/${tempEndDate.year}',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return FractionallySizedBox(
              heightFactor: 0.6,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text("Filter", style: AppTextStyles.subheadingBlue),
                    const SizedBox(height: 20),

                    // Start Date
                    TextFormField(
                      controller: startDateController,
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                      ),
                      onChanged: (value) {
                        // Optionally parse and update tempStartDate
                        try {
                          final parts = value.split('/');
                          if (parts.length == 3) {
                            final parsedDate = DateTime(
                              int.parse(parts[2]),
                              int.parse(parts[1]),
                              int.parse(parts[0]),
                            );
                            setModalState(() {
                              tempStartDate = parsedDate;
                            });
                          }
                        } catch (_) {}
                      },
                      onTap: () async {
                        // Optional: open date picker on tap
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: tempStartDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setModalState(() {
                            tempStartDate = picked;
                            startDateController.text =
                                '${picked.day}/${picked.month}/${picked.year}';
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // End Date
                    TextFormField(
                      controller: endDateController,
                      decoration: const InputDecoration(labelText: 'End Date'),
                      onChanged: (value) {
                        try {
                          final parts = value.split('/');
                          if (parts.length == 3) {
                            final parsedDate = DateTime(
                              int.parse(parts[2]),
                              int.parse(parts[1]),
                              int.parse(parts[0]),
                            );
                            setModalState(() {
                              tempEndDate = parsedDate;
                            });
                          }
                        } catch (_) {}
                      },
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: tempEndDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setModalState(() {
                            tempEndDate = picked;
                            endDateController.text =
                                '${picked.day}/${picked.month}/${picked.year}';
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Store Dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Store'),
                      value: tempSelectedStore,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('All Store'),
                        ),
                        ...stores.map(
                          (store) => DropdownMenuItem(
                            value: store.id.toString(),
                            child: Text(store.name),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setModalState(() {
                          tempSelectedStore = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Category'),
                      value: tempSelectedCategory,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('All Category'),
                        ),
                        ...categories.map(
                          (category) => DropdownMenuItem(
                            value: category.id.toString(),
                            child: Text(category.name),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setModalState(() {
                          tempSelectedCategory = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Apply Filter Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          startDate = tempStartDate;
                          endDate = tempEndDate;
                          selectedCategory = tempSelectedCategory;
                          selectedStore = tempSelectedStore;
                        });
                        _fetchStockMutations();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.bluePrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Apply Filter",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredMutations = stockMutations.where((mutation) {
      return (mutation.categoryName ?? '').toLowerCase().contains(searchQuery);
    }).toList();


    return Scaffold(
      body: CustomScrollView(
        scrollBehavior: const CupertinoScrollBehavior(),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.bluePrimary,
            title: Text('Stock Mutations', style: AppTextStyles.headingWhite),
            leading: IconButton(
              icon: const Icon(CupertinoIcons.arrow_left, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),

          // SEARCH BAR
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: SearchBarWidget(
                controller: search,
                onFilterTap: () => _openFilterSheet(context),
              ),
            ),
          ),

          if (filteredMutations.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final mutation = filteredMutations[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: StockMutationCard(stockMutation: mutation),
                  );
                },
                childCount: filteredMutations.length,
              ),
            )
          else if (!isLoading)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'No Stock Mutations',
                  style: AppTextStyles.labelBlue,
                ),
              ),
            ),

          if (isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 52),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onFilterTap;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onFilterTap,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            child: Icon(CupertinoIcons.search, color: AppColors.pinkPrimary),
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'search...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: AppColors.pinkPrimary.withOpacity(0.8),
                ),
              ),
              controller: _controller,
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
                debugPrint(_controller.value.text);
              },
              cursorColor: AppColors.pinkPrimary,
              style: TextStyle(color: AppColors.pinkPrimary),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt, color: AppColors.pinkPrimary),
            onPressed: () {
              widget.onFilterTap();
            },
          ),
        ],
      ),
    );
  }
}