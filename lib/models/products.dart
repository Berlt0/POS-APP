class Product {
  final int? id;
  final String name;
  final double price;
  final int stock;
  final String stockUnit;
  final double? cost;
  final String? category;
  final String? barcode;
  final int? lowStockAlert;
  final String? description;
  final String? imagePath;
  final String? createdAt;
  final String? lastUpdate;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.stockUnit = 'pcs',
    this.cost,
    this.category,
    this.barcode,
    this.lowStockAlert,
    this.description,
    this.imagePath,
    this.createdAt,
    this.lastUpdate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'stock_unit': stockUnit,
      'cost': cost,
      'category': category,
      'barcode': barcode,
      'low_stock_alert': lowStockAlert ?? 10,
      'description': description,
      'image_path': imagePath,
      'createdAt': createdAt ?? DateTime.now().toIso8601String(),
      'lastUpdate': lastUpdate ?? DateTime.now().toIso8601String(),
    };
  }

  // Optional: factory method to create Product from DB map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      price: map['price'] as double,
      stock: map['stock'] as int,
      stockUnit: map['stock_unit'] as String? ?? 'pcs',
      cost: map['cost'] != null ? map['cost'] as double : null,
      category: map['category'] as String?,
      barcode: map['barcode'] as String?,
      lowStockAlert: map['low_stock_alert'] as int?,
      description: map['description'] as String?,
      imagePath: map['image_path'] as String?,
      createdAt: map['createdAt'] as String?,
      lastUpdate: map['lastUpdate'] as String?,
    );
  }
}
