class Sale {
  final int id;
  final String product_name;
  final int quantity;
  final double price;
  final String createdAt;

  Sale({
    required this.id,
    required this.product_name,
    required this.quantity,
    required this.price,
    required this.createdAt,
  });

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      product_name: map['product_name'],
      quantity: map['quantity'],
      price: map['price'],
      createdAt: map['created_at'],
    );
  }
}

