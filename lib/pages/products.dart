import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pos_app/widgets/footer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/db/product.dart';
import 'package:pos_app/models/products.dart';

class Products extends StatefulWidget {
  const Products({super.key});

  @override
  State<Products> createState() => _ProductsState();
}


class _ProductsState extends State<Products> {

  TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  String _selectedCategory = 'All';

  late Future<List<Product>> _productsFuture;

  
 @override
  void initState() {
    super.initState();
    _loadProducts();
  }
  
void _loadProducts() {
  _productsFuture = ProductDB.getAll();
  _productsFuture.then((list) {
    print("Products loaded: ${list.length}");
    for (var p in list) {
      print("Product: ${p.name}, ${p.imagePath}");
    }
  }); // returns List<Product> from DB
}



Widget categoryHeader(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      children: [
        const Expanded(child: Divider(color:Colors.black,thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.kameron(
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Colors.black,thickness: 1)),
      ],
    ),
  );
}


Widget productCard(Product product) {
  return Container(
    margin: const EdgeInsets.only(top: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        /// LEFT SIDE
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: product.imagePath != null
                  ? Image.file(
                      File(product.imagePath!),
                      width: 45,
                      height: 45,
                      fit: BoxFit.cover,
                    ): Image.asset(
                      'assets/Legendaries.png', // fallback image
                      width: 45,
                      height: 45,
                      fit: BoxFit.cover,
                    ),
            ),

            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: GoogleFonts.kameron(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '₱${product.price.toStringAsFixed(2)}',
                  style: GoogleFonts.kameron(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  'Stock: ${product.stock}',
                  style: GoogleFonts.kameron(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ),

        /// RIGHT SIDE
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () {},
            ),
          ],
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        shadowColor: Colors.grey.withOpacity(0.5),
        automaticallyImplyLeading: false,
        elevation: 5,
        title:Padding(
          padding: const EdgeInsets.fromLTRB(20,0,0,0),
          child: Text(
            "Products",
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
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for...',
                        prefixIcon: const Icon(Icons.search),
                        hintStyle: GoogleFonts.kameron(fontSize: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100]
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      style: GoogleFonts.kameron(
                        fontSize: 16,
                        color: Colors.black),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100]
                      ),
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All')),
                        DropdownMenuItem(value: 'Food', child: Text('Food')),
                        DropdownMenuItem(value: 'Drinks', child: Text('Drinks')),
                        DropdownMenuItem(value: 'Others', child: Text('Others')),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedCategory = value!);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

             Expanded(
              child: FutureBuilder<List<Product>>(
                future: _productsFuture,
                builder: (context,snapshot){
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading products'));
                  }

                  // This is the key line:
                  final products = snapshot.data ?? [];

                  // Group products by category
                  final Map<String, List<Product>> grouped = {};
                  for (var product in products) {
                    if (_selectedCategory != 'All' &&
                        product.category != _selectedCategory) continue;

                    grouped.putIfAbsent(product.category ?? 'Others', () => []);
                    grouped[product.category ?? 'Others']!.add(product);
                }

                 return ListView(
                  children: grouped.entries.map((entry) {
                    final category = entry.key;
                    final productsInCategory = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        categoryHeader(category),
                        ...productsInCategory.map((product) => productCard(product)),
                      ],
                    );
                  }).toList(),
                );
                },
              ),
            ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed:(){
            Navigator.pushNamed(context, '/addproduct').then((_) {
            setState(() {
              _loadProducts();
            });
          });

          },
          backgroundColor: Color(0xFF25FFA0), 
          child: const Icon(Icons.add, color: Colors.black), 
          ),
      bottomNavigationBar: AppFooter(
        currentIndex: 2,
        onTap: (index) {
          if(index == 0){
            Navigator.pushReplacementNamed(context, '/home');
          }else if(index == 1){
            Navigator.pushReplacementNamed(context, '/inventory');
          }else if(index == 2){
            Navigator.pushReplacementNamed(context, '/products');
          }else if(index == 3){
            Navigator.pushReplacementNamed(context, '/reports');
          }
        },
        onCenterTap: (){
           Navigator.pushReplacementNamed(context, '/pos');
        },
      ),
    );
  }
}