import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:operational_app/api/accounts.dart';
import 'package:operational_app/api/category.dart';
import 'package:operational_app/api/operation.dart';
import 'package:operational_app/api/product.dart';
import 'package:operational_app/api/transaction.dart';
import 'package:operational_app/bloc/auth_bloc.dart';
import 'package:operational_app/helper/notification.dart';
import 'package:operational_app/model/account.dart';
import 'package:operational_app/model/customer.dart';
import 'package:operational_app/model/operation.dart';
import 'package:operational_app/model/transaction.dart';
import 'package:operational_app/model/transaction_operation.dart';
import 'package:operational_app/model/transaction_product.dart';
import 'package:operational_app/notifier/detail_notifier.dart';
import 'package:operational_app/notifier/sales_notifier.dart';
import 'package:operational_app/screen/qr_scanner_screen.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/form_sheet.dart';
import 'package:operational_app/widget/selection_form.dart';
import 'package:operational_app/widget/text_form.dart';
import 'package:operational_app/widget/text_card_detail.dart';
import 'package:operational_app/widget/transaction_operation_section.dart';
import 'package:operational_app/widget/transaction_product_section.dart';
import 'package:provider/provider.dart';

class TransactionEditScreen extends StatefulWidget {
  final Transaction transaction;
  const TransactionEditScreen({super.key, required this.transaction});

  @override
  State<TransactionEditScreen> createState() => _TransactionEditScreenState();
}

class _TransactionEditScreenState extends State<TransactionEditScreen> {
  // DatePicker Functionality
  final TextEditingController dateController = TextEditingController();
  // Transaction Details
  List<TransactionProduct> itemSold = [];
  List<TransactionProduct> itemBought = [];
  List<TransactionOperation> operations = [];
  bool isFlex = false;

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
    {"id": 0, "value": "Belum Lunas"},
    {"id": 1, "value": "Lunas"},
    {"id": 2, "value": "Selesai"},
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
    'account_id': null,
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

    if (type == 'product_sold') {
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
      isFlex = res['is_flex_price'] || context.read<AuthCubit>().state.isOwner;
    });
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
        transactionId: widget.transaction.id,
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
      // Called to create the new transaction detail
      Map<String, dynamic> insert = {
        'transaction_id': widget.transaction.id,
        'detail_type': 'product',
        'product_code_id': tp.productCodeId,
        'type': tp.type,
        'name': tp.name,
        'price': tp.price,
        'quantity': tp.weight,
        'weight': tp.weight,
        'uom': 'gram',
        'adjustment_price': 0.0,
        'total_price': tp.totalPrice,
        'transaction_type': 1,
        'discount': 0,
      };
      final result = await TransactionAPI.createTransactionDetail(
        context,
        insert,
      );
      if (result['success']) {
        tp.id = result['data']['id'] ?? '';
        setState(() {
          itemSold.add(tp);
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
      } else {
        NotificationHelper.showNotificationSheet(
          context: context,
          title: "Gagal",
          message: "Operasi Gagal Didaftarkan",
          icon: Icons.error_outline,
          primaryColor: AppColors.error,
          primaryButtonText: "OK",
          onPrimaryPressed: () {},
        );
      }
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
      if (itemBought
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
        transactionId: widget.transaction.id,
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
      // Called to create the new transaction detail
      Map<String, dynamic> insert = {
        'transaction_id': widget.transaction.id,
        'detail_type': 'product',
        'product_code_id': tp.productCodeId,
        'type': tp.type,
        'name': tp.name,
        'price': tp.price,
        'quantity': tp.weight,
        'weight': tp.weight,
        'uom': 'gram',
        'adjustment_price': 0.0,
        'total_price': tp.totalPrice,
        'transaction_type': 2,
        'discount': 0,
        'is_broken': tp.isBroken,
      };
      final result = await TransactionAPI.createTransactionDetail(
        context,
        insert,
      );
      if (result['success']) {
        tp.id = result['data']['id'] ?? '';
        setState(() {
          itemBought.add(tp);
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
      } else {
        NotificationHelper.showNotificationSheet(
          context: context,
          title: "Gagal",
          message: "Operasi Gagal Didaftarkan",
          icon: Icons.error_outline,
          primaryColor: AppColors.error,
          primaryButtonText: "OK",
          onPrimaryPressed: () {},
        );
      }
    }
  }

  // Fetch Product Outside of the Store
  Future<void> _fetchProductOutside(Map<String, dynamic> result) async {
    final prod = await ProductAPI.fetchProductOutside(context, result);
    if (prod != null) {
      TransactionProduct tp = TransactionProduct(
        id: '',
        transactionId: widget.transaction.id,
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
      // Called to create the new transaction detail
      Map<String, dynamic> insert = {
        'transaction_id': widget.transaction.id,
        'detail_type': 'product',
        'product_code_id': null,
        'type': tp.type,
        'name': tp.name,
        'price': tp.price,
        'quantity': tp.weight,
        'weight': tp.weight,
        'uom': 'gram',
        'adjustment_price': 0.0,
        'total_price': tp.totalPrice,
        'transaction_type': 2,
        'discount': 0,
        'is_broken': tp.isBroken,
      };
      final result = await TransactionAPI.createTransactionDetail(
        context,
        insert,
      );
      if (result['success']) {
        tp.id = result['data']['id'] ?? '';
        setState(() {
          itemBought.add(tp);
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
      } else {
        NotificationHelper.showNotificationSheet(
          context: context,
          title: "Gagal",
          message: "Operasi Gagal Didaftarkan",
          icon: Icons.error_outline,
          primaryColor: AppColors.error,
          primaryButtonText: "OK",
          onPrimaryPressed: () {},
        );
      }
    }
  }

  // Fetch Operation by ID
  Future<void> _fetchOperation(String id) async {
    // Fetch Operation by ID
    final op = await OperationAPI.fetchOperation(context, id);
    if (op != null) {
      TransactionOperation to = TransactionOperation(
        id: '',
        transactionId: widget.transaction.id,
        operationId: op.id,
        name: '${op.code} - ${op.name}',
        unit: 1,
        price: op.price,
        type: 'Operation',
        adjustmentPrice: 0.0,
        totalPrice: op.price,
        comment: "",
      );
      // Insert new Transaction Details
      Map<String, dynamic> insert = {
        'transaction_id': widget.transaction.id,
        'detail_type': 'operation',
        'operation_id': op.id,
        'type': 'Operation',
        'name': '${op.code} - ${op.name}',
        'price': op.price,
        'quantity': 1,
        'unit': 1,
        'uom': op.uom,
        'adjustment_price': 0.0,
        'total_price': op.price,
        'transaction_type': 1,
      };
      final result = await TransactionAPI.createTransactionDetail(
        context,
        insert,
      );
      if (result['success']) {
        to.id = result['data']['id'] ?? '';
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
      } else {
        NotificationHelper.showNotificationSheet(
          context: context,
          title: "Gagal",
          message: "Operasi Gagal Didaftarkan",
          icon: Icons.error_outline,
          primaryColor: AppColors.error,
          primaryButtonText: "OK",
          onPrimaryPressed: () {},
        );
      }
    }
  }

  // Fetch Accounts for tukar kurang TODOELLA
  Future<void> _fetchAccounts() async {
    debugPrint('fetching accounts...');
    final res = await AccountsApi.fetchAccountFromAPI(
      context,
      accountTypeId: '1',
    );
    final accountSetting = await AccountsApi.fetchAccountSetting(
      context,
      action: 'purchaseCust',
    );
    debugPrint('accountSetting: ${accountSetting.toString()}');
    setState(() {
      accounts = res;
      if (accountSetting.isNotEmpty) {
        form['account_id'] = accountSetting[0].accountId;
      }
    });
  }

  void cancelProductSold(int index) async {
    // Delete the transaction Detail
    final id = itemSold[index].id;
    final res = await TransactionAPI.deleteTransactionDetail(context, id);
    if (res) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Sukses",
        message: "Produk berhasil dihapus",
        icon: Icons.check_circle_outline,
        primaryColor: AppColors.success,
        primaryButtonText: "OK",
        onPrimaryPressed: () {},
      );
      setState(() {
        itemSold.removeAt(index);
        _calculate();
      });
    } else {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal",
        message:
            "Gagal menghapus produk, karena telah digunakan pada transaksi lain.",
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
        primaryButtonText: "OK",
        onPrimaryPressed: () {},
      );
    }
  }

  void cancelProductBought(int index) async {
    // Delete the transaction Detail
    final id = itemBought[index].id;
    final res = await TransactionAPI.deleteTransactionDetail(context, id);
    if (res) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Sukses",
        message: "Produk berhasil dihapus",
        icon: Icons.check_circle_outline,
        primaryColor: AppColors.success,
        primaryButtonText: "OK",
        onPrimaryPressed: () {},
      );
      setState(() {
        itemBought.removeAt(index);
        _calculate();
      });
    } else {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal",
        message:
            "Gagal menghapus produk, karena telah digunakan pada transaksi lain.",
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
        primaryButtonText: "OK",
        onPrimaryPressed: () {},
      );
    }
  }

  void cancelOperation(int index) async {
    // Delete the transaction Detail
    final id = operations[index].id;
    final res = await TransactionAPI.deleteTransactionDetail(context, id);
    if (res) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Sukses",
        message: "Operasi berhasil dihapus",
        icon: Icons.check_circle_outline,
        primaryColor: AppColors.success,
        primaryButtonText: "OK",
        onPrimaryPressed: () {},
      );
      setState(() {
        operations.removeAt(index);
        _calculate();
      });
    } else {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal",
        message: "Gagal menghapus operasi.",
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
        primaryButtonText: "OK",
        onPrimaryPressed: () {},
      );
    }
  }

  Future<void> _showPromptSoldEdit(int index) async {
    String adjusted = itemSold[index].adjustmentPrice.toString();
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isDismissible: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setModalState) => FormSheet(
                title: 'Sunting Produk Penjualan',
                form: Column(
                  children: [
                    TextForm(
                      onChanged: (value) {
                        adjusted = value;
                      },
                      label: 'Penyesuaian Harga',
                      initialValue: itemSold[index].adjustmentPrice.toString(),
                      isNumber: true,
                    ),
                  ],
                ),
                onOkPressed: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pop(context, {'adjusted': adjusted});
                  });
                },
                primaryColor: AppColors.success,
              ),
        );
      },
    );
    if (result != null) {
      // Update it to the backend
      Map<String, dynamic> map = TransactionProduct.toJSON(itemSold[index]);
      map['adjustment_price'] = double.tryParse(result['adjusted']) ?? 0.0;
      map['total_price'] =
          (itemSold[index].price * itemSold[index].weight) +
          itemSold[index].adjustmentPrice;
      debugPrint('Map Editted ${map['id']}');
      final response = await TransactionAPI.updateTransactionDetail(
        context,
        map['id'],
        map,
      );
      if (response) {
        NotificationHelper.showNotificationSheet(
          context: context,
          title: "Sukses",
          message: "Berhasil melakukan perubahan.",
          icon: Icons.check_circle_outline,
          primaryColor: AppColors.success,
          primaryButtonText: "OK",
          onPrimaryPressed: () {},
        );
        setState(() {
          itemSold[index].adjustmentPrice =
              double.tryParse(result['adjusted']) ?? 0.0;
          itemSold[index].totalPrice =
              (itemSold[index].price * itemSold[index].weight) +
              itemSold[index].adjustmentPrice;
          _calculate();
        });
      }
    }
  }

  Future<void> _showPromptBoughtEdit(int index) async {
    String adjusted = itemBought[index].adjustmentPrice.toString();
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isDismissible: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setModalState) => FormSheet(
                title: 'Sunting Produk Pembelian',
                form: Column(
                  children: [
                    TextForm(
                      onChanged: (value) {
                        adjusted = value;
                      },
                      initialValue:
                          itemBought[index].adjustmentPrice.toString(),
                      label: 'Penyesuaian Harga',
                      isNumber: true,
                    ),
                  ],
                ),
                onOkPressed: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pop(context, {'adjusted': adjusted});
                  });
                },
                primaryColor: AppColors.success,
              ),
        );
      },
    );
    if (result != null) {
      Map<String, dynamic> map = TransactionProduct.toJSON(itemBought[index]);
      map['adjustment_price'] = double.tryParse(result['adjusted']) ?? 0.0;
      map['total_price'] =
          (itemBought[index].price * itemBought[index].weight) +
          itemBought[index].adjustmentPrice;

      final response = await TransactionAPI.updateTransactionDetail(
        context,
        map['id'],
        map,
      );
      if (response) {
        NotificationHelper.showNotificationSheet(
          context: context,
          title: "Sukses",
          message: "Berhasil melakukan perubahan.",
          icon: Icons.check_circle_outline,
          primaryColor: AppColors.success,
          primaryButtonText: "OK",
          onPrimaryPressed: () {},
        );
        setState(() {
          itemBought[index].adjustmentPrice =
              double.tryParse(result['adjusted']) ?? 0.0;
          itemBought[index].totalPrice =
              ((itemBought[index].price * itemBought[index].weight) +
                  itemBought[index].adjustmentPrice) *
              -1;
          _calculate();
        });
      }
    }
  }

  Future<void> _showPromptOperationEdit(int index) async {
    String adjusted = operations[index].adjustmentPrice.toString();
    String jumlah = operations[index].unit.toString();
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isDismissible: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setModalState) => FormSheet(
                title: 'Sunting Operasi',
                form: Column(
                  spacing: 8,
                  children: [
                    TextForm(
                      onChanged: (value) {
                        jumlah = value;
                      },
                      label: 'Jumlah',
                      initialValue: operations[index].unit.toString(),
                      isNumber: true,
                    ),
                    TextForm(
                      onChanged: (value) {
                        adjusted = value;
                      },
                      label: 'Penyesuaian Harga',
                      initialValue:
                          operations[index].adjustmentPrice.toString(),
                      isNumber: true,
                    ),
                  ],
                ),
                onOkPressed: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pop(context, {
                      'jumlah': jumlah,
                      'adjusted': adjusted,
                    });
                  });
                },
                primaryColor: AppColors.success,
              ),
        );
      },
    );
    if (result != null) {
      Map<String, dynamic> map = TransactionOperation.toJSON(operations[index]);
      map['adjustment_price'] = double.tryParse(result['adjusted']) ?? 0.0;
      map['total_price'] =
          (operations[index].price * operations[index].unit) +
          operations[index].adjustmentPrice;

      final response = await TransactionAPI.updateTransactionDetail(
        context,
        map['id'],
        map,
      );
      if (response) {
        NotificationHelper.showNotificationSheet(
          context: context,
          title: "Sukses",
          message: "Berhasil melakukan perubahan.",
          icon: Icons.check_circle_outline,
          primaryColor: AppColors.success,
          primaryButtonText: "OK",
          onPrimaryPressed: () {},
        );
        setState(() {
          operations[index].unit = double.tryParse(result['jumlah']) ?? 0.0;
          operations[index].adjustmentPrice =
              double.tryParse(result['adjusted']) ?? 0.0;
          operations[index].totalPrice =
              (operations[index].price * operations[index].unit) +
              operations[index].adjustmentPrice;
          _calculate();
        });
      }
    }
  }

  Future<void> _showPromptEditFinal() async {
    String tax = form['tax_percent'].toString();
    String adj = form['adjustment_price'].toString();
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isDismissible: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setModalState) => FormSheet(
                title: 'Sunting Final Value',
                form: Column(
                  spacing: 8,
                  children: [
                    TextForm(
                      onChanged: (value) {
                        tax = value;
                      },
                      label: 'Pajak',
                      initialValue: form['tax_percent'].toString(),
                      isNumber: true,
                    ),
                    if (widget.transaction.transactionType == 3) // Tukar Tambah
                      TextForm(
                        onChanged: (value) {
                          adj = value;
                        },
                        label: 'Beban Tukar Tambah',
                        initialValue: form['adjustment_price'].toString(),
                        isNumber: true,
                      ),
                  ],
                ),
                onOkPressed: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pop(context, {'tax': tax, 'adj': adj});
                  });
                },
                primaryColor: AppColors.success,
              ),
        );
      },
    );
    if (result != null) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Sukses",
        message: "Berhasil melakukan perubahan.",
        icon: Icons.check_circle_outline,
        primaryColor: AppColors.success,
        primaryButtonText: "OK",
        onPrimaryPressed: () {},
      );
      setState(() {
        form['tax_percent'] = double.tryParse(result['tax']) ?? 0.0;
        config['tax_percent'] = double.tryParse(result['tax']) ?? 0.0;
        form['adjustment_price'] = double.tryParse(result['adj']) ?? 0.0;
        _calculate();
      });
    }
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
    if (widget.transaction.transactionType == 3) {
      if (subtotal >= 0) {
        adj =
            config['fixed_tt_adjustment'] > 0
                ? config['fixed_tt_adjustment']
                : (config['percent_tt_adjustment'] / 100) * subtotal;
      } else {
        adj =
            (config['fixed_kbl_adjustment'] > 0
                ? config['fixed_kbl_adjustment']
                : (config['percent_kbl_adjustment'] / 100) * subtotal) *
            -1;
      }
    }

    tax += adj * (config['tax_percent'] / 100);

    setState(() {
      form['sub_total_price'] = subtotal;
      form['tax_price'] = tax;
      form['adjustment_price'] = adj;
      form['total_price'] =
          subtotal + tax + adj; // Total Price = Subtotal + Tax + Adjustment
      form['paid_amount'] = form['total_price'];
    });
    // Update Detail Transaksi
    Provider.of<DetailNotifier>(context, listen: false).markForRefresh();
    Provider.of<SalesNotifier>(context, listen: false).markForRefresh();
  }

  Future<void> _submit() async {
    // Submit Transaction
    form['transaction_details'] = [
      ...itemSold.map((item) => TransactionProduct.toJSON(item)),
      ...itemBought.map((item) => TransactionProduct.toJSON(item)),
      ...operations.map((item) => TransactionOperation.toJSON(item)),
    ];
    debugPrint('form: ${form.toString()}');
    final response = await TransactionAPI.updateTransaction(
      context,
      widget.transaction.id,
      form,
    );
    debugPrint(response.toString());
    if (response) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Berhasil",
        message: "Transaksi berhasil diperbarui.",
        icon: Icons.check_circle_outline,
        primaryColor: AppColors.success,
        primaryButtonText: "OK",
        onPrimaryPressed: () {
          Provider.of<DetailNotifier>(context, listen: false).markForRefresh();
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
    form = {
      'date': widget.transaction.date,
      'customer_id': widget.transaction.customer?.id,
      'payment_method': widget.transaction.paymentMethod,
      'status': widget.transaction.status,
      'sub_total_price': widget.transaction.subTotalPrice,
      'tax_price': widget.transaction.taxPrice,
      'adjustment_price': widget.transaction.adjustmentPrice,
      'total_price': widget.transaction.totalPrice,
      'paid_amount': widget.transaction.paidAmount,
      'transaction_type': widget.transaction.transactionType,
      'account_id': widget.transaction.accountId,
      'employee_id': widget.transaction.employee?.id ?? '',
      'store_id': widget.transaction.storeId,
    };

    itemBought =
        widget.transaction.transactionProducts
            .where((item) => item.transactionType == 2)
            .toList();
    itemSold =
        widget.transaction.transactionProducts
            .where((item) => item.transactionType == 1)
            .toList();
    operations = widget.transaction.transactionOperations;
    dateController.text = "${form['date'].toLocal()}".split(' ')[0];
    customer = widget.transaction.customer;

    _fetchConfig();
    _fetchAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(
              "${widget.transaction.code}",
              style: AppTextStyles.headingWhite,
            ),
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
                          TextCardDetail(
                            label: "Kode Transaksi",
                            value: widget.transaction.code,
                            type: "text",
                          ),
                          TextCardDetail(
                            label: 'Tanggal',
                            value: form['date'],
                            type: "date",
                          ),
                          TextCardDetail(
                            label: "Jenis",
                            value:
                                transactionType
                                    .where(
                                      (trans) =>
                                          trans['id'] ==
                                          widget.transaction.transactionType,
                                    )
                                    .first['value'],
                            type: "text",
                          ),
                          TextCardDetail(
                            label: "Sales",
                            value: widget.transaction.employee?.name ?? "-",
                            type: "text",
                          ),
                          TextCardDetail(
                            label: "Customer",
                            value: customer?.name ?? "-",
                            type: "text",
                          ),
                          TextCardDetail(
                            label: "Customer Email",
                            value: customer?.email ?? "-",
                            type: "text",
                          ),
                          Divider(),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child:
                                (form['total_price'] ?? 0) >= 0
                                    ? DropdownButtonFormField(
                                      // if tukar tambah
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
                                    )
                                    : ((form['status'] == 1 ||
                                            form['status'] == 2) &&
                                        form['total_price'] > 0)
                                    ? DropdownButtonFormField(
                                      // if tukar kurang (store bayar customer pakai apa)
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
                                                  child: Text(
                                                    '${item.code} - ${item.name}',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                    )
                                    : null,
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
                  if (widget.transaction.transactionType == 1 ||
                      widget.transaction.transactionType == 3)
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
                      onEdit: (index) => _showPromptSoldEdit(index),
                      readonly: false,
                      isFlex: isFlex,
                    ),
                  if (widget.transaction.transactionType == 1 ||
                      widget.transaction.transactionType == 3)
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
                  if (widget.transaction.transactionType == 2 ||
                      widget.transaction.transactionType == 3)
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
                      onEdit: (index) => _showPromptBoughtEdit(index),
                      readonly: false,
                      isFlex: isFlex,
                    ),
                  if (widget.transaction.transactionType == 2 ||
                      widget.transaction.transactionType == 3)
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
                  if (widget.transaction.transactionType == 2 ||
                      widget.transaction.transactionType == 3)
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

                  if (widget.transaction.transactionType == 1 ||
                      widget.transaction.transactionType == 3)
                    TransactionOperationSection(
                      title: "Detail Jasa",
                      operations: operations,
                      totalPrice: operations.fold(
                        0.0,
                        (previousValue, element) =>
                            previousValue + element.totalPrice,
                      ),
                      onRemove: (index) => cancelOperation(index),
                      onEdit: (index) => _showPromptOperationEdit(index),
                      readonly: false,
                      isFlex: isFlex,
                    ),
                  if (widget.transaction.transactionType == 1 ||
                      widget.transaction.transactionType == 3)
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
                          Row(
                            children: [
                              Text(
                                "Detail Akhir Transaksi",
                                style: AppTextStyles.headingBlue,
                              ),
                              Spacer(),
                              if (isFlex &&
                                  widget.transaction.transactionType != 2)
                                InkWell(
                                  onTap: _showPromptEditFinal,
                                  borderRadius: BorderRadius.circular(
                                    8,
                                  ), // Optional: for ripple effect
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        color: AppColors.bluePrimary,
                                        size: 20,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "Edit",
                                        style: AppTextStyles.labelBlueItalic,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          Divider(),
                          TextCardDetail(
                            label: "Subtotal",
                            value: form['sub_total_price'],
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
                          if (form['transaction_type'] != 2)
                            TextCardDetail(
                              label: "Pajak (${config['tax_percent']}%)",
                              value: form['tax_price'],
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
