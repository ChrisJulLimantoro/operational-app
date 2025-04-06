class StockMutation {
  final String? categoryId;
  final String? categoryName;
  final String storeId;
  final String companyId;
  final String ownerId;
  final String initialStock;
  final String initialStockGram;
  final String inGoods;
  final String inGoodsGram;
  final String sales;
  final String salesGram;
  final String outGoods;
  final String outGoodsGram;
  final String purchase;
  final String purchaseGram;
  final String trade;
  final String tradeGram;
  final String finals;
  final String finalGram;
  final String unitPrice;

  StockMutation({
    required this.categoryId,
    required this.categoryName,
    required this.storeId,
    required this.companyId,
    required this.ownerId,
    required this.initialStock,
    required this.initialStockGram,
    required this.inGoods,
    required this.inGoodsGram,
    required this.sales,
    required this.salesGram,
    required this.outGoods,
    required this.outGoodsGram,
    required this.purchase,
    required this.purchaseGram,
    required this.trade,
    required this.tradeGram,
    required this.finals,
    required this.finalGram,
    required this.unitPrice,
  });

  factory StockMutation.fromJSON(Map<String, dynamic> json) {
    return StockMutation(
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      storeId: json['store_id'] ?? '',
      companyId: json['company_id'] ?? '',
      ownerId: json['owner_id'] ?? '',
      initialStock: json['initial_stock'] ?? '0',
      initialStockGram: json['initial_stock_gram'] ?? '0',
      inGoods: json['in_goods'] ?? '0',
      inGoodsGram: json['in_goods_gram'] ?? '0',
      sales: json['sales'] ?? '0',
      salesGram: json['sales_gram'] ?? '0',
      outGoods: json['out_goods'] ?? '0',
      outGoodsGram: json['out_goods_gram'] ?? '0',
      purchase: json['purchase'] ?? '0',
      purchaseGram: json['purchase_gram'] ?? '0',
      trade: json['trade'] ?? '0',
      tradeGram: json['trade_gram'] ?? '0',
      finals: json['final'] ?? '0',
      finalGram: json['final_gram'] ?? '0',
      unitPrice: json['unit_price'] ?? '0',
    );
  }
}