
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

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
      color: quantity>0 ? Color(0xFF00E6FF) : Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ➕ ➖ Buttons (Top)
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

            /// 🖼 Product Image
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),

            const SizedBox(height: 6),

            /// 🏷 Product Info
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


class _POSState extends State<POS> {


    TextEditingController _searchController = TextEditingController();
    String _searchText = '';

    String _selectedCategory = 'All';


    final List<String> categories = [
      'All',
      'Drinks',
      'Snacks',
      'Foods',
      'Others',
      'Fish',
      'Can',
      'Noodles',

    ];

    List<Map<String, dynamic>> products = [
  {
    'name': 'Coke',
    'price': 20.0,
    'stock': 50,
    'qty': 0,
    'image': 'https://shopsuki.ph/cdn/shop/files/102051426_080dc8b7-e441-4d33-8f01-2bcae3404e7d_800x.jpg?v=1764041994',
  },
  {
    'name': 'Super Crunch',
    'price': 15.0,
    'stock': 30,
    'qty': 0,
    'image': 'https://shopsuki.ph/cdn/shop/files/107256203_1024x.jpg?v=1750067729',
  }, {
    'name': 'Kopiko',
    'price': 10.0,
    'stock': 14,
    'qty': 0,
    'image': 'https://shopsuki.ph/cdn/shop/files/8996001410547_1024x.jpg?v=1748839410',
  },
  {
    'name': 'Kopiko',
    'price': 10.0,
    'stock': 14,
    'qty': 0,
    'image': 'https://shopsuki.ph/cdn/shop/files/8996001410547_1024x.jpg?v=1748839410',
  },
  {
    'name': 'Kopiko',
    'price': 10.0,
    'stock': 14,
    'qty': 0,
    'image': 'https://shopsuki.ph/cdn/shop/files/8996001410547_1024x.jpg?v=1748839410',
  },
  {
    'name': 'Kopiko',
    'price': 10.0,
    'stock': 14,
    'qty': 0,
    'image': 'https://shopsuki.ph/cdn/shop/files/8996001410547_1024x.jpg?v=1748839410',
  },
];

  int getTotalQuantity() {
  return products.fold<int>(
    0,
    (total, product) => total + (product['qty'] as int),
  );
}

double getSubTotal() {
  return products.fold<double>(
    0.0,
    (total, product) =>
        total + (product['price'] * product['qty']),
  );
}

double getTotal() => getSubTotal();

  @override
  Widget build(BuildContext context) {

  
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        shadowColor: Colors.grey.withOpacity(0.5),
        elevation: 5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title:Padding(
          padding: const EdgeInsets.fromLTRB(1,0,0,0),
          child: Text(
            "POS",
            style: GoogleFonts.kameron(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black
            ),
            ),
        ),
        
      ),
      body: 
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => {
                        setState(() {
                          _searchText = value;
                        })
                      },
                      decoration: InputDecoration(
                      hintText: 'Search for...',
                      prefixIcon: const Icon(Icons.search),
                      hintStyle: GoogleFonts.kameron(
                        fontSize: 16
                      ),
                      border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                      color: Colors.black,
                        width: 1
                      )
                      ),
                      fillColor: Colors.grey[100],
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                      ),
                    ),
                  ),
          
                  SizedBox(width: 10,),
          
                  Expanded(
                    flex:1,
                    child: ElevatedButton(
                    onPressed: (){}, 
                    style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: Color(0xFF30DD04)
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(child: Text("Scan",
                        style: GoogleFonts.kameron(
                          fontSize: 17,
                          color: Colors.black,
                          fontWeight: FontWeight.w500
                        ),)),
                        SizedBox(width: 5,),
                        Icon(
                          Icons.qr_code_scanner,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
          
                        )
                      ],
                    )
                    )
          
                  )
          
                ],
              ),
              SizedBox(height: 20,),
              SizedBox(
                height: 40, 
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = _selectedCategory == category;

                    return ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        backgroundColor: isSelected
                            ? const Color(0xFF00E6FF)
                            : Colors.white,
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
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,       // 2 per row (phone)
                    childAspectRatio: 0.7,   // card height ratio
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                
                    return ProductCard(
                      name: product['name'],
                      price: product['price'],
                      stock: product['stock'],
                      quantity: product['qty'],
                      imagePath: product['image'],
                      onAdd: () {
                        setState(() {
                          product['qty']++;
                        });
                      },
                      onRemove: () {
                        setState(() {
                          if (product['qty'] > 0) {
                                setState(() {
                                  product['qty']--;
                                });
                              }
                        });
                      },
                    );
                  },
                ),
              ),

              SizedBox(height: 15,),
              //Review 
              Center(
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E6FF),
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)
                  ),
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
                              _rowText("Total Quantity", getTotalQuantity().toString()),
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

                              /// Checkout
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6FE5F2),
                                  minimumSize: const Size(double.infinity, 36),
                                ),
                                onPressed: () {},
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.chevron_right, color: Colors.black),
                                      Text("Checkout", style: GoogleFonts.kameron(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500
                                      )),
                                    ],
                                  ),
                                ),
                              ),

                              /// Clear Cart
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEE5558),
                                  minimumSize: const Size(double.infinity, 36),
                                ),
                                onPressed: () {},
                                child: Center(
                                  child: Row( 
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.delete, color: Colors.black),
                                      Text("Clear Cart", style: GoogleFonts.kameron(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500
                                      )),
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
            SizedBox(height: 40),

            
            ],
          ),
        ),
      
    
    );
  }
}