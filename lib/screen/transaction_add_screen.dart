import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:operational_app/api/accounts.dart';
import 'package:operational_app/api/category.dart';
import 'package:operational_app/api/customer.dart';
import 'package:operational_app/api/operation.dart';
import 'package:operational_app/api/product.dart';
import 'package:operational_app/api/transaction.dart';
import 'package:operational_app/helper/notification.dart';
import 'package:operational_app/model/account.dart';
import 'package:operational_app/model/customer.dart';
import 'package:operational_app/model/operation.dart';
import 'package:operational_app/model/transaction_operation.dart';
import 'package:operational_app/model/transaction_product.dart';
import 'package:operational_app/notifier/sales_notifier.dart';
import 'package:operational_app/screen/qr_scanner_screen.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/email_form.dart';
import 'package:operational_app/widget/form_sheet.dart';
import 'package:operational_app/widget/selection_form.dart';
import 'package:operational_app/widget/text_form.dart';
import 'package:operational_app/widget/text_card_detail.dart';
import 'package:operational_app/widget/transaction_operation_section.dart';
import 'package:operational_app/widget/transaction_product_section.dart';
import 'package:provider/provider.dart';

class TransactionAddScreen extends StatefulWidget {
  final int type;
  const TransactionAddScreen({super.key, this.type = 1});

  @override
  State<TransactionAddScreen> createState() => _TransactionAddScreenState();
}

