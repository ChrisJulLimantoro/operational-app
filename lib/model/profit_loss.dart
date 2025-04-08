class PLItem {
  final String name;
  final int amount;

  PLItem({required this.name, required this.amount});

  factory PLItem.fromJson(Map<String, dynamic> json) {
    return PLItem(
      name: json['name'],
      amount: json['amount'],
    );
  }
}

class PLSection {
  final String label;
  final List<PLItem> data;

  PLSection({required this.label, required this.data});

  factory PLSection.fromJson(Map<String, dynamic> json) {
    return PLSection(
      label: json['label'],
      data: (json['data'] as List)
          .map((item) => PLItem.fromJson(item))
          .toList(),
    );
  }
}