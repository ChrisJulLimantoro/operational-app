import 'package:operational_app/model/account.dart';
import 'package:operational_app/model/customer.dart';
import 'package:operational_app/model/employee.dart';
import 'package:operational_app/model/transaction_operation.dart';
import 'package:operational_app/model/transaction_product.dart';

class Transaction {
  final String id;
  final DateTime date;
  final String code;
  final int transactionType;
  final int paymentMethod;
  final double paidAmount;
  final int poinEarned;
  final int status;
  final double subTotalPrice;
  final double taxPrice;
  final double taxPercent;
  final double adjustmentPrice;
  final double totalPrice;
  final String comment;
  final int approve;
  final String storeId;
  final String? notaLink;
  final Customer? customer;
  final Employee? employee;
  final List<TransactionProduct> transactionProducts;
  final List<TransactionOperation> transactionOperations;
  final Account? account;
  final String? accountId;

  Transaction({
    required this.id,
    required this.date,
    required this.code,
    required this.transactionType,
    required this.paymentMethod,
    required this.paidAmount,
    required this.poinEarned,
    required this.status,
    required this.subTotalPrice,
    required this.taxPrice,
    required this.taxPercent,
    required this.adjustmentPrice,
    required this.totalPrice,
    required this.comment,
    required this.storeId,
    required this.approve,
    required this.customer,
    required this.employee,
    this.notaLink,
    required this.transactionOperations,
    required this.transactionProducts,
    this.account,
    this.accountId,
  });

  factory Transaction.fromJSON(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      date: DateTime.parse(json['date']),
      code: json['code'],
      transactionType: json['transaction_type'],
      paymentMethod: json['payment_method'],
      paidAmount: double.tryParse(json['paid_amount']) ?? 0.0,
      poinEarned: json['poin_earned'] ?? 0,
      status: json['status'],
      subTotalPrice: double.tryParse(json['sub_total_price']) ?? 0.0,
      adjustmentPrice: double.tryParse(json['adjustment_price']) ?? 0.0,
      taxPrice: double.tryParse(json['tax_price']) ?? 0.0,
      taxPercent: double.tryParse(json['tax_percent']) ?? 0.0,
      totalPrice: double.tryParse(json['total_price']) ?? 0.0,
      comment: json['comment'] ?? '-',
      approve: json['approve'],
      storeId: json['store_id'],
      notaLink: json['nota_link'],
      customer: Customer.fromJSON(json['customer']),
      employee: Employee.fromJSON(json['employee']),
      transactionOperations:
          (json['transaction_operations'] as List)
              .map((op) => TransactionOperation.fromJSON(op))
              .toList(),
      transactionProducts:
          (json['transaction_products'] as List)
              .map((product) => TransactionProduct.fromJSON(product))
              .toList(),
      account: json['account'] != null
          ? Account.fromJSON(json['account'])
          : null,
      accountId: json['account_id'] as String?,
    );
  }
}
