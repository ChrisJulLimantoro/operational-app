import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:operational_app/api/customer.dart';
import 'package:operational_app/api/operation.dart';
import 'package:operational_app/api/product.dart';
import 'package:operational_app/api/transaction.dart';
import 'package:operational_app/helper/notification.dart';
import 'package:operational_app/model/customer.dart';
import 'package:operational_app/model/operation.dart';
import 'package:operational_app/model/transaction_operation.dart';
import 'package:operational_app/model/transaction_product.dart';
import 'package:operational_app/screen/qr_scanner_screen.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/email_form.dart';
import 'package:operational_app/widget/form_sheet.dart';
import 'package:operational_app/widget/operation_selection_form.dart';
import 'package:operational_app/widget/text_form.dart';
import 'package:operational_app/widget/text_card_detail.dart';
import 'package:operational_app/widget/transaction_operation_section.dart';
import 'package:operational_app/widget/transaction_product_section.dart';

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
    'total_price': 0.0,
    'paid_amount': 0.0,
    'transaction_type': 1,
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
      await _fetchProductBought(scanned.split(';')[0]);
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
  Future<void> _showPromptOperation() async {
    String selectedOperation = '';
    List<Operation> ops = await OperationAPI.fetchOperations(context, 0, 0);
    final selected = await showModalBottomSheet(
      context: context,
      isDismissible: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder:
          (context) => FormSheet(
            title: 'Select Operation',
            form: OperationSelectionForm(
              options:
                  ops
                      .map((item) => {'id': item.id, 'value': item.name})
                      .toList(), // Example options
              onChanged: (value) {
                selectedOperation = value;
              },
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
        form['sub_total_price'] = form['sub_total_price'] + tp.totalPrice;
        form['tax_price'] = form['sub_total_price'] * 0.1;
        form['total_price'] = form['sub_total_price'] + form['tax_price'];
        form['paid_amount'] =
            form['total_price']; //assume paid amount is total price
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
  Future<void> _fetchProductBought(String barcode) async {}

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
        form['sub_total_price'] = form['sub_total_price'] + to.totalPrice;
        form['tax_price'] = form['sub_total_price'] * 0.1;
        form['total_price'] = form['sub_total_price'] + form['tax_price'];
        form['paid_amount'] = form['total_price'];
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

  Future<void> _submit() async {
    // Submit Transaction
    form['transaction_details'] = [
      ...itemSold.map((item) => TransactionProduct.toJSON(item)),
      ...itemBought.map((item) => TransactionProduct.toJSON(item)),
      ...operations.map((item) => TransactionOperation.toJSON(item)),
    ];
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
          GoRouter.of(context).go('/transaction');
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Init Date
    dateController.text = "${form['date'].toLocal()}".split(' ')[0];

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
                            child: DropdownButtonFormField(
                              decoration: InputDecoration(
                                icon: Icon(Icons.shop),
                                labelText: "Jenis Transaksi",
                              ),
                              value: form['transaction_type'],
                              onChanged: (value) {
                                setState(() {
                                  form['transaction_type'] = value;
                                });
                              },
                              items:
                                  transactionType
                                      .map(
                                        (item) => DropdownMenuItem(
                                          value: item['id'],
                                          child: Text(item['value']),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonFormField(
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
                            ),
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
                                  color: AppColors.bluePrimary,
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
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                // Search by notificationSheet penjualan Produk
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
                  TransactionOperationSection(
                    title: "Detail Jasa",
                    operations: operations,
                    totalPrice: operations.fold(
                      0.0,
                      (previousValue, element) =>
                          previousValue + element.totalPrice,
                    ),
                  ),
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
                          TextCardDetail(
                            label: "Pajak",
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
