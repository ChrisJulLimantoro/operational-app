import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:operational_app/api/company.dart';
import 'package:operational_app/api/profit_loss.dart';
import 'package:operational_app/api/store.dart';
import 'package:operational_app/model/company.dart';
import 'package:operational_app/model/profit_loss.dart';
import 'package:operational_app/model/store.dart';
import 'package:operational_app/notifier/sales_notifier.dart';
import 'package:operational_app/theme/text.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:intl/intl.dart';

class ProfitLossScreen extends StatefulWidget {
  const ProfitLossScreen({super.key});

  @override
  State<ProfitLossScreen> createState() => _ProfitLossScreenState();
}

class _ProfitLossScreenState extends State<ProfitLossScreen> {
  bool isLoadingStores = false;
  bool isLoadingCompanies = false;
  bool isLoadingPL = false;
  bool isRefresh = false;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  String? selectedCompany;
  String? selectedStore;
  List<Company> companies = [];
  List<Store> stores = [];
  List<PLSection> profitLossData = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    startDate = DateTime(now.year, now.month, 1);
    endDate = DateTime(now.year, now.month + 1, 0);
    _fetchCompanies();
    _fetchStores();
    _fetchProfitLoss();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final notifier = Provider.of<SalesNotifier>(context);
    if (notifier.shouldRefresh) {
      _refreshProfitLoss();
      notifier.resetRefresh();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchProfitLoss() async {
    if (isLoadingPL) return;

    setState(() => isLoadingPL = true);

    try {
      List<PLSection> newPL = await ProfitLossAPI.fetchPLDataFromAPI(
        context,
        startDate: startDate,
        endDate: endDate,
        companyID: selectedCompany,
        store: selectedStore,
      );

      debugPrint('Fetched ${newPL.length} Profit loss');

      if (newPL.isEmpty) {
        // setState(() => hasMore = false);
      } else {
        setState(() {
          profitLossData = newPL;
        });
      }
    } catch (e) {
      debugPrint("Error fetching profit loss: $e");
    }

    setState(() => isLoadingPL = false);
  }

  Future<void> _fetchCompanies() async {
    if (isLoadingCompanies) return;
    setState(() => isLoadingCompanies = true);

    try {
      List<Company> newCompanies = await CompanyAPI.fetchCompanies(context);
      debugPrint('Fetched ${newCompanies.length} companies');

      if (newCompanies.isNotEmpty) {
        setState(() => companies = newCompanies);
      } else {}
    } catch (e) {
      debugPrint("Error fetching companies: $e");
    }

    setState(() => isLoadingCompanies = false);
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

  Future<void> _refreshProfitLoss() async {
    if (isLoadingPL) return;
    isRefresh = true;
    setState(() {
      isLoadingPL = true;
    });

    try {
      List<PLSection> latestProfitLoss = await ProfitLossAPI.fetchPLDataFromAPI(
        context,
      );

      if (latestProfitLoss.isNotEmpty) {
      } else {}

      await Future.delayed(Duration(milliseconds: 200));
    } catch (e) {
      debugPrint("Error fetching newest transactions: $e");
    }

    setState(() => isLoadingPL = false);
    isRefresh = false;
  }

  void _openFilterSheet(BuildContext context) {
    // Temporary filter values
    DateTime tempStartDate = startDate;
    DateTime tempEndDate = endDate;
    String? tempSelectedCompany = selectedCompany;
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

                    // Company Dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Company'),
                      value: tempSelectedCompany,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('All Company'),
                        ),
                        ...companies.map(
                          (company) => DropdownMenuItem(
                            value: company.id.toString(),
                            child: Text(company.name),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setModalState(() {
                          tempSelectedCompany = val;
                        });
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
                    const SizedBox(height: 24),

                    // Apply Filter Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          startDate = tempStartDate;
                          endDate = tempEndDate;
                          selectedCompany = tempSelectedCompany;
                          selectedStore = tempSelectedStore;
                        });
                        _fetchProfitLoss();
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

  Future<void> _handlePrintPDF() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Ask permission (only for Android)
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        bool hasPermission = false;

        if (sdkInt >= 30) {
          final status = await Permission.manageExternalStorage.request();
          if (status.isGranted) {
            hasPermission = true;
          } else {
            Navigator.of(context).pop(); // Close loader
            openAppSettings(); // Redirect to settings
            return;
          }
        } else {
          final status = await Permission.storage.request();
          if (status.isGranted) {
            hasPermission = true;
          } else {
            Navigator.of(context).pop(); // Close loader
            return;
          }
        }

        if (!hasPermission) {
          Navigator.of(context).pop(); // Close loader
          return;
        }
      }

      // Call your API to generate PDF
      final pdfBytes = await ProfitLossAPI.generatePDF(
        context: context,
        filters: {
          if (selectedStore != null) 'store': selectedStore,
          if (selectedCompany != null) 'company_id': selectedCompany,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'labelRangeSelected':
              '${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}',
        },
      );
      // DEBUGGING
      if (pdfBytes == null) {
        debugPrint("pdfBytes is null!");
        return;
      }

      // Print length
      debugPrint("pdfBytes length: ${pdfBytes.length}");

      // Print preview as hex
      final preview = pdfBytes!.take(10).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
      debugPrint("pdfBytes (first 10 bytes in hex): $preview");

      // Print preview as text
      final strPreview = String.fromCharCodes(pdfBytes!.take(20));
      debugPrint("First few bytes as string: $strPreview");
      // DEBUGGING


      Navigator.of(context).pop(); // Close loader

      if (pdfBytes == null) return;

      // Save the PDF file
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      // Open the file
      await OpenFilex.open(file.path);
    } catch (e) {
      Navigator.of(context).pop(); // Close loader in case of error
      debugPrint("Error while generating PDF: $e");

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: const Text("An error occurred while generating the PDF."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }




  final currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '');

  Widget buildProfitLoss(List<PLSection> plData) {
    String formatDate(DateTime date) {
      return '${date.day}/${date.month}/${date.year}';
    }

    String getCompanyName(String? id) {
      if (id == null) return 'All Companies';
      final found = companies.firstWhere(
        (c) => c.id.toString() == id,
        orElse:
            () => Company(
              id: '',
              name: 'Unknown',
              code: '',
              ownerId: '',
              createdAt: null,
            ),
      );
      return found.name;
    }

    String getStoreName(String? id) {
      if (id == null) return 'All Stores';
      final found = stores.firstWhere(
        (s) => s.id.toString() == id,
        orElse:
            () => Store(
              id: '',
              name: 'Unknown',
              code: '',
              npwp: '',
              address: '',
              openDate: DateTime.now(),
              longitude: 0,
              latitude: 0,
              description: '',
              isActive: false,
              isFlexPrice: false,
              isFloatPrice: false,
              taxPercentage: 0,
              poinConfig: 0,
              logo: '',
              company: null,
              createdAt: null,
            ),
      );
      return found.name;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 📌 TITLE HEADER WITH FILTERS
          Center(
            child: Column(
              children: [
                Text(
                  'Profit & Loss Report',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${formatDate(startDate)} - ${formatDate(endDate)}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  '${getCompanyName(selectedCompany)} | ${getStoreName(selectedStore)}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// 🔽 PROFIT LOSS DATA
          ...plData.map((section) {
            final dataItems = section.data;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: Text(
                    section.label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...List.generate(dataItems.length, (index) {
                  final item = dataItems[index];
                  final isLast = index == dataItems.length - 1;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start, // Allow wrapping
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Text(
                              item.name,
                              softWrap: true,
                              style: TextStyle(
                                fontWeight:
                                    isLast ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                        if (item.amount != null)
                          Text(
                            currencyFormatter.format(item.amount),
                            style: TextStyle(
                              fontWeight:
                                  isLast ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true, // Ensures the app bar remains visible when scrolling
            floating: false, // No snap effect
            elevation: 0,
            title: Text('Profit & Loss', style: AppTextStyles.headingWhite),
            leading: IconButton(
              icon: const Icon(CupertinoIcons.arrow_left, color: Colors.white),
              onPressed: () {
                context.pop();
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.filter_alt_outlined,
                  color: Colors.white,
                ),
                onPressed: () => _openFilterSheet(context),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: buildProfitLoss(profitLossData), // <- insert it here
            ),
          ),
          // Print button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _handlePrintPDF,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Print PDF'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: AppColors.pinkPrimary,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Loading Indicator
          if (isLoadingPL)
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
