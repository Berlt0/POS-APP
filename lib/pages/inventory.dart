import 'package:flutter/material.dart';
import 'package:pos_app/utils/responsive.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/widgets/footer.dart';
import 'package:pos_app/models/products.dart';
import 'package:pos_app/db/product.dart';

class Inventory extends StatefulWidget {
  const Inventory({super.key});

  @override
  State<Inventory> createState() => _InventoryState();
}

class Product {
  final String name;
  final String category;
  final int stock;

  Product({required this.name, required this.category, required this.stock});
}


class _InventoryState extends State<Inventory> {

  TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  String _selectedCategory = 'All';

  late Future<List<SomeProductData>> _futureProductDatas;
  
//   List<Product> _products = [
//   Product(name: 'Coke', category: 'Drinks', stock: 20),
//   Product(name: 'Pepsi', category: 'Drinks', stock: 15),
//   Product(name: 'Burger', category: 'Food', stock: 30),
//   Product(name: 'Chips', category: 'Food', stock: 50),
//   Product(name: 'Water', category: 'Drinks', stock: 100),
// ];


  @override
  void initState(){
    super.initState();
    _futureProductDatas = ProductDB.getFewProductsData();
  }

  @override
  void dispose(){
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        shadowColor: Colors.grey.withOpacity(0.5),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[100],
        elevation: 5,
        title:Padding(
          padding: const EdgeInsets.fromLTRB(20,0,0,0),
          child: Text(
            "Inventory",
            style: GoogleFonts.kameron(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black
            ),
            ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 3,
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
                      ),
                    ),
                  ),
        
                  SizedBox(width: 10,),
        
                  Expanded(
                    flex:2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                      dropdownColor: Colors.white, // dropdown menu background
                      style: GoogleFonts.kameron(
                      fontSize: 16,
                      color: Colors.black, // selected text color
                      ),
                      decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 1
                        ),
                      ),
                      fillColor: Colors.grey[100],
                      filled: true,
                      
                    ),
                     items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'Food', child: Text('Food')),
                    DropdownMenuItem(value: 'Drinks', child: Text('Drinks')),
                    DropdownMenuItem(value: 'Others', child: Text('Others')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                    )
                  )
                ],
              ),
              Divider(
                color: Colors.black,
                thickness: 1,
                height: 45,
              ),
              Text(
                '$_selectedCategory Products' ,
                style: GoogleFonts.kameron(
                  fontSize: 17,
                  fontWeight: FontWeight.w500
                ), 
              ),
              SizedBox(height: 20),
              FutureBuilder(
                future: _futureProductDatas,
                builder: (context, snapshot) {

                  if(snapshot.connectionState == ConnectionState.waiting){
                    return const Center(child: CircularProgressIndicator());
                  }

                  if(snapshot.hasError){
                    return Center(
                      child: Text('Error loading inventory',
                      style: GoogleFonts.kameron(
                        color: Colors.black,
                      ),),
                    );
                  }

                  final products = snapshot.data ?? [];

                  final filteredProducts = products.where((product){
                  final matchesSearch = product.name.toLowerCase().contains(_searchText.toLowerCase());

                  final matchesCategory = _selectedCategory == 'All' ||
                  product.category == _selectedCategory;

                  return matchesSearch && matchesCategory;
        
                  }).toList();

                  if(filteredProducts.isEmpty){
                    return Center(
                      child: Text(
                        'No products found',
                        style: GoogleFonts.kameron(
                          color: Colors.black
                        ),
                      ),
                    );
                  }

                  

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columnSpacing: 25,
                        headingRowColor: MaterialStateProperty.all(const Color(0xFF6FE5F2)),
                        
                        columns: [
                          DataColumn(label: Center(child: Text('Product',style: tableTextStyle(fontSize: 15,fontWeight: FontWeight.bold),))),
                          DataColumn(label: Center(child: Text('Category',style: tableTextStyle(fontSize: 15,fontWeight: FontWeight.bold)))),
                          DataColumn(label: Center(child: Text('Stock',style: tableTextStyle(fontSize: 15,fontWeight: FontWeight.bold)))),
                          DataColumn(label: Center(child: Text('Status',style: tableTextStyle(fontSize: 15,fontWeight: FontWeight.bold)))),
                          DataColumn(label: Center(child: Text('Update',style: tableTextStyle(fontSize: 15,fontWeight: FontWeight.bold)))),
                        ],rows: filteredProducts.map((product){
                          return DataRow(cells: [
                          DataCell(Center(child: Text(product.name,style: tableTextStyle(fontSize: 14, fontWeight: FontWeight.normal)))),
                          DataCell(Center(child: Text(product.category,style: tableTextStyle(fontSize: 14,fontWeight: FontWeight.normal)))),
                          DataCell(Center(child: Text(product.stock.toString(),style: tableTextStyle(fontSize: 14,fontWeight: FontWeight.normal)))),
                          DataCell(
                            Center(
                              child: Text(
                              product.stock > 0 ? 'Available' : 'Out of stock',
                              style: tableTextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: product.stock > 0 ? const Color.fromARGB(255, 34, 141, 38) : Colors.red,
                              ),
                            ),
                            ),
                          ),
                          DataCell(
                            Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min, // make row wrap tightly
                              children: [
                                Icon(Icons.edit, size: 18,color: const Color.fromARGB(255, 1, 68, 122),),
                                SizedBox(width: 5),
                                Text("Update", style: tableTextStyle(fontSize: 14,color: Color.fromARGB(255, 1, 68, 122)),),
                              ],
                            ),
                          ),
                          ),
                        ]);
                        }).toList()
                        ),
                    ),
                  );
                }
              )

            ],
          ),
        ),
      ),
      bottomNavigationBar: AppFooter(
        currentIndex: 1,
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

TextStyle tableTextStyle({
  double fontSize = 16,
  FontWeight fontWeight = FontWeight.normal,
  Color color = Colors.black,
}) {
  return GoogleFonts.kameron(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
  );
}
