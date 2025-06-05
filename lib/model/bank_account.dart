class BankAccount {
  final String id;
  final String bankName;
  final String accountNumber;
  final String accountHolder;
  final String storeId;

  BankAccount({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolder,
    required this.storeId,
  });

  factory BankAccount.fromJSON(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'] as String,
      bankName: json['bank_name'] as String,
      accountNumber: json['account_number'] as String,
      accountHolder: json['account_holder'] as String,
      storeId: json['store_id'] as String,
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'bank_name': bankName,
      'account_number': accountNumber,
      'account_holder': accountHolder,
      'store_id': storeId,
    };
  }
}