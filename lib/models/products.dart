class Product {
  final int? id;
  final String name;
  final double price;
  final int stock;
  final String? category;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'category': category,
    };
  }
}
