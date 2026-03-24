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
  String? lastUpdate;
  String? deletedAt;
  int isSync;

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
    this.deletedAt,
    this.isSync = 0,
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
      'updated_at': lastUpdate ?? DateTime.now().toIso8601String(),
      'deleted_at': deletedAt,
      'is_synced': isSync,
    };
  }

  // Optional: factory method to create Product from DB map
  factory Product.fromMap(Map<String, dynamic> map) {

    double parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  int parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
    return Product(
      // id: map['id'] as int?,
      // name: map['name'] as String,
      // price: (map['price'] as num).toDouble(),
      // stock: map['stock'] as int,
      // stockUnit: map['stock_unit'] as String? ?? 'pcs',
      // cost: map['cost'] != null ? (map['cost'] as num).toDouble() : null,
      // category: map['category'] as String?,
      // barcode: map['barcode'] as String?,
      // lowStockAlert: map['low_stock_alert'] as int?,
      // description: map['description'] as String?,
      // imagePath: map['image_path'] as String?,
      // createdAt: map['createdAt'] as String?,
      // lastUpdate: map['update_at'] as String?,
      // deletedAt: map['deleted_at'] as String?,
      // isSync: map['is_synced'] as int? ?? 0,

      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()),
      name: map['name'] as String,
      price: parseDouble(map['price']),
      stock: parseInt(map['stock']),
      stockUnit: map['stock_unit'] as String? ?? 'pcs',
      cost: map['cost'] != null ? parseDouble(map['cost']) : null,
      category: map['category'] as String?,
      barcode: map['barcode'] as String?,
      lowStockAlert: map['low_stock_alert'] != null ? parseInt(map['low_stock_alert']) : null,
      description: map['description'] as String?,
      imagePath: map['image_path'] as String?,
      createdAt: map['createdAt'] as String?,
      lastUpdate: map['updated_at'] as String?,
      deletedAt: map['deleted_at'] as String?,
      isSync: map['is_synced'] != null ? parseInt(map['is_synced']) : 0,
      
    );
  }
}

class SomeProductData{
final int? id;
final String name;
final String? category;
final int stock;
final int? low_stock_alert;
final String? image_path;

SomeProductData({
  this.id,
  required this.name,
  this.category,
  required this.stock,
  this.low_stock_alert,

  this.image_path
});

factory SomeProductData.fromMap(Map<String,dynamic>map){
  return SomeProductData(
    id: map['id'] as int?,
    name: map['name'] as String,
    category: map['category'] as String?,
    stock: map['stock'] as int,
    low_stock_alert: map['low_stock_alert'] as int?,
    image_path: map['image_path'] as String?
  );
}

}

class ProductUpdateStock{
  final int id;
  final int stock;

  ProductUpdateStock({
    required this.id,
    required this.stock,
  });

  Map<String, dynamic> toMap() {
    return {
      'stock': stock,
    };

  }
}

class editProduct {

  final int? id;
  final String name;
  final double price;
  final int stock;
  final double? cost;
  final String? category;
  final int? lowStockAlert;
  final String? description;
  final String? image_path;

  editProduct({
    this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.cost,
    this.category,
    this.lowStockAlert,
    this.description,
    this.image_path,

  });

  Map<String, dynamic> toMap() {
  return {
    'id': id,
    'name': name,
    'price': price,
    'stock': stock,
    'cost': cost,
    'category': category,
    'low_stock_alert': lowStockAlert,
    'description': description,
    'image_path': image_path,
  };
}


}

class LowStockProducts{

  final int id;
  final String name;
  final int stock;
  final String stock_unit;
  final int low_stock_alert;

  LowStockProducts({
    required this.id,
    required this.name,
    required this.stock,
    required this.stock_unit,
    required this.low_stock_alert,
  });

  factory LowStockProducts.fromMap(Map<String, dynamic> map) {
    return LowStockProducts(
      id: map['id'],
      name: map['name'],
      stock: map['stock'],
      stock_unit: map['stock_unit'],
      low_stock_alert: map['low_stock_alert'],
    );
  }


}