import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos_app/models/pos.dart';
import 'package:pos_app/db/pos.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class POS extends StatefulWidget {
  const POS({super.key});

  @override
  State<POS> createState() => _POSState();
}

class ProductCard extends StatelessWidget {
  final String name;
  final double price;
  final int stock;
  final int quantity;
  final String imagePath;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.stock,
    required this.quantity,
    required this.imagePath,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: quantity > 0 ? const Color(0xFF00E6FF) : Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Buttons (Top)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circleButton(
                  icon: Icons.remove,
                  onTap: quantity > 0 ? onRemove : null,
                ),
                Text(
                  quantity.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                _circleButton(
                  icon: Icons.add,
                  onTap: stock > quantity ? onAdd : null,
                ),
              ],
            ),

            const SizedBox(height: 6),

            //Product Image
            Expanded(
                child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: imagePath.isNotEmpty && File(imagePath).existsSync()
                    ? Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Image.asset(
                        'assets/Legendaries.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
              ),
            ),

            const SizedBox(height: 6),

            //Product Info
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.kameron(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            Text(
              '₱${price.toStringAsFixed(2)}',
              style: GoogleFonts.kameron(
                fontSize: 13,
                color: const Color.fromARGB(255, 57, 148, 60),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Stock: $stock',
              style: GoogleFonts.kameron(
                fontSize: 12.5,
                color: const Color.fromARGB(255, 68, 67, 67),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton({required IconData icon, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: onTap == null ? Colors.grey[300] : Colors.black,
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }
}

Widget _rowText(
  String label,
  String value, {
  bool isBold = false,
  double fontSize = 14,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: GoogleFonts.kameron(
          fontSize: fontSize,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      Text(
        value,
        style: GoogleFonts.kameron(
          fontSize: fontSize,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    ],
  );
}

class _POSItem {
  final POSModel product;
  int qty;

  _POSItem({required this.product, this.qty = 0});
}

class _POSState extends State<POS> {


  List<_POSItem> products = [];
  bool isLoading = true;
  String _selectedCategory = 'All';
  List<String> categories = ['All'];
  TextEditingController _searchController = TextEditingController();
  String _searchText = '';


  @override
  void initState() {
    super.initState();
    _loadProducts();
  }


  Future<String> saveImageLocally(File image) async {
  final dir = await getApplicationDocumentsDirectory();
  final newPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.png';
  final newImage = await image.copy(newPath);
  return newImage.path;
}




  Future<void> _loadProducts() async {
    try {
      final dbProducts = await POSDB.getProducts();

      final catSet = <String>{};
      for (var product in dbProducts) {
        if ((product.category ?? '').isNotEmpty) {
          catSet.add(product.category!);
        }
      }

      setState(() {
        products = dbProducts.map((p) => _POSItem(product: p)).toList();
        categories = ['All', ...catSet];
        isLoading = false;
      });
    } catch (error) {
      debugPrint("POS load error: $error");
      setState(() => isLoading = false);
    }
  }

  int getTotalQuantity() => products.fold(0, (total, item) => total + item.qty);

  double getSubTotal() =>
      products.fold(0.0, (total, item) => total + (item.product.price * item.qty));

  double getTotal() => getSubTotal();

  @override
  Widget build(BuildContext context) {

    // compute filtered products here

    final filteredProducts = products.where((p) {

      final matchesCategory = _selectedCategory == 'All' || (p.product.category ?? '') == _selectedCategory;
      final matchesSearch = _searchText.trim().isEmpty || p.product.name.toLowerCase().contains(_searchText.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
    

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        shadowColor: Colors.grey.withOpacity(0.5),
        elevation: 5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Padding(
          padding: const EdgeInsets.fromLTRB(1, 0, 0, 0),
          child: Text(
            "POS",
            style: GoogleFonts.kameron(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// SEARCH + SCAN
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search for...',
                      prefixIcon: const Icon(Icons.search),
                       suffixIcon: _searchText.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchText = '';
                              });
                            },
                          )
                        : null,
                      hintStyle: GoogleFonts.kameron(fontSize: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.black, width: 1),
                      ),
                      fillColor: Colors.grey[100],
                      filled: true,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: const Color(0xFF30DD04),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Scan",
                          style: GoogleFonts.kameron(
                              fontSize: 17,
                              color: Colors.black,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 5),
                        const Icon(Icons.qr_code_scanner, color: Colors.black),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// CATEGORIES
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = _selectedCategory == category;

                  return ElevatedButton(
                    onPressed: () {
                      setState(() => _selectedCategory = category);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      backgroundColor:
                          isSelected ? const Color(0xFF00E6FF) : Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected ? Colors.transparent : Colors.grey,
                        ),
                      ),
                    ),
                    child: Text(
                      category,
                      style: GoogleFonts.kameron(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            /// PRODUCT GRID
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final item = filteredProducts[index];

                  return ProductCard(
                    name: item.product.name,
                    price: item.product.price,
                    stock: item.product.stock ?? 0,
                    quantity: item.qty,
                    imagePath: item.product.image_path ?? '',
                    onAdd: () {
                      setState(() {
                        if (item.qty < (item.product.stock ?? 0)) item.qty++;
                      });
                    },
                    onRemove: () {
                      setState(() {
                        if (item.qty > 0) item.qty--;
                      });
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 15),

            /// CART SUMMARY
            Center(
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                    color: const Color(0xFF00E6FF),
                    borderRadius: BorderRadius.circular(12)),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        /// LEFT — TEXT COLUMN
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _rowText(
                                  "Total Quantity", getTotalQuantity().toString()),
                              _rowText("Subtotal", "₱${getSubTotal()}"),
                              const SizedBox(height: 6),
                              _rowText(
                                "Total",
                                "₱${getTotal()}",
                                isBold: true,
                                fontSize: 16,
                              ),
                            ],
                          ),
                        ),

                        /// MIDDLE — VERTICAL DIVIDER
                        const VerticalDivider(
                          width: 20,
                          thickness: 1,
                          color: Colors.black,
                        ),

                        /// RIGHT — BUTTON COLUMN
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6FE5F2),
                                  minimumSize: const Size(double.infinity, 36),
                                ),
                                onPressed: (){
                                  
                                  if(getTotalQuantity() == 0){
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Cart is empty! Please'),
                                        backgroundColor: Colors.red,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                    return;
                                  }
                                  Navigator.pushNamed(context, '/reviewcart');
                                },
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.chevron_right,
                                          color: Colors.black),
                                      Text(
                                        "Checkout",
                                        style: GoogleFonts.kameron(
                                            color: Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEE5558),
                                  minimumSize: const Size(double.infinity, 36),
                                ),
                                onPressed: () {
                                  setState(() {
                                    for(final item in products){
                                      item.qty = 0;
                                    }
                                  });
                                },
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.delete, color: Colors.black),
                                      Text(
                                        "Clear Cart",
                                        style: GoogleFonts.kameron(
                                            color: Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
