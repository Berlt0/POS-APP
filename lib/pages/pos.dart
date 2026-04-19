import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/db/barcode.dart';
import 'package:pos_app/db/sync.dart';
import 'package:pos_app/db/syncTransationHistory.dart';
import 'package:pos_app/models/pos.dart';
import 'package:pos_app/db/pos.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pos_app/models/cartItem.dart';
import 'package:flutter/services.dart';
import 'package:pos_app/utils/responsive.dart';
import 'package:pos_app/pages/barcodeScanner.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();



class POS extends StatefulWidget {
  const POS({super.key});

  @override
  State<POS> createState() => _POSState();
}


class ProductCard extends StatelessWidget {
  final double width;
  final double height; 
  final String name;
  final double price;
  final int stock;
  final int quantity;
  final String imagePath;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const ProductCard({
    super.key,
    required this.width,   
    required this.height,
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

    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final double borderRadius = Responsive.spacing(context, mobile: 14, tablet: 16, desktop: 18);
    
    return SizedBox(
      width: width,
      height: height,
      child: Card(
        elevation: 3,
        color: quantity > 0 ? const Color(0xFF00E6FF)  : stock == 0 ?  Color.fromARGB(221, 238, 85, 87) : isDark ? Color.fromARGB(209, 49, 49, 49) : Colors.grey[200],
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
                    context: context,
                    name: 'remove',
                    icon: Icons.remove,
                    onTap: quantity > 0 ? onRemove : null,
                    size: isDesktop ? 35 : isTablet ? 30 : 20,
                    
                  ),
                  Text(
                    quantity.toString(),
                    style: GoogleFonts.kameron(fontWeight: FontWeight.bold, 
                    fontSize: isDesktop ? 22 : isTablet ? 20 : 15,
                    color: quantity > 0 ? Colors.black : Theme.of(context).colorScheme.onSurface,)
                  ),
                  _circleButton(
                    context: context,
                    name: 'add',
                    icon: Icons.add,
                    onTap: stock > quantity ? onAdd : null,
                    size: isDesktop ? 35 : isTablet ? 30 : 20,
                  ),
                ],
              ),
      
              const SizedBox(height: 15),
      
              //Product Image
              Expanded(
                  child: Stack(
                    children: [ 
                    ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadius - 2),
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
      
      
      
                        if (stock == 0)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "OUT OF STOCK",
                                style: GoogleFonts.kameron(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                ],
                ), 
              ),
      
              const SizedBox(height: 6),
      
              //Product Info
              Text(
                capitalizeEachWord(name),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.kameron(
                  fontWeight: FontWeight.bold,
                  fontSize: isDesktop ? 22 : isTablet ? 19 : 14,
                  color: quantity > 0 ? Colors.black : Theme.of(context).colorScheme.onSurface
                ),
              ),
              Text(
                '₱${price.toStringAsFixed(2)}',
                style: GoogleFonts.kameron(
                  fontSize: isDesktop ? 21 : isTablet ? 18 : 13,
                  color: quantity > 0 ? const Color.fromARGB(255, 1, 54, 3) : const Color.fromARGB(255, 43, 155, 47)   ,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Stock: $stock',
                style: GoogleFonts.kameron(
                  fontSize: isDesktop ? 20.5 : isTablet ? 17.5 : 12.5,
                  color:  quantity > 0 ? Colors.black : Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500
                ),
              ),
      
      
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleButton({
    required BuildContext context,
    required IconData icon,
    VoidCallback? onTap,
    String? name,
    double size = 20}) {
    
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: onTap == null ? Colors.grey[300] : Colors.white
        ),
        child: Icon(icon, size: size, color:  (onTap == null && name == 'remove') ||  (onTap == null && name == 'add')? Colors.white : Colors.black),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

      if (!mounted) return;

      setState(() {
        products = dbProducts.map((p) => _POSItem(product: p)).toList();
        categories = ['All', ...catSet];
        isLoading = false;
      });
    } catch (error) {
      debugPrint("POS load error: $error");
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  int getTotalQuantity() => products.fold(0, (total, item) => total + item.qty);

  double getSubTotal() =>
      products.fold(0.0, (total, item) => total + (item.product.price * item.qty));

  double getTotal() => getSubTotal();



  void addToCart(POSModel product) {
  try {
    // Try to find existing item
    final existingItem = products.firstWhere(
      (item) => item.product.id == product.id,
    );

    // Product already exists, increment qty
    setState(() {
      if (existingItem.qty < (product.stock ?? 0)) {
        existingItem.qty++;
      }
    });
  } catch (e) {
    // Not found → add new
    setState(() {
      products.add(_POSItem(product: product, qty: 1));
    });
  }
}

  @override
  Widget build(BuildContext context) {


    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    final isMobile = Responsive.isMobile(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;


    final crossAxisCount = isDesktop ? 4 : isTablet ? 3 : 2;
    final cardWidth = (screenWidth - 16 * (crossAxisCount + 1)) / crossAxisCount;
    final cardHeight = cardWidth * 1.35; // adjust as needed


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
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
         backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        shadowColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
        elevation: 3,
       toolbarHeight: isDesktop ? 80 : isTablet ? 70 : 60,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_sharp,size: isDesktop ? 35 : isTablet ? 30 :25),   // or Icons.arrow_back
            iconSize: Responsive.spacing(context, mobile: 28, tablet: 32, desktop: 36), 
            onPressed: () => Navigator.pop(context),
            tooltip: 'Back',
          ),
      
          leadingWidth: 50,  
        title: Text(
            "POS",
            style: GoogleFonts.kameron(
              fontSize: isDesktop ? 22 : isTablet ? 20 :18,
              fontWeight: FontWeight.bold,
            ),
          ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// SEARCH + SCAN
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      style: GoogleFonts.kameron(
                          fontSize:  Responsive.font(context,mobile: 17, tablet: 20, desktop: 30),
                          color: Colors.black
                        ),
                      controller: _searchController,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
                        ],
                      onChanged: (value) {
                        if (!mounted) return;
                        setState(() {
                          _searchText = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search for...',
                        hintStyle: GoogleFonts.kameron(fontSize: Responsive.font(context,mobile: 15, tablet: 18, desktop: 20), fontWeight: FontWeight.w500,color: Colors.black87),
                        prefixIcon: Icon(Icons.search, size: Responsive.font(context,mobile: 25, tablet: 28, desktop: 30),color: Colors.black87,),
                         suffixIcon: _searchText.isNotEmpty
                          ? IconButton(
                              icon:  Icon(Icons.clear, size: Responsive.font(context,mobile: 20, tablet: 25, desktop: 30),color: Colors.black87,),
                              onPressed: () {
                                if (!mounted) return;
                                setState(() {
                                  _searchController.clear();
                                  _searchText = '';
                                });
                              },
                            )
                          : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(color: Colors.black, width: 1),
                        ),
                        fillColor: Colors.white,
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BarcodeScannerPage(
                              onDetect: (barcode) async {
                                debugPrint("Scanned barcode: $barcode");

                              final productMap = await Barcode.getProductByBarcode(barcode);

                              if (productMap != null) {
                                
                          
                                final product = POSModel.fromMap(productMap);

                                addToCart(product); 

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Added: ${product.name}")),
                                );
                                
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Product not found")),
                                );
                              }
                            },
                            ),
                          )
                        );
                      },
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
                          const Icon(Icons.barcode_reader, color: Colors.black,size: 22,),
                          const SizedBox(width: 5),
                          Text(
                            "Scan",
                            style: GoogleFonts.kameron(
                                fontSize: Responsive.font(context, mobile: 16, tablet: 18, desktop: 19),
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
        
              const SizedBox(height: 20),
        
              /// CATEGORIES
              if(products.isNotEmpty)
              SizedBox(
                height: isDesktop ? 55 : isTablet ? 50 : 40,
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
                          fontSize: isDesktop ? 20 : isTablet ? 18 : 14,
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
                child:  filteredProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_searchText.isNotEmpty
                            ? Icons.search_off
                            : Icons.storefront_outlined,
                            size: 60,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            _searchText.isNotEmpty
                                ? 'No products found'
                                : 'No products available', 
                            style: GoogleFonts.kameron(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: cardWidth / cardHeight,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final item = filteredProducts[index];
        
                    return ProductCard(
                      width: cardWidth,
                      height: cardHeight,
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
        
              
              Center(
                child: Container(
                  width: isDesktop ? 580 : isTablet ? 530 : double.infinity,
                  height: isDesktop ? 150 : isTablet ? 140 : 130,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                      color: const Color(0xFF00E6FF),
                      borderRadius: BorderRadius.circular(12)),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface, 
                        borderRadius: BorderRadius.circular(12)),
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
                                    "Total Quantity", getTotalQuantity().toString(), fontSize: isDesktop ? 20 : isTablet ? 18 : 14),
                                _rowText("Subtotal", "₱${getSubTotal().toStringAsFixed(2)}",fontSize: isDesktop ? 20 : isTablet ? 18 : 14),
                                const SizedBox(height: 2),
                                _rowText(
                                  "Total",
                                  "₱${getTotal().toStringAsFixed(2)}",
                                  isBold: true,
                                  fontSize: isDesktop ? 22 : isTablet ? 20 : 15,
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
                                    minimumSize: Size(double.infinity, isMobile ? 40 : 45),
                                  ),
                                  onPressed: () async{
                                    
                                   if(getTotalQuantity() == 0){
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Cart is empty! Please select a product to proceed.'),
                                          backgroundColor: Colors.red,
                                          behavior: SnackBarBehavior.floating,
                                          margin: EdgeInsets.only(
                                            top: MediaQuery.of(context).padding.top + 16,
                                            left: 16,
                                            right: 16,
                                          ),
                                          duration: Duration(seconds: 3),
                                                              
                                        ),
                                      );
        
                                      return;
                                    }
        
                                    final cartItems = products
                                        .where((item) => item.qty > 0)
                                        .map((item) => CartItem(
                                              productId: item.product.id!,
                                              productGlobalId: item.product.global_id!,
                                              name: item.product.name,
                                              price: item.product.price,
                                              quantity: item.qty,
                                              imagePath: item.product.image_path ?? '',
                                            ))
                                        .toList();
        
                                    final transactionId = await Navigator.pushNamed(
                                      context,
                                      '/reviewcart',
                                      arguments:{
                                        'items': cartItems,
                                        'subtotal': getSubTotal(),
                                        'total': getTotal(),
                                        'totalQuantity': getTotalQuantity(),
                                      }, );

                                    if(transactionId != null){

                                      await Navigator.pushNamed(context, '/receipt',arguments: transactionId);

                                      if (!mounted) return;

                                      await syncSales();
                                      await syncTransaction();

                                      if (!mounted) return;

                                      setState(() {
                                        for (final item in products) {
                                          item.qty = 0;
                                        }
                                      });

                                      await _loadProducts();
                                      
                                  }
                                  },
        
                                  child: Center(
                                    child: SizedBox(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                           Icon(Icons.shopping_cart_checkout_outlined,
                                              color: Colors.black,
                                              size: isDesktop ? 26 : isTablet ? 23 : 18),
                                          SizedBox(width: 5,),
                                          Text(
                                            "Checkout",
                                            style: GoogleFonts.kameron(
                                                color: Colors.black,
                                                fontSize: isDesktop ? 20 : isTablet ? 18 : 15,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: isMobile ? 3 : 8,),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEE5558),
                                    minimumSize: Size(double.infinity, isMobile ? 40 : 45),
                                  ),
                                  onPressed: () {
                                    if (!mounted) return;
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
                                        Icon(Icons.remove_shopping_cart_outlined, color: Colors.black,size: isDesktop ? 26 : isTablet ? 23 : 18,),
                                        SizedBox(width: 5,),
                                        Text(
                                          "Clear Cart",
                                          style: GoogleFonts.kameron(
                                              color: Colors.black,
                                              fontSize: isDesktop ? 20 : isTablet ? 18 : 15,
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
      ),
    );
  }
}

String capitalizeEachWord(String text) {
  return text
      .split(' ')
      .map((word) =>
          word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' : '')
      .join(' ');
}