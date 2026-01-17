import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos_app/utils/responsive.dart';
import 'package:pos_app/db/inventory.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/widgets/footer.dart';
import 'package:pos_app/models/products.dart';
import 'package:pos_app/db/product.dart';

class Inventory extends StatefulWidget {
  const Inventory({super.key});

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {

  TextEditingController _stockController = TextEditingController();

  TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  String _selectedCategory = 'All';
  List<String> _categories = ['All'];

  int _currentPage = 1;
  final int _itemsPerPage = 15;
  int _totalItems = 0;
  int _totalPages = 1;

  Future<List<SomeProductData>>? _futureProductDatas;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final dbCategories = await InventoryDB.getCategories();
    setState(() {
      _categories = ['All', ...dbCategories];
    });
  }

  Future<void> _loadProducts() async {

    // Compute total items & pages
    _totalItems = await InventoryDB.countProductsFiltered(
      category: _selectedCategory,
      searchText: _searchText,
    );

    _totalPages = (_totalItems / _itemsPerPage).ceil();

    if (_currentPage > _totalPages && _totalPages != 0) {
      _currentPage = _totalPages;
    } else if (_totalPages == 0) {
      _currentPage = 1;
    }

    // Fetch products for current page
    final products = await InventoryDB.getFewProductsData(
      page: _currentPage,
      limit: _itemsPerPage,
      category: _selectedCategory,
      searchText: _searchText,
    );

    setState(() {
      _futureProductDatas = Future.value(products);
    });
    
}


Future<void> _updateStock(SomeProductData product) async{

  try {

    if (_stockController.text.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Stock is empty."
            ),
            content: Text(
              "Stock is required"
            ),
            actions: [
              TextButton(onPressed:() => Navigator.pop(context), child: Text('Ok'))
            ],
          );
        }
      );
      return;
    }
    
    final newStock = int.parse(_stockController.text.trim());

    if(newStock < 0){
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Invalid Input'),
            content: Text('Stock cannot be negative'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    await ProductDB.updateStock(product.id!, newStock);

    Navigator.pop(context);
    _loadProducts();

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stock updated successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        )
    );

      } catch (error) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update stock'),
            backgroundColor: Colors.red,
          ),
        );
  }

}

void _openUpdateModal(SomeProductData product){

  _stockController.text = product.stock.toString();

  showModalBottomSheet(
    context: context ,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(20))
    ),
    builder: (context){

      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 70,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Update Product",
              style: GoogleFonts.kameron(
                fontSize: 18,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 15,),

              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: InputDecoration(
                  labelText: 'Stock',
                  errorText: _stockController.text.isEmpty ? 'Required' : null,
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  
              },
            ),

            SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200,40),
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),

                ),
                shadowColor: Colors.grey[800]
              ),
              
              onPressed: () => _updateStock(product),
              child: Text('Save',
              style: GoogleFonts.kameron(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: Colors.white
              ),),
            ),

          ],
        ),
      );


    });

}


  Widget _buildPageNumbers() {
    // only show numbers if more than one page
    if (_totalPages <= 1) return const SizedBox();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_totalPages, (index) {
        final page = index + 1;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: InkWell(
            onTap: page == _currentPage
                ? null
                : () {
                    setState(() {
                      _currentPage = page;
                    });
                    _loadProducts();
                  },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _currentPage == page ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                page.toString(),
                style: TextStyle(
                  color: _currentPage == page ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }),
    );
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
        title: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
          child: Text(
            "Inventory",
            style: GoogleFonts.kameron(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
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
                      onChanged: (value) {
                        setState(() {
                          _searchText = value;
                          _currentPage = 1; // reset to first page on new search
                        });
                        _loadProducts();
                      },
                      decoration: InputDecoration(
                        hintText: 'Search for...',
                        prefixIcon: const Icon(Icons.search),
                        hintStyle: GoogleFonts.kameron(fontSize: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.black, width: 1),
                        ),
                        fillColor: Colors.grey[100],
                        filled: true,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                      dropdownColor: Colors.white,
                      style: GoogleFonts.kameron(fontSize: 16, color: Colors.black),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.black, width: 1),
                        ),
                        fillColor: Colors.grey[100],
                        filled: true,
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(value: category, child: Text(category));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                          _currentPage = 1; // reset to first page on category change
                        });
                        _loadProducts();
                      },
                    ),
                  )
                ],
              ),
              Divider(color: Colors.black, thickness: 1, height: 45),
              Text(
                '$_selectedCategory Products',
                style: GoogleFonts.kameron(fontSize: 17, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 20),
              FutureBuilder(
                future: _futureProductDatas,
                builder: (context, snapshot) {
                  if (_futureProductDatas == null) {
                    return const SizedBox();
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading inventory',
                        style: GoogleFonts.kameron(color: Colors.black),
                      ),
                    );
                  }

                  final products = snapshot.data ?? [];

                  if (products.isEmpty) {
                    return Center(
                      child: Text(
                        'No products found',
                        style: GoogleFonts.kameron(color: Colors.black),
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
                          DataColumn(
                              label: Center(
                                  child: Text('Product',
                                      style: tableTextStyle(fontSize: 15, fontWeight: FontWeight.bold)))),
                          DataColumn(label: Center(child: Text('Category', style: tableTextStyle(fontSize: 15, fontWeight: FontWeight.bold)))),
                          DataColumn(label: Center(child: Text('Stock', style: tableTextStyle(fontSize: 15, fontWeight: FontWeight.bold)))),
                          DataColumn(label: Center(child: Text('Status', style: tableTextStyle(fontSize: 15, fontWeight: FontWeight.bold)))),
                          DataColumn(label: Center(child: Text('Update', style: tableTextStyle(fontSize: 15, fontWeight: FontWeight.bold)))),
                        ],
                        rows: products.map((product) {
                          return DataRow(cells: [
                            DataCell(Center(child: Text(product.name, style: tableTextStyle(fontSize: 14)))),

                            DataCell(Center(child: Text(product.category, style: tableTextStyle(fontSize: 14)))),

                            DataCell(Center(child: Text(product.stock.toString(), style: tableTextStyle(fontSize: 14)))),

                            DataCell(
                              Center(
                                child: Text(
                                  product.stock > 0 ? 'Available' : 'Out of stock',
                                  style: tableTextStyle(
                                    fontSize: 14,
                                    color: product.stock > 0 ? const Color.fromARGB(255, 34, 141, 38) : Colors.red,
                                  ),
                                ),
                              ),
                            ),

                            DataCell(
                              Center(
                                child: InkWell(
                                  onTap: () => _openUpdateModal(product),
                                  borderRadius: BorderRadius.circular(6),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        size: 18,
                                        color: const Color.fromARGB(255, 1, 68, 122),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "Update",
                                        style: tableTextStyle(
                                          fontSize: 14,
                                          color: const Color.fromARGB(255, 1, 68, 122),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ]);
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 25),
              Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left),
                      onPressed: _currentPage > 1
                          ? () {
                              setState(() {
                                _currentPage--;
                              });
                              _loadProducts();
                            }
                          : null,
                    ),
                    _buildPageNumbers(),
                    IconButton(
                      icon: Icon(Icons.chevron_right),
                      // use computed _totalPages so '>' disables when no next page
                      onPressed: _currentPage < _totalPages
                          ? () {
                              setState(() {
                                _currentPage++;
                              });
                              _loadProducts();
                            }
                          : null,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppFooter(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/inventory');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/products');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/reports');
          }
        },
        onCenterTap: () {
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