class _TransactionAddScreenState extends State<TransactionAddScreen> {
  // DatePicker Functionality
  final TextEditingController dateController = TextEditingController();
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      dateController.text = "${picked.toLocal()}".split(' ')[0];
      setState(() {
        form['date'] = picked;
      });
    }
  }

  // Transaction Details
  List<TransactionProduct> itemSold = [];
  List<TransactionProduct> itemBought = [];
  List<TransactionOperation> operations = [];

  // Transaction Type
  List<Map<String, dynamic>> transactionType = [
    {"id": 1, "value": "Penjualan"},
    {"id": 2, "value": "Pembelian"},
    {"id": 3, "value": "Tukar Tambah"},
  ];
  List<Map<String, dynamic>> paymentMethod = [
    {"id": 1, "value": "Tunai"},
    {"id": 2, "value": "Transfer"},
    {"id": 3, "value": "Debit"},
  ];
  List<Account> accounts = [];
  List<Map<String, dynamic>> statuses = [
    {"id": 1, "value": "Belum Lunas"},
    {"id": 2, "value": "Lunas"},
    {"id": 3, "value": "Selesai"},
  ];
  Customer? customer;
  bool isOpen = false;

  // Form Data
  Map<String, dynamic> form = {
    'date': DateTime.now(),
    'customer_id': null,
    'payment_method': 1,
    'status': 1,
    'sub_total_price': 0.0,
    'tax_price': 0.0,
    'adjustment_price': 0.0,
    'total_price': 0.0,
    'paid_amount': 0.0,
    'transaction_type': 1,
    'account_id' : null,
  };
  Map<String, dynamic> config = {
    'tax_percent': null,
    'fixed_tt_adjustment': null,
    'percent_tt_adjustment': null,
    'fixed_kbl_adjustment': null,
    'percent_kbl_adjustment': null,
  };
  // Open QR Scanner
  Future<void> _qrScan(String type) async {
    final scanned = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );
    if (scanned == null) return;

    if (type == 'customer') {
      await _fetchCustomer(scanned);
    } else if (type == 'product_sold') {
      await _fetchProductSold(scanned.split(';')[0]);
    } else if (type == 'product_bought') {
      final data = {'barcode': scanned.split(';')[0]};
      // Ask if its broken or not
      final result = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isDismissible: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        builder: (context) {
          return StatefulBuilder(
            builder:
                (context, setModalState) => FormSheet(
                  title: 'Cari Produk Pembelian',
                  form: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Kondisi rusak ? ",
                        style: AppTextStyles.labelBlue,
                      ),
                      Checkbox(
                        value: isOpen,
                        onChanged: (value) {
                          setModalState(() {
                            isOpen = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  onOkPressed: () {
                    debugPrint('cari produk pressed 1');
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pop(context, {'isBroken': isOpen});
                    });
                  },
                  primaryColor: AppColors.success,
                ),
          );
        },
      );
      // data['isBroken'] = result;
      data['isBroken'] = result?['isBroken'] ?? false;
      await _fetchProductBought(data);
    } else if (type == 'operation') {
      await _fetchOperation(scanned.split(';')[1]);
    }
  }

  // Open Prompt to Insert Customer email
  Future<void> _showPromptCustomer() async {
    String scannedEmail = '';
    final scanned = await showModalBottomSheet(
      context: context,
      isDismissible: true, // Allows dismissing by tapping outside
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder:
          (context) => FormSheet(
            title: 'Cari Pelanggan',
            form: EmailForm(
              onChanged: (value) {
                scannedEmail = value; // Update email value
              },
            ),
            onOkPressed: () {
              Navigator.pop(context, scannedEmail);
            },
            primaryColor: AppColors.success,
          ),
    );
    if (scanned != null) {
      if (scannedEmail.isEmpty) {
        NotificationHelper.showNotificationSheet(
          context: context,
          title: "Gagal",
          message: "Email tidak valid",
          icon: Icons.error_outline,
          primaryColor: AppColors.error,
          primaryButtonText: "OK",
          onPrimaryPressed: () {},
        );
        return;
      }
      await _fetchCustomerByEmail(scannedEmail);
    }
  }

  // Open Prompt to Insert Product Barcode
  Future<void> _showPromptSold() async {
    String scannedBarcode = '';
    final scanned = await showModalBottomSheet(
      context: context,
      isDismissible: true, // Allows dismissing by tapping outside
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder:
          (context) => FormSheet(
            title: 'Cari Produk',
            form: TextForm(
              onChanged: (value) {
                scannedBarcode = value; // Update barcode value
              },
              label: 'Enter Barcode',
            ),
            onOkPressed: () {
              Navigator.pop(context, scannedBarcode);
            },
            primaryColor: AppColors.success,
          ),
    );
    if (scanned != null) {
      await _fetchProductSold(scanned);
    }
  }

  // Open Prompt to Insert Product Barcode
  Future<void> _showPromptBought() async {
    String scannedBarcode = '';
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isDismissible: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setModalState) => FormSheet(
                title: 'Cari Produk Pembelian',
                form: Column(
                  children: [
                    TextForm(
                      onChanged: (value) {
                        scannedBarcode = value;
                      },
                      label: 'Enter Barcode',
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Kondisi rusak ? ",
                          style: AppTextStyles.labelBlue,
                        ),
                        Checkbox(
                          value: isOpen,
                          onChanged: (value) {
                            setModalState(() {
                              isOpen = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                onOkPressed: () {
                  debugPrint('cari produk pressed 2');
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pop(context, {
                      'barcode': scannedBarcode,
                      'isBroken': isOpen,
                    });
                  });
                },
                primaryColor: AppColors.success,
              ),
        );
      },
    );
    if (result != null) {
      await _fetchProductBought(result);
    }
  }

  // Open Prompt to Insert Product Type, Weight and isBroken
  Future<void> _showPromptOutside() async {
    Map<String, dynamic> result = {};

    final cats = await CategoryAPI.fetchCategories(context);
    List<Map<String, dynamic>> categories =
        cats
            .map(
              (item) => {'id': item.id, 'value': '${item.code} - ${item.name}'},
            )
            .toList();

    String? selectedCategory;
    List<Map<String, dynamic>> filteredSubcategories = [];

    final res = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isDismissible: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setModalState) => FormSheet(
                title: 'Produk Pembelian dari Luar Toko',
                form: Column(
                  children: [
                    // Category Dropdown
                    SelectionForm(
                      label: 'Category',
                      options: categories,
                      onChanged: (value) {
                        selectedCategory = value;
                        result['category_id'] = value;
                        setModalState(() {
                          final data =
                              cats.firstWhere((cat) => cat.id == value).types;
                          if (data!.isNotEmpty) {
                            filteredSubcategories =
                                data
                                    .map(
                                      (item) => {
                                        'id': item.id,
                                        'value': '${item.code} - ${item.name}',
                                      },
                                    )
                                    .toList();
                          } else {
                            filteredSubcategories = [];
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Subcategory Dropdown
                    SelectionForm(
                      label: 'Subcategory',
                      options: filteredSubcategories,
                      onChanged: (value) {
                        result['type_id'] = value;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Weight
                    TextForm(
                      onChanged: (value) {
                        result['weight'] = value;
                      },
                      label: 'Enter Weight',
                    ),
                    const SizedBox(height: 12),

                    // Checkbox
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Kondisi rusak ? ",
                          style: AppTextStyles.labelBlue,
                        ),
                        Checkbox(
                          value: isOpen,
                          onChanged: (value) {
                            setModalState(() {
                              isOpen = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                onOkPressed: () {
                  Navigator.pop(context, {
                    'category_id': result['category_id'],
                    'type_id': result['type_id'],
                    'weight': result['weight'],
                    'isBroken': isOpen,
                  });
                },
                primaryColor: AppColors.success,
              ),
        );
      },
    );

    // result from modal
    if (res != null && res['type_id'] != null && res['weight'] != null) {
      await _fetchProductOutside(res);
    }
  }

  // Open Prompt to Insert Product Barcode
  Future<void> _showPromptOperation() async {
    String selectedOperation = '';
    List<Operation> ops = await OperationAPI.fetchOperations(context);
    final selected = await showModalBottomSheet(
      context: context,
      isDismissible: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder:
          (context) => FormSheet(
            title: 'Select Operation',
            form: SelectionForm(
              options:
                  ops
                      .map((item) => {'id': item.id, 'value': item.name})
                      .toList(), // Example options
              onChanged: (value) {
                selectedOperation = value;
              },
              label: 'Select Operation',
            ),
            onOkPressed: () {
              Navigator.pop(
                context,
                selectedOperation,
              ); // Return selected value
            },
            primaryColor: AppColors.success,
          ),
    );
    if (selected != null) {
      await _fetchOperation(selectedOperation);
    }
  }

  // Fetch Tax and config
  Future<void> _fetchConfig() async {
    // Fetch Config
    final res = await TransactionAPI.fetchConfig(context);
    setState(() {
      form['tax_percent'] =
          form['tax_percent'] ?? double.parse(res['tax_percentage']);
      config['tax_percent'] = double.parse(res['tax_percentage']);
      config['fixed_tt_adjustment'] =
          double.tryParse(res['fixed_tt_adjustment']) ?? 0.0;
      config['percent_tt_adjustment'] =
          double.tryParse(res['percent_tt_adjustment']) ?? 0.0;
      config['fixed_kbl_adjustment'] =
          double.tryParse(res['fixed_kbl_adjustment']) ?? 0.0;
      config['percent_kbl_adjustment'] =
          double.tryParse(res['percent_kbl_adjustment']) ?? 0.0;
    });
  }

  // Fetch Customer by ID
  Future<void> _fetchCustomer(String id) async {
    final cust = await CustomerAPI.fetchCustomer(context, id);
    if (cust != null) {
      setState(() {
        form['customer_id'] = cust.id;
        customer = cust;
      });
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Berhasil",
        message: "Customer ditemukan",
        icon: Icons.check_circle_outline,
        primaryColor: AppColors.success,
        primaryButtonText: "OK",
        onPrimaryPressed: () {},
      );
    }
  }

  // Fetch Customer by ID
  Future<void> _fetchCustomerByEmail(String email) async {
    final cust = await CustomerAPI.fetchCustomerByEmail(context, email);
    if (cust != null) {
      setState(() {
        form['customer_id'] = cust.id;
        customer = cust;
      });
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Berhasil",
        message: "Customer ditemukan",
        icon: Icons.check_circle_outline,
        primaryColor: AppColors.success,
        primaryButtonText: "OK",
        onPrimaryPressed: () {},
      );
    }
  }

  // Fetch Product by barcode
  Future<void> _fetchProductSold(String barcode) async {
    // Fetch Product sold by ID
    final prod = await ProductAPI.fetchProductCode(context, barcode);
    if (prod != null) {
      if (prod['status'] == 1) {
        NotificationHelper.showNotificationSheet(
          context: context,
          title: "Gagal",
          message: "Produk telah terjual",
          icon: Icons.error_outline,
          primaryColor: AppColors.error,
          primaryButtonText: "OK",
          onPrimaryPressed: () {},
        );
        return;
      }
      if (itemSold
          .where((element) => element.productCodeId == prod['id'])
          .isNotEmpty) {
        NotificationHelper.showNotificationSheet(
          context: context,
          title: "Gagal",
          message: "Produk sudah terdaftar",
          icon: Icons.error_outline,
          primaryColor: AppColors.error,
          primaryButtonText: "OK",
          onPrimaryPressed: () {},
        );
        return;
      }
      TransactionProduct tp = TransactionProduct(
        id: '',
        transactionId: '',
        productCodeId: prod['id'],
        transactionType: 1,
        name: prod['name'],
        price: double.parse(prod['price']),
        weight: double.parse(prod['weight']),
        type: prod['type'],
        adjustmentPrice: 0.0,
        totalPrice:
            (double.parse(prod['price']) * double.parse(prod['weight'])),
        status: 1,
        discount: 0.0,
      );
      setState(() {
        itemSold.add(tp);
        _calculate();
      });
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Berhasil",
        message: "Produk Berhasil didaftarkan",
        icon: Icons.check_circle_outline,
        primaryColor: AppColors.success,
        primaryButtonText: "OK",
        onPrimaryPressed: () {},
      );
    }
  }

  // Fetch Product by barcode
  Future<void> _fetchProductBought(Map<String, dynamic> result) async {
    // Fetch Product sold by ID
    final prod = await ProductAPI.fetchProductPurchase(
      context,
      result['barcode'],
      result['isBroken'],
    );
    if (prod != null) {
      if (prod['status'] != 1) {
        NotificationHelper.showNotificationSheet(
          context: context,
          title: "Gagal",
          message: "Produk tidak tersedia",
          icon: Icons.error_outline,
          primaryColor: AppColors.error,
          primaryButtonText: "OK",
          onPrimaryPressed: () {},
        );
        return;
      }
      if (itemSold
          .where((element) => element.productCodeId == prod['id'])
          .isNotEmpty) {
        NotificationHelper.showNotificationSheet(
          context: context,
          title: "Gagal",
          message: "Produk sudah terdaftar",
          icon: Icons.error_outline,
          primaryColor: AppColors.error,
          primaryButtonText: "OK",
          onPrimaryPressed: () {},
        );
        return;
      }
      TransactionProduct tp = TransactionProduct(
        id: '',
        transactionId: '',
        productCodeId: prod['id'],
        transactionType: 2,
        name: prod['name'],
        price: double.parse(prod['price'].toString()),
        weight: double.parse(prod['weight'].toString()),
        type: prod['type'],
        adjustmentPrice: double.parse(prod['adjustment_price'].toString()),
        totalPrice:
            (double.parse(prod['price'].toString()) *
                    double.parse(prod['weight'].toString()) +
                double.parse(prod['adjustment_price'].toString())) *
            -1,
        status: 1,
        discount: 0.0,
        isBroken: prod['is_broken'],
      );
      setState(() {
        itemBought.add(tp);
        _calculate();
      });
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Berhasil",
        message: "Produk berhasil didaftarkan",
        icon: Icons.check_circle_outline,
        primaryColor: AppColors.success,
        primaryButtonText: "OK",
        onPrimaryPressed: () {},
      );
    }
  }

  // Fetch Product Outside of the Store
  Future<void> _fetchProductOutside(Map<String, dynamic> result) async {
    final prod = await ProductAPI.fetchProductOutside(context, result);
    if (prod != null) {
      TransactionProduct tp = TransactionProduct(
        id: '',
        transactionId: '',
        productCodeId: prod['id'] ?? '',
        transactionType: 2,
        name: prod['name'],
        price: double.parse(prod['price'].toString()),
        weight: double.parse(prod['weight'].toString()),
        type: prod['type'],
        adjustmentPrice: double.parse(prod['adjustment_price'].toString()),
        totalPrice:
            (double.parse(prod['price'].toString()) *
                    double.parse(prod['weight'].toString()) +
                double.parse(prod['adjustment_price'].toString())) *
            -1,
        status: 1,
        discount: 0.0,
        isBroken: prod['is_broken'],
      );
      setState(() {
        itemBought.add(tp);
        _calculate();
      });
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Berhasil",
        message: "Produk dari luar toko berhasil didaftarkan",
        icon: Icons.check_circle_outline,
        primaryColor: AppColors.success,
        primaryButtonText: "OK",
        onPrimaryPressed: () {},
      );
    }
  }

  // Fetch Operation by ID
  Future<void> _fetchOperation(String id) async {
    // Fetch Operation by ID
    final op = await OperationAPI.fetchOperation(context, id);
    if (op != null) {
      TransactionOperation to = TransactionOperation(
        id: '',
        transactionId: '',
        operationId: op.id,
        name: '${op.code} - ${op.name}',
        unit: 1,
        price: op.price,
        type: 'Operation',
        adjustmentPrice: 0.0,
        totalPrice: op.price,
        comment: "",
      );
      setState(() {
        operations.add(to);
        _calculate();
      });
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Berhasil",
        message: "Operasi berhasil didaftarkan",
        icon: Icons.check_circle_outline,
        primaryColor: AppColors.success,
        primaryButtonText: "OK",
        onPrimaryPressed: () {},
      );
    }
  }

  // Fetch Accounts for tukar kurang TODOELLA
  Future<void> _fetchAccounts() async {
    debugPrint('fetching accounts...');
    final res = await AccountsApi.fetchAccountFromAPI(context, 
      accountTypeId: '1',
    );
    final accountSetting = await AccountsApi.fetchAccountSetting(context, 
      action: 'purchaseCust',
    );
    debugPrint('accountSetting: ${accountSetting.toString()}');
    setState(() {
      accounts = res;
      if (accountSetting.isNotEmpty ) {
        form['account_id'] = accountSetting[0].accountId;
      }
    });
  }

  void cancelProductSold(int index) {
    setState(() {
      itemSold.removeAt(index);
      _calculate();
    });
  }

  void cancelProductBought(int index) {
    setState(() {
      itemBought.removeAt(index);
      _calculate();
    });
  }

  void cancelOperation(int index) {
    setState(() {
      operations.removeAt(index);
      _calculate();
    });
  }

  void _calculate() {
    double bought = 0;
    double sold = 0;
    double tax = 0;

    for (final item in itemSold) {
      sold += item.totalPrice;
      tax += item.totalPrice * (config['tax_percent'] / 100);
    }
    for (final item in itemBought) {
      bought += item.totalPrice;
    }
    for (final item in operations) {
      sold += item.totalPrice;
      tax += item.totalPrice * (config['tax_percent'] / 100);
    }

    double adj = 0;
    double subtotal = sold + bought;
    if (widget.type == 3) {
      if (subtotal + tax >= 0) {
        adj =
            config['fixed_tt_adjustment'] ??
            (config['percent_tt_adjustment'] / 100) * subtotal;
      } else {
        adj =
            config['fixed_kbl_adjustment'] ??
            (config['percent_kbl_adjustment'] / 100) * subtotal;
      }
    }

    setState(() {
      form['sub_total_price'] = subtotal;
      form['tax_price'] = tax;
      form['adjustment_price'] = adj;
      form['total_price'] =
          subtotal + tax + adj; // Total Price = Subtotal + Tax + Adjustment
      form['paid_amount'] = form['total_price'];
    });
  }

  Future<void> _submit() async {
    // Submit Transaction
    form['transaction_products'] = [
      ...itemSold.map((item) => TransactionProduct.toJSON(item)),
      ...itemBought.map((item) => TransactionProduct.toJSON(item)),
    ];
    form['transaction_operations'] = [
      ...operations.map((item) => TransactionOperation.toJSON(item)),
    ];
    debugPrint('form: ${form.toString()}');
    final response = await TransactionAPI.submitTransaction(context, form);
    debugPrint(response.toString());
    if (response) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Berhasil",
        message: "Transaksi berhasil disimpan",
        icon: Icons.check_circle_outline,
        primaryColor: AppColors.success,
        primaryButtonText: "OK",
        onPrimaryPressed: () {
          Provider.of<SalesNotifier>(context, listen: false).markForRefresh();
          context.pop();
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Init Date
    dateController.text = "${form['date'].toLocal()}".split(' ')[0];
    form['transaction_type'] = widget.type;
    _fetchConfig();
    _fetchAccounts();
    debugPrint('transaction type: ${widget.type}');
    // Initialize items Details
    // itemSold =
    //     widget.transaction.transactionProducts
    //         .where((item) => item.transactionType == 1)
    //         .toList();
    // itemBought =
    //     widget.transaction.transactionProducts
    //         .where((item) => item.transactionType == 2)
    //         .toList();
    // operations = widget.transaction.transactionOperations;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text("Transaksi Baru", style: AppTextStyles.headingWhite),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Row(children: []),
                  Card(
                    color: Colors.white,
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 6,
                        children: [
                          Text(
                            "Detail Transaksi",
                            style: AppTextStyles.headingBlue,
                          ),
                          Divider(),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              controller: dateController,
                              readOnly: true, // Prevent manual input
                              decoration: InputDecoration(
                                icon: Icon(Icons.calendar_today),
                                labelText: "Tanggal Transaksi",
                              ),
                              onTap: () => _selectDate(context),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: 
                            (form['total_price'] ?? 0) >= 0 ? 
                            DropdownButtonFormField( // if tukar tambah
                              decoration: InputDecoration(
                                icon: Icon(Icons.payment),
                                labelText: "Jenis Pembayaran",
                              ),
                              value: form['payment_method'],
                              onChanged: (value) {
                                setState(() {
                                  form['payment_method'] = value;
                                });
                              },
                              items:
                                  paymentMethod
                                      .map(
                                        (item) => DropdownMenuItem(
                                          value: item['id'],
                                          child: Text(item['value']),
                                        ),
                                      )
                                      .toList(),
                            ) :
                            (form['status'] != 1) ? 
                             DropdownButtonFormField( // if tukar kurang (store bayar customer pakai apa)
                              isExpanded: true,
                              decoration: InputDecoration(
                                icon: Icon(Icons.payment),
                                labelText: "Account Pembayaran",
                              ),
                              value: form['account_id'],
                              onChanged: (value) {
                                setState(() {
                                  form['account_id'] = value;
                                });
                              },
                              items:
                                  accounts
                                      .map(
                                        (item) => DropdownMenuItem(
                                          value: item.id,
                                          child: Text('${item.code} - ${item.name}',         overflow: TextOverflow.ellipsis,),
                                        ),
                                      )
                                      .toList(),
                            )   : null
                            ,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonFormField(
                              decoration: InputDecoration(
                                icon: Icon(Icons.shopping_cart),
                                labelText: "Status",
                              ),
                              value: form['status'],
                              onChanged: (value) {
                                setState(() {
                                  form['status'] = value;
                                });
                              },
                              items:
                                  statuses
                                      .map(
                                        (item) => DropdownMenuItem(
                                          value: item['id'],
                                          child: Text(item['value']),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.white,
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Text(
                            "Detail Pelanggan",
                            style: AppTextStyles.headingBlue,
                          ),
                          Divider(),
                          TextCardDetail(
                            label: "Nama",
                            value: customer?.name ?? "-",
                            type: "text",
                          ),
                          TextCardDetail(
                            label: "Email",
                            value: customer?.email ?? "-",
                            type: "text",
                          ),
                          TextCardDetail(
                            label: "No Telepon",
                            value: customer?.phone ?? "-",
                            type: "text",
                          ),
                          Divider(),

                          InkWell(
                            onTap: () async {
                              // Scan QR Code to get customer ID
                              _qrScan('customer');
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Container(
                                width: double.infinity,
                                color: AppColors.pinkPrimary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Scan QR Customer",
                                  style: AppTextStyles.labelWhite,
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              // Scan QR Code to get customer ID
                              _showPromptCustomer();
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Container(
                                width: double.infinity,
                                color: AppColors.bluePrimary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Cari Email Customer",
                                  style: AppTextStyles.labelWhite,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (widget.type == 1 || widget.type == 3)
                    TransactionProductSection(
                      title: "Detail Penjualan",
                      products: itemSold,
                      totalWeight: itemSold.fold(
                        0.0,
                        (previousValue, element) =>
                            previousValue + element.weight,
                      ),
                      totalPrice: itemSold.fold(
                        0.0,
                        (previousValue, element) =>
                            previousValue + element.totalPrice,
                      ),
                      onRemove: (index) => cancelProductSold(index),
                      readonly: false,
                    ),
                  if (widget.type == 1 || widget.type == 3)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Row(
                        spacing: 12,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                // Scan QR penjualan Produk
                                _qrScan('product_sold');
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.pinkPrimary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.qr_code, color: Colors.white),
                                    Text(
                                      "Scan QR\nPenjualan produk",
                                      style: AppTextStyles.labelWhite,
                                      softWrap: true,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                // Search by notificationSheet penjualan Produk
                                _showPromptSold();
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.bluePrimary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.search, color: Colors.white),
                                    Text(
                                      "Pencarian\nPenjualan produk",
                                      style: AppTextStyles.labelWhite,
                                      softWrap: true,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (widget.type == 2 || widget.type == 3)
                    TransactionProductSection(
                      title: "Detail Pembelian",
                      products: itemBought,
                      totalWeight: itemBought.fold(
                        0.0,
                        (previousValue, element) =>
                            previousValue + element.weight,
                      ),
                      totalPrice: itemBought.fold(
                        0.0,
                        (previousValue, element) =>
                            previousValue + element.totalPrice,
                      ),
                      onRemove: (index) => cancelProductBought(index),
                      readonly: false,
                    ),
                  if (widget.type == 2 || widget.type == 3)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Row(
                        spacing: 12,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                // Scan QR pembelian Produk
                                _qrScan('product_bought');
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.pinkPrimary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.qr_code, color: Colors.white),
                                    Text(
                                      "Scan QR\nPembelian produk",
                                      style: AppTextStyles.labelWhite,
                                      softWrap: true,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (widget.type == 2 || widget.type == 3)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Row(
                        spacing: 12,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                // Scan QR pembelian Produk
                                _showPromptOutside();
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.bluePrimary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.search, color: Colors.white),
                                    Text(
                                      "Pembelian produk\nDari luar toko",
                                      style: AppTextStyles.labelWhite,
                                      softWrap: true,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                // Search by notificationSheet penjualan Produk
                                _showPromptBought();
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.bluePrimary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.search, color: Colors.white),
                                    Text(
                                      "Pembelian produk\nMilik Toko",
                                      style: AppTextStyles.labelWhite,
                                      softWrap: true,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (widget.type == 1 || widget.type == 3)
                    TransactionOperationSection(
                      title: "Detail Jasa",
                      operations: operations,
                      totalPrice: operations.fold(
                        0.0,
                        (previousValue, element) =>
                            previousValue + element.totalPrice,
                      ),
                      onRemove: (index) => cancelOperation(index),
                      readonly: false,
                    ),
                  if (widget.type == 1 || widget.type == 3)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Row(
                        spacing: 12,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                // Scan QR Jasa
                                _qrScan('operation');
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.pinkPrimary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.qr_code, color: Colors.white),
                                    Text(
                                      "Scan QR Jasa",
                                      style: AppTextStyles.labelWhite,
                                      softWrap: true,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                // Search by notificationSheet pencarian JASA
                                _showPromptOperation();
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.bluePrimary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.search, color: Colors.white),
                                    Text(
                                      "Pencarian Jasa",
                                      style: AppTextStyles.labelWhite,
                                      softWrap: true,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Card(
                    color: Colors.white,
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 20.0,
                      ),
                      child: Column(
                        spacing: 6,
                        children: [
                          TextCardDetail(
                            label: "Subtotal",
                            value: form['sub_total_price'],
                            type: "currency",
                            textStyle: AppTextStyles.labelPink,
                          ),
                          if (form['transaction_type'] != 2)
                            TextCardDetail(
                              label: "Pajak",
                              value: form['tax_price'],
                              type: "currency",
                              textStyle: AppTextStyles.labelPink,
                            ),
                          if (form['transaction_type'] == 3)
                            TextCardDetail(
                              label: "Biaya Tukar Tambah",
                              value: form['adjustment_price'],
                              type: "currency",
                              textStyle: AppTextStyles.labelPink,
                            ),
                          Divider(),
                          TextCardDetail(
                            label: "Total",
                            value: form['total_price'],
                            type: "currency",
                            textStyle: AppTextStyles.labelPink,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 20.0,
                    ),
                    child: InkWell(
                      onTap: () {
                        // Scan QR Code to get customer ID
                        debugPrint(form.toString());
                        _submit();
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Container(
                          width: double.infinity,
                          color: AppColors.pinkPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          alignment: Alignment.center,
                          child: Text(
                            "Save",
                            style: AppTextStyles.headingWhite,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
