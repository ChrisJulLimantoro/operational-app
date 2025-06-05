class Account {
  final String id;
  final int code;
  final String name;
  final int accountTypeId;
  final String description;
  final String storeId;
  final String companyId;
  final bool deactive;
  final DateTime? createdAt;

  Account({
    required this.id,
    required this.code,
    required this.name,
    required this.accountTypeId,
    required this.description,
    required this.storeId,
    required this.companyId,
    required this.deactive,
    required this.createdAt,
  });

  factory Account.fromJSON(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      accountTypeId: json['account_type_id'],
      description: json['description'] ?? "-",
      storeId: json['store_id'] ?? "-",
      companyId: json['company_id'],
      deactive: json['deactive'] ?? false,
      createdAt: DateTime.tryParse(json['created_at']),
    );
  }
}
