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

  Future<void> _updateStock(SomeProductData product) async {
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
              title: const Text("Stock is empty."),
              content: const Text("Stock is required"),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ok'))
              ],
            );
          },
        );
        return;
      }

      final newStock = int.parse(_stockController.text.trim());

      if (newStock < 0) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Invalid Input'),
              content: const Text('Stock cannot be negative'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
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
        const SnackBar(
          content: Text('Stock updated successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update stock'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  void _openUpdateModal(SomeProductData product) {
    _stockController.text = product.stock.toString();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLandscape = Responsive.isLandscape(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface, 
      barrierColor: isDark ? Colors.black.withOpacity(0.9) : Colors.black.withOpacity(0.6),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String? _errorText;

        return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface, 
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
          child: StatefulBuilder(
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
                    const SizedBox(height: 10),
                    Text(
                      "Update Product",
                      style: GoogleFonts.kameron(
                        fontSize: isLandscape ? Responsive.font(context, mobile: 15, tablet: 16, desktop: 18) : Responsive.font(context, mobile: 16, tablet: 20, desktop: 22),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _stockController,
                      style: GoogleFonts.kameron(
                        fontSize: isLandscape ? Responsive.font(context, mobile: 15, tablet: 16, desktop: 18) : Responsive.font(context, mobile: 18, tablet: 20, desktop: 22),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        errorText: _errorText,
                        errorStyle: GoogleFonts.kameron(
                          fontSize: Responsive.font(context, mobile: 13, tablet: 15, desktop: 17),
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                        labelText: 'Stock',
                        labelStyle: GoogleFonts.kameron(
                           fontSize: isDesktop ? 19 : isTablet ? 18 : 17,
                        ),
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        contentPadding:  EdgeInsets.symmetric(vertical: isMobile ? 12 : isLandscape ? 16 : 18, horizontal: 20),
                      ),
                      onChanged: (value) {
                        if (_errorText != null) {
                          setStateDialog(() => _errorText = null);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: isLandscape ? Size(isDesktop ? 170 : isTablet ? 160 : 150 ,isDesktop ? 45 : isTablet ? 40 : 35) :  Size(isDesktop ? 200 : isTablet ? 180 : 150 ,isDesktop ? 55 : isTablet ? 50 : 40),
                        backgroundColor: const Color(0xFF00C853),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shadowColor: Colors.grey[800],
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
                      child: Text(
                        'Save',
                        style: GoogleFonts.kameron(
                          fontSize: isLandscape ? Responsive.font(context, mobile: 14, tablet: 16, desktop: 18) : Responsive.font(context, mobile: 15, tablet: 19, desktop: 21),
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLandscape = Responsive.isLandscape(context);

    final isMobile = Responsive.isTablet(context);
    final isTablet = Responsive.isTablet(context);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        shadowColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
        elevation: 5,
        toolbarHeight:  isLandscape ? (isDesktop ? 50 : isTablet ? 40 : 35) : (isDesktop ? 70 : isTablet ? 60 : 50),
        title: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
          child: Text(
            "Inventory",
            style: GoogleFonts.kameron(
              fontSize: isLandscape ? (isDesktop ? 20 :isTablet ? 18 : 16) : (isDesktop ? 24 :isTablet ? 22 : 20),
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface
            ),
          ),
        ),
      ),

   
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 3,
                          child: SizedBox(
                            height: isLandscape
                            ? Responsive.spacing(context, mobile: 45, tablet: 50, desktop: 55)
                            : Responsive.spacing(context, mobile: 50, tablet: 55, desktop: 63),
                            child: TextField(
                              style: GoogleFonts.kameron(
                                fontSize:  Responsive.font(context,mobile: 17, tablet: 19, desktop: 20),
                                color: Colors.black
                              ),
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {
                                  _searchText = value;
                                  _currentPage = 1;
                                });
                                _loadProducts();
                              },
                               inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
                              ],
                              decoration: InputDecoration(
                                hintText: 'Search for...',
                                prefixIcon: Icon(Icons.search, size: Responsive.font(context,mobile: 25, tablet: 28, desktop: 30),color: Colors.black87,),
                                hintStyle: GoogleFonts.kameron(
                                  fontSize: isLandscape ? Responsive.font(context,mobile: 14, tablet: 16, desktop: 18)
                                            : Responsive.font(context,mobile: 15, tablet: 18, desktop: 20),
                                  fontWeight: FontWeight.w500, 
                                  color: Colors.black87
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(color: Colors.black, width: 1),
                                ),
                                fillColor: Colors.grey[100],
                                filled: true,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: isLandscape 
                              ? Responsive.spacing(context, mobile: 45, tablet: 50, desktop: 55)
                              : Responsive.spacing(context, mobile: 50, tablet: 55, desktop: 63),
                            child: DropdownButtonFormField<String>(
                              iconEnabledColor: Colors.black87,
                              dropdownColor: Colors.white,
                              value: _selectedCategory,
                              style: GoogleFonts.kameron(
                                fontSize: isLandscape ? Responsive.font(context,mobile: 14, tablet: 16, desktop: 18)
                                          : Responsive.font(context,mobile: 16, tablet: 18, desktop: 20), 
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
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
                                  _currentPage = 1;
                                });
                                _loadProducts();
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                    Divider( thickness: .9, height: 35),
                    
                    Center(
                      child: Text(
                        _selectedCategory == 'All' ? 'Complete Inventory' : '$_selectedCategory',
                        style: GoogleFonts.kameron(
                          fontSize: isLandscape ? Responsive.font(context, mobile: 14, tablet: 16, desktop: 18)
                                    : Responsive.font(context, mobile: 15, tablet: 17, desktop: 19),
                          fontWeight: FontWeight.w500),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? Color.fromARGB(248, 233, 232, 232) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final bool isMobile = Responsive.isMobile(context);

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
                                    height: MediaQuery.of(context).size.height * 0.5,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            isSearching ? Icons.search_off : Icons.inventory_2_outlined,
                                            size: 45,
                                            color: Theme.of(context).colorScheme.surface,
                                          ),
                                          const SizedBox(height: 15),
                                          Text(
                                            _searchText.isNotEmpty ? 'No results found' : 'No products found',
                                            style: GoogleFonts.kameron(
                                              fontSize: isLandscape
                                              ? isDesktop ? 18 : isTablet ? 16 : 14
                                              : isDesktop ? 20 : isTablet ? 18 : 16,
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
                                  scrollDirection: Axis.vertical,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: constraints.maxWidth,
                                        maxWidth: isMobile ? double.infinity : constraints.maxWidth,
                                      ),
                                      child: DataTable(
                                        columnSpacing: isDesktop ? 35 : isTablet ? 30 : 25,
                                        headingRowHeight: isLandscape ? (isDesktop ? 40 : isTablet ? 35 : 30) :  (isDesktop ? 58 : isTablet ? 55 : 50),
                                        dataRowHeight: isLandscape ? (isDesktop ? 45 : isTablet ? 40 : 36) : (isDesktop ? 60 : isTablet ? 55 : 45),
                                        headingRowColor: MaterialStateProperty.all(const Color.fromARGB(228, 255, 255, 255)),
                                        columns: [
                                          DataColumn(label: Text('Product', style: tableTextStyle(
                                            fontSize: isLandscape ? (isDesktop ? 19 : isTablet ? 18 : 16) : (isDesktop ? 21 : isTablet ? 18 : 14.5), 
                                            fontWeight: FontWeight.w500))
                                            ),
                                          DataColumn(label: Text('Category', style: tableTextStyle(
                                            fontSize: isLandscape ? (isDesktop ? 19 : isTablet ? 18 : 16) : (isDesktop ? 21 : isTablet ? 18 : 14.5),  
                                            fontWeight: FontWeight.w500))
                                          ),
                                          DataColumn(label: Text('Stock', style: tableTextStyle(
                                            fontSize: isLandscape ? (isDesktop ? 19 : isTablet ? 18 : 16) : (isDesktop ? 21 : isTablet ? 18 : 14.5),  
                                            fontWeight: FontWeight.w500))
                                          ),
                                          DataColumn(label: Text('Status', style: tableTextStyle(
                                            fontSize: isLandscape ? (isDesktop ? 19 : isTablet ? 18 : 16) : (isDesktop ? 21 : isTablet ? 18 : 14.5),  
                                            fontWeight: FontWeight.w500))
                                          ),
                                          if(_userRole == 'admin')
                                          DataColumn(label: Text('Update', style: tableTextStyle(
                                            fontSize: isLandscape ? (isDesktop ? 19 : isTablet ? 18 : 16) : (isDesktop ? 21 : isTablet ? 18 : 14.5),  
                                            fontWeight: FontWeight.w500))
                                          ),
                                        ],
                                        rows: products.map((product) {
                                          return DataRow(cells: [
                                            DataCell(Text(capitalizeEachWord(product.name), style: tableTextStyle(
                                              fontSize: isLandscape ? (isDesktop ? 18 : isTablet ? 17 : 15) : (isDesktop ? 21 : isTablet ? 18 : 14) 

                                              ))
                                            ),
                                            DataCell(Text(capitalizeEachWord(product.category ?? 'Uncategorized'), style: tableTextStyle(
                                              fontSize: isLandscape ? (isDesktop ? 17 : isTablet ? 17 : 15) : (isDesktop ? 21 : isTablet ? 18 : 14)
                                              ))
                                              ),
                                            DataCell(Text(product.stock.toString(), style: tableTextStyle(
                                              fontSize: isLandscape ? (isDesktop ? 17 : isTablet ? 17 : 15) : (isDesktop ? 21 : isTablet ? 18 : 14)
                                              ))
                                              ),
                                            DataCell(
                                              Text(
                                                product.stock == 0 ? 'Out of Stock' : product.stock <= product.low_stock_alert! ? 'Low Stock' : 'In Stock',
                                                style: tableTextStyle(
                                                  fontSize: isLandscape ? (isDesktop ? 17 : isTablet ? 17 : 15) : (isDesktop ? 21 : isTablet ? 18 : 14),
                                                  fontWeight: FontWeight.w500,
                                                  color: product.stock == 0 ? Colors.red : product.stock <= product.low_stock_alert! ? const Color.fromARGB(255, 255, 165, 0) : Color.fromARGB(255, 21, 105, 0),
                                                ),
                                              ),
                                            ),
                                            if(_userRole == 'admin')
                                            DataCell(
                                              InkWell(
                                                onTap:  () => _openUpdateModal(product),
                                                borderRadius: BorderRadius.circular(6),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.edit,
                                                      size: isDesktop ? 22 : isTablet ? 20 : 18,
                                                      color: _userRole == 'admin'
                                                          ? const Color.fromARGB(255, 1, 68, 122)
                                                          : Colors.grey,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      "Update",
                                                      style: tableTextStyle(
                                                        fontSize: isLandscape ? (isDesktop ? 17 : isTablet ? 17 : 15) : (isDesktop ? 21 : isTablet ? 18 : 14),
                                                        color: _userRole == 'admin'
                                                            ? const Color.fromARGB(255, 1, 68, 122)
                                                            : Colors.grey,
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
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),

                     SizedBox(height: 60), 
                  ],
                ),
              ),
            ),
          ),

          // Fixed Pagination at the bottom
          if (_totalItems > 1)
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: const EdgeInsets.symmetric(vertical: 45),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
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
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage < _totalPages
                        ? () {
                            setState(() {
                              _currentPage++;
                            });
                            _loadProducts();
                          }
                        : null,
                  ),
                ],
              ),
            ),
        ],
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