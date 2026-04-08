
 class CartItem{
    final int productId;
    final String productGlobalId; 
    final String name;
    final double price;
    final int quantity;
    final String imagePath;

    CartItem({
        required this.productId,
        required this.productGlobalId,
        required this.name, 
        required this.price, 
        required this.quantity,
        required this.imagePath
    });
} 