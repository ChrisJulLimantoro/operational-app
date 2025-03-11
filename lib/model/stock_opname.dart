import 'package:operational_app/model/category.dart';
import 'package:operational_app/model/stock_opname_detail.dart';
import 'package:operational_app/model/store.dart';

class StockOpname {
  final String id;
  final String storeId;
  final String categoryId;
  final Store? store;
  final Category? category;
  final DateTime? date;
  final String? description;
  final int status;
  final bool isApproved;
  final String? approveBy;
  final DateTime? approveAt;
  final String createdBy;
  final DateTime? createdAt;
  final List<StockOpnameDetail> details;

  StockOpname({
    required this.id,
    required this.storeId,
    required this.categoryId,
    this.store,
    this.category,
    this.description,
    this.status = 0,
    this.isApproved = false,
    this.approveBy,
    this.approveAt,
    required this.date,
    required this.createdBy,
    required this.createdAt,
    this.details = const [],
  });

  factory StockOpname.fromJSON(Map<String, dynamic> json) {
    print(json['details']);
    return StockOpname(
      id: json['id'] ?? '', // Handle null safely
      storeId: json['store_id'] ?? '', // Handle null safely
      categoryId: json['category_id'] ?? '', // Handle null safely
      store: json['store'] != null ? Store.fromJSON(json['store']) : null,
      category:
          json['category'] != null ? Category.fromJSON(json['category']) : null,
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      description: json['description'] ?? '-',
      status: json['status'] ?? 0, // Provide default if null
      isApproved: json['is_approved'] ?? false, // Provide default if null
      approveBy: json['approve_by'] ?? '-', // Allow null
      approveAt:
          json['approve_at'] != null
              ? DateTime.tryParse(json['approve_at'])
              : null,
      createdBy: json['created_by'] ?? '-', // Handle null safely
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'])
              : null,
      details:
          (json['details'] as List?)
              ?.map((e) => StockOpnameDetail.fromJSON(e))
              .toList() ??
          [],
    );
  }
}
