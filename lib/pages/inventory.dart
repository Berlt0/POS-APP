import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos_app/db/sync.dart';
import 'package:pos_app/utils/responsive.dart';
import 'package:pos_app/db/inventory.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/widgets/footer.dart';
import 'package:pos_app/models/products.dart';
import 'package:pos_app/db/product.dart';
import 'package:pos_app/db/user.dart';

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


  String? _userRole;
  bool _isLoadingRole = true;


  Future<List<SomeProductData>>? _futureProductDatas;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadProducts();
    _loadRole();
  
  }

  @override
  void dispose() {
    _searchController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _loadRole() async {
  final role = await UserDB().getLoggedInUserRole();
  setState(() {
    _userRole = role;
    _isLoadingRole = false;
  });
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

     if (_userRole != 'admin') {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Unauthorized action'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

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
    await syncProducts();

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
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
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

      String? _errorText;

      return StatefulBuilder(
        builder: (context, setStateDialog) {

          final isMobile = Responsive.isMobile(context);
          final isTablet = Responsive.isTablet(context);
          final isDesktop = Responsive.isDesktop(context);

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
              SizedBox(height: 10,),
              Text(
                "Update Product",
                style: GoogleFonts.kameron(
                  fontSize: Responsive.font(context, mobile: 18, tablet: 20, desktop: 22),
                  fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 15,),
        
                TextFormField(
                  controller: _stockController,
                  style: GoogleFonts.kameron( 
                    fontSize: Responsive.font(context, mobile: 18, tablet: 20, desktop: 22),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: InputDecoration(
                    errorText: _errorText,
                    errorStyle: GoogleFonts.kameron( 
                    fontSize: Responsive.font(context, mobile: 13, tablet: 15, desktop: 17),
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                    labelText: 'Stock',
                    labelStyle: GoogleFonts.kameron(
                              fontSize: Responsive.font(context, mobile: 21, tablet: 23, desktop: 25)
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    contentPadding: EdgeInsets.symmetric(vertical: 22,horizontal: 20),
                  ),
                  
                  onChanged: (value) {
                    if (_errorText != null) {
                        setStateDialog(() => _errorText = null);
                    }
                },
              ),
        
              SizedBox(height: 20),
        
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                // minimumSize: Size(200,40),
                minimumSize: Size(200, isDesktop ? 55 : isTablet ? 50 : 45),
                backgroundColor: Color(0xFF00C853),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  ),
                  shadowColor: Colors.grey[800]
                ),
                
                onPressed: () {

                  final value = _stockController.text;

                    setStateDialog(() {
                      if (value.isEmpty) {
                        _errorText = 'Stock is required';
                      } else if (int.tryParse(value) == null) {
                        _errorText = 'Invalid number';
                      } else {
                        _errorText = null;
                      }
                    });

                    if (_errorText != null) return;

                  _updateStock(product);
                  },
                child: Text('Save',
                style: GoogleFonts.kameron(
                  fontSize: Responsive.font(context, mobile: 17, tablet: 19, desktop: 21),
                  fontWeight: FontWeight.w500,
                  color: Colors.black
                ),),
              ),
        
            ],
          ),
        );
        }
      );


    });

}


  Widget _buildPageNumbers() {
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

    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        shadowColor: Colors.grey.withOpacity(0.5),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[100],
        elevation: 5,
        toolbarHeight: isDesktop ? 80 : isTablet ? 70 : 60,
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
                 _selectedCategory == 'All'
                    ? 'Complete Inventory'
                    : '$_selectedCategory' ,
                style: GoogleFonts.kameron(fontSize: Responsive.font(context, mobile: 17, tablet: 19, desktop: 21), fontWeight: FontWeight.w500),
              ),

              SizedBox(height: 20),
                Container(
                  width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: LayoutBuilder(
                        builder: (context, constraints){
                    
                        final tableWidth = constraints.maxWidth -32;
                    
                      return FutureBuilder(
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
                      
                            final isSearching = _searchText.trim().isNotEmpty;
                            
                              return SizedBox(
                                height: MediaQuery.of(context).size.height * 0.5, // helps vertical centering
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon( isSearching
                                        ? Icons.search_off
                                        :Icons.inventory_2_outlined,
                                        size: 45 ,
                                        color: Colors.grey[500],
                                      ),
                                      SizedBox(height: 15),
                                      Text(
                                        _searchText.isNotEmpty
                                            ? 'No results found'
                                            : 'No products found',
                                        style: GoogleFonts.kameron(
                                          fontSize: 16,
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                      
                        
                      
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minWidth: constraints.maxWidth),
                              child: SizedBox(
                                width: constraints.maxWidth,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                    child: DataTable(
                                      columnSpacing: isDesktop ? 60 : isTablet ? 50 : 30,
                                      headingRowHeight: isTablet ? 50 : 56,
                                      dataRowHeight:  isDesktop ? 60 : isTablet ? 55 : 50,
                                      headingRowColor:MaterialStateProperty.all(const Color.fromARGB(164, 224, 224, 224)),
                                      columns: [
                                        DataColumn(label: Text('Product', style: tableTextStyle(fontSize: isDesktop ? 21 : isTablet ? 18 : 15, fontWeight: FontWeight.w500))),
                                        DataColumn(label: Text('Category', style: tableTextStyle(fontSize: isDesktop ? 21 : isTablet ? 18 : 15, fontWeight: FontWeight.w500))),
                                        DataColumn(label: Text('Stock', style: tableTextStyle(fontSize: isDesktop ? 21 : isTablet ? 18 : 15, fontWeight: FontWeight.w500))),
                                        DataColumn(label: Text('Status', style: tableTextStyle(fontSize: isDesktop ? 21 : isTablet ? 18 : 15, fontWeight: FontWeight.w500))),
                                        DataColumn(label: Text('Update', style: tableTextStyle(fontSize: isDesktop ? 21 : isTablet ? 18 : 15, fontWeight: FontWeight.w500))),
                                      ],
                                      rows: products.map((product) {
                                        
                                        return DataRow(cells: [
                                          DataCell(Text(capitalizeEachWord(product.name), style: tableTextStyle(fontSize:  isDesktop ? 21 : isTablet ? 18 : 14))),
                                                    
                                          DataCell(Text(capitalizeEachWord(product.category ?? 'Uncategorized'), style: tableTextStyle(fontSize:  isDesktop ? 21 : isTablet ? 18 : 14))),
                                                    
                                          DataCell( Text(product.stock.toString(), style: tableTextStyle(fontSize:  isDesktop ? 21 : isTablet ? 18 : 14))),   
                                                    
                                          DataCell(
                                            
                                              Text(
                                                product.stock == 0 ? 'Out of Stock' : product.stock <= product.low_stock_alert! ? 'Low Stock' : 'In Stock',
                                                style: tableTextStyle(
                                                  fontSize: isDesktop ? 21 : isTablet ? 18 : 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: product.stock == 0 ? Colors.red : product.stock <= product.low_stock_alert! ? const Color.fromARGB(255, 255, 165, 0) : const Color.fromARGB(255, 34, 141, 38),
                                                ),
                                              ),
                                              
                                            
                                          ),
                                                    
                                          DataCell(
                                              InkWell(
                                                onTap: (_isLoadingRole || _userRole == 'admin') 
                                                ? () => _openUpdateModal(product)
                                                : () {
                                                    
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('Only admin can update stock'),
                                                        backgroundColor: Colors.red,
                                                      ),
                                                    );
                                                },
                                                borderRadius: BorderRadius.circular(6),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.edit,
                                                      size:  isDesktop ? 22 : isTablet ? 20 : 18,
                                                      color: _userRole == 'admin'
                                                      ? const Color.fromARGB(255, 1, 68, 122)
                                                      : Colors.grey,
                                                    ),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      "Update",
                                                      style: tableTextStyle(
                                                        fontSize:isDesktop ? 19 : isTablet ? 17 : 14,
                                                        color: _userRole == 'admin'
                                                        ? const Color.fromARGB(255, 1, 68, 122)
                                                        : Colors.grey
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          
                                        ]);
                                      }).toList(),
                                    ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                      }
                    ),
                  ),
                ),
              
              SizedBox(height: 25),
              if(_totalItems > 1) 
              
              Container(
                color: Colors.grey[100], // optional background
                padding: const EdgeInsets.symmetric(vertical: 10),
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

String capitalizeEachWord(String text) {
  return text
      .split(' ')
      .map((word) =>
          word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' : '')
      .join(' ');
}