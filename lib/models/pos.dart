

class POSModel{

final int? id;
final String name;
final String? category;
final double price;
final double? cost;
final int? stock;
final String? image_path;

POSModel({

  this.id,
  required this.name,
  required this.category,
  required this.price,
  required this.cost,
  this.stock,
  required this.image_path,

});

  factory POSModel.fromMap(Map<String, dynamic> map) {
    return POSModel(
      id: map['id'] as int,
      name: map['name'] as String,
      category: map['category'] as String?,
      price: (map['price'] as num).toDouble(),
      cost: map['cost'] != null ? (map['cost'] as num).toDouble() : 0.0,
      stock: map['stock'] as int,
      image_path: map['image_path'] as String?
    );
  }
}
