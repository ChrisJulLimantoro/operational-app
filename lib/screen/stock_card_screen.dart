import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:operational_app/api/product.dart';
import 'package:operational_app/api/stock_card.dart';
import 'package:operational_app/model/product.dart';
import 'package:operational_app/model/stock_card.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/stock_card_card.dart';

class StockCardScreen extends StatefulWidget {
  const StockCardScreen({super.key});

  @override
  State<StockCardScreen> createState() => _StockCardScreenState();
}

class _StockCardScreenState extends State<StockCardScreen> {
  List<StockCard> stockCards = [];
  List<Product> products = [];
  bool isLoading = false;
  String? selectedProduct;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  final search = TextEditingController();
  bool isLoadingProduct = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    startDate = DateTime(now.year, now.month, 1);
    endDate = DateTime(now.year, now.month + 1, 0);
    _fetchProducts();
    _fetchstockCards();

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

  Future<void> _fetchstockCards() async {
    setState(() => isLoading = true);
    try {
      stockCards = await StockCardAPI.fetchStockCards(
        context,
        dateStart: startDate,
        dateEnd: endDate,
        productID: selectedProduct,
      );
    } catch (e) {
      debugPrint("Error fetching stock cards: $e");
    }
    setState(() => isLoading = false);
  }

  Future<void> _fetchProducts() async {
    if (isLoadingProduct) return;
    setState(() => isLoadingProduct = true);

    try {
      List<Product> newProduct = await ProductAPI.fetchProducts(context);
      debugPrint('Fetched ${newProduct.length} stores');

      if (newProduct.isNotEmpty) {
        setState(() => products = newProduct);
      } else {}
    } catch (e) {
      debugPrint("Error fetching stores: $e");
    }

    setState(() => isLoadingProduct = false);
  }

  void _openFilterSheet(BuildContext context) {
    // Temporary filter values
    DateTime tempStartDate = startDate;
    DateTime tempEndDate = endDate;
    String? tempSelectedProduct = selectedProduct;

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
                      decoration: const InputDecoration(labelText: 'Product'),
                      value: tempSelectedProduct,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('All Product'),
                        ),
                        ...products.map(
                          (product) => DropdownMenuItem(
                            value: product.id.toString(),
                            child: Text(product.name),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setModalState(() {
                          tempSelectedProduct = val;
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
                          selectedProduct = tempSelectedProduct;
                        });
                        _fetchstockCards();
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
    final filteredStockCard =
        stockCards.where((card) {
          return (card.name ?? '').toLowerCase().contains(searchQuery) ||
              (card.code ?? '').toLowerCase().contains(searchQuery) ||
              (card.description ?? '').toLowerCase().contains(searchQuery) ||
              (card.transCode ?? '').toLowerCase().contains(searchQuery) ||
              (card.productId ?? '').toLowerCase().contains(searchQuery);
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
            title: Text('Stock Card', style: AppTextStyles.headingWhite),
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

          if (filteredStockCard.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final stockcard = filteredStockCard[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  child: StockCardCard(stockCard: stockcard),
                );
              }, childCount: filteredStockCard.length),
            )
          else if (!isLoading)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text('No Data Found', style: AppTextStyles.labelBlue),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 8.0,
            ),
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
