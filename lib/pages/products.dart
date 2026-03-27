import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos_app/db/sync.dart';
import 'package:pos_app/widgets/footer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/db/product.dart';
import 'package:pos_app/models/products.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pos_app/db/user.dart';
import 'package:flutter/cupertino.dart';

class Products extends StatefulWidget {
  const Products({super.key});

  @override
  State<Products> createState() => _ProductsState();
}


class _ProductsState extends State<Products> {

  TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  TextEditingController _productNameController = TextEditingController();
  TextEditingController _productCategoryController = TextEditingController();
  TextEditingController _barcodeController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _costController = TextEditingController();
  TextEditingController _stockAlertController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  File? selectedImage;
  String stockUnit = 'pcs'; 

  List<String> _categories = ['All']; 
  String _selectedCategory = 'All';
  

  final ImagePicker _picker = ImagePicker();
  File? _editedImage;
  File? _originalImage;


  late Future<List<Product>> _productsFuture;

  String? _userRole;
  


  
 @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadRole();

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });   

  }



  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }



  Future<void> _loadRole() async {
  final role = await UserDB().getLoggedInUserRole();
  setState(() {
    _userRole = role;
  });
}


  String toTitleCase(String text) {
  if (text.isEmpty) return text;
  return text
      .split(' ')
      .map((word) => word.isNotEmpty
          ? word[0].toUpperCase() + word.substring(1).toLowerCase()
          : '')
      .join(' ');
}



// Picking image for edit image

Future<void> _pickImage(void Function(void Function()) modalSetState) async {
  showModalBottomSheet(
    context: context,
    builder: (_) => SizedBox(
      height: 120,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () async {
              final XFile? newImage =
                  await _picker.pickImage(source: ImageSource.gallery);
              if (newImage != null) {
                modalSetState(() {
                  _editedImage = File(newImage.path);
                });
              }
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take a Photo'),
            onTap: () async {
              final XFile? newImage =
                  await _picker.pickImage(source: ImageSource.camera);
              if (newImage != null) {
                modalSetState(() {
                  _editedImage = File(newImage.path);
                });
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}




// Saving image path

  Future<String> saveImageLocally(File image) async {
  final dir = await getApplicationDocumentsDirectory();
  final newPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.png';
  final newImage = await image.copy(newPath);
  return newImage.path;
}




void _loadProducts() {
   _productsFuture = ProductDB.getAllActiveProducts();
  _productsFuture.then((list) {
    print("Products loaded: ${list.length}");
    
    final Set<String> uniqueCategories = list
        .map((p) => p.category ?? 'Others')
        .toSet(); 
        final List<String> sortedCategories = uniqueCategories.toList()..sort();
    setState(() {
      _categories = ['All', ...uniqueCategories];
    });
  });
}





Future<void> _saveEditedProduct(Product originalProduct) async {
  try {
  
    String? imagePath = originalProduct.imagePath;

    if (_editedImage != null &&
        (_originalImage == null ||
            _editedImage!.path != _originalImage!.path)) {
      imagePath = await saveImageLocally(_editedImage!);
    }

    
    final updatedProduct = editProduct(
      id: originalProduct.id,
      name: _productNameController.text.trim(),
      category: _productCategoryController.text.trim(),
      price: double.tryParse(
            _priceController.text.replaceAll('₱', '').trim(),
          ) ?? 0,
      cost: double.tryParse(
            _costController.text.replaceAll('₱', '').trim(),
          ) ?? 0,
      stock: originalProduct.stock, // inventory stock is separate
      lowStockAlert: int.tryParse(_stockAlertController.text),
      description: _descriptionController.text.trim(),
      image_path: imagePath,
    );

    await ProductDB.updateProduct(updatedProduct);

    Navigator.pop(context);
    await syncProducts();

     ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product updated successfully',),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        )
    );

    setState(() {
      _loadProducts();
    });
  } catch (error) {
    debugPrint("Save error: $error");
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update product'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);

  }
}



Future<bool?> showConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text('Confirm Update',
        style: GoogleFonts.kameron(
          fontSize: 21,
          fontWeight: FontWeight.w500
        ),),
        content: Text('Are you sure you want to save the changes?',
        style: GoogleFonts.kameron(
          fontSize: 17,
          fontWeight: FontWeight.normal
        ),),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',style: GoogleFonts.kameron(
              fontSize: 15,
              fontWeight: FontWeight.w500
            ),),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(100,40),
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                ),
                shadowColor: Colors.grey[800]
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Save',
            style: GoogleFonts.kameron(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white
            ),),
          ),
        ],
      );
    },
  );
}



Future<bool?> showDeleteConfirmationModal(BuildContext context) {
  return showGeneralDialog<bool>(
    context: context,
    barrierLabel: "Delete Product",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      return Center(
        child: Material(
          type: MaterialType.transparency,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Text(
                    "Delete Product?",
                    style: GoogleFonts.kameron(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,

                    ),
                  ),
                  const SizedBox(height: 10),
                       Text(
                        "Are you sure you want to delete this product?",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.kameron(
                          fontSize: 15,
                          fontWeight: FontWeight.w500
                      
                        ),
                      ),
                  
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                     
                        GestureDetector(
                          onTap: () { 
                            Navigator.of(context).pop(false); 
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("No", style: GoogleFonts.kameron(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w500
                            )),
                          ),
                        ),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(true); 
                        },
                        child:  Text("Yes", style: GoogleFonts.kameron(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500
                        ),),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return ScaleTransition(
        scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
        child: child,
      );
    },
  );
}



// Usage inside your state:
void _openDeleteConfirmationModal(int productId) async {
  print(productId);
  final confirmed = await showDeleteConfirmationModal(context);

  if (confirmed == true) {
    
    await ProductDB.archiveProduct(productId);
    // await _loadProducts();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product deleted successfully'),
        backgroundColor: Colors.red,
      ),
    );
  }
}






void _openEditModal(Product product){

  _productNameController.text = capitalizeEachWord(product.name);
  _productCategoryController.text = product.category ?? "";
  _priceController.text = product.price.toString();
  _costController.text = product.cost.toString();
  _stockAlertController.text = product.lowStockAlert.toString();
  _descriptionController.text = product.description ?? "";

_originalImage = product.imagePath != null
    ? File(product.imagePath!)
    : null;

_editedImage = _originalImage;

final autocompleteCategories = _categories.where((c) => c != 'All').toList();


  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20))
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, modalSetState) {
        return Padding( 
          padding:EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView( 
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Edit Product",
                  style: GoogleFonts.kameron(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black
                  ),),
                  SizedBox(height: 15,),
                  GestureDetector(
                  onTap: () => _pickImage(modalSetState),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _editedImage != null
                            ? Image.file(
                                _editedImage!,
                                width: 190,
                                height: 160,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/Legendaries.png',
                                width: 190,
                                height: 160,
                                fit: BoxFit.cover,
                              ),
                      ),
        
                      /// Edit icon overlay
                      Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
        
                SizedBox(height: 30,),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                     
                         TextFormField(
                          controller: _productNameController,
                          decoration: InputDecoration(
                            labelText: 'Product',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (value) {},),
        
                          SizedBox(height: 15,),
                          
                          Autocomplete<String>(
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              if (textEditingValue.text.isEmpty) {
                                return const Iterable<String>.empty();
                              }
                              return autocompleteCategories.where((category) => 
                                  category.toLowerCase().contains(textEditingValue.text.toLowerCase())
                              );
                            },
                            displayStringForOption: (option) => option,
                            fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                              // controller.text = _productCategoryController.text;
                              // controller.selection = TextSelection.fromPosition(
                              //   TextPosition(offset: controller.text.length)
                              // );
                              // controller.addListener(() {
                              //   _productCategoryController.text = controller.text;
                              // });
                              controller.value = TextEditingValue(
                                text: _productCategoryController.text,
                                selection: TextSelection.fromPosition(
                                  TextPosition(offset: _productCategoryController.text.length),
                                ),
                              );
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                onEditingComplete: onEditingComplete,
                                decoration: InputDecoration(
                                  labelText: 'Category',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                ),
                              );
                            },
                            onSelected: (selection) {
                              _productCategoryController.text = selection;
                            },
                          ),
                                  
                          SizedBox(height: 15,),
                          
                          TextFormField(
                          controller: _priceController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                          ],
                          keyboardType: TextInputType.numberWithOptions(decimal: true),                
                          decoration: InputDecoration(
                            labelText: 'Price',
                            prefixText: '₱ ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (value) {},),
        
                          SizedBox(height: 15,),
                          
                          TextFormField(
                          controller: _costController,
                         inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                          ],
                          keyboardType: TextInputType.numberWithOptions(decimal: true),  
                          decoration: InputDecoration(
                            labelText: 'Cost',
                            prefixText: '₱ ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (value) {},),
        
                          SizedBox(height: 15,),
                          
                          TextFormField(
                          controller: _stockAlertController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],       
                          decoration: InputDecoration(
                            labelText: 'Stock Alert Level',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
        
                          ),
                          onChanged: (value) {},),
                          
                          SizedBox(height: 15,),
                          
                          TextFormField(
                          controller: _descriptionController,    
                          decoration: InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (value) {},),
                          
                          
                        
                      ],
                    )
                  ],
                ),
                SizedBox(height: 20,),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(200,40),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)
                    ),
                    shadowColor: Colors.grey[800]
                  ),
                  onPressed: () async{

                     FocusScope.of(context).unfocus();

                    if(_productNameController.text.trim().isEmpty || _productCategoryController.text.trim().isEmpty || _priceController.text.trim().isEmpty || _costController.text.trim().isEmpty || _stockAlertController.text.trim().isEmpty ){
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text('Invalid Input',
                          style: GoogleFonts.kameron(
                            fontSize: 21,
                            fontWeight: FontWeight.w500,
                          
                          ),),
                          content: Text('Required fields must not be empty.',
                          style: GoogleFonts.kameron(
                            fontSize: 17,
                            fontWeight: FontWeight.normal
                          ),),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: Text('OK',
                            style: GoogleFonts.kameron(
                              fontSize: 15,
                              fontWeight: FontWeight.normal
                            ),))
                          ],
                        ),
                      );
                      return;
                    }

                    final confirmed = await showConfirmationDialog(context);
                  
                    if(confirmed == true){
                      
                      await _saveEditedProduct(product);
                    
                    }

                  } ,
                  child: Text(
                    "Save",
                    style: GoogleFonts.kameron(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.white
                    ),
                    
                  ))
                  ,const SizedBox(height: 30),
              ],
            ),
          ), 
          );
        }
      );
    }
  
    ).whenComplete(() {
  setState(() {
    _editedImage = _originalImage;
  });
});

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
      color: product.stock == 0 ? Colors.red[100] : Colors.white,
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
                  toTitleCase(product.name),
                  style: GoogleFonts.kameron(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '₱${product.price.toStringAsFixed(2)}',
                  style: GoogleFonts.kameron(
                    fontSize: 14,
                    color: Colors.grey[900],
                  ),
                ),
                Text(
                  'Stock: ${product.stock}',
                  style: GoogleFonts.kameron(
                    fontSize: 14,
                    color: Colors.grey[900],
                  ),
                ),
              ],
            ),
          ],
        ),

        /// RIGHT SIDE
        Row(
          children: [
            if (_userRole == 'admin') ...[
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () => _openEditModal(product),
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                onPressed: () =>_openDeleteConfirmationModal(product.id!),
              ),
            ],
          ],
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
                      ],
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
                      items:_categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
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

                   if (products.isEmpty) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_mall_outlined,
                                size: 45,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 15),
                              Text(
                                'No products available',
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

                  List<Widget> productWidgets = [];
                  

                  final filtered = products.where((product) {
                  final matchesCategory = _selectedCategory == 'All' ||
                      product.category == _selectedCategory;
                  final matchesSearch = product.name.toLowerCase().contains(_searchText);
                  return matchesCategory && matchesSearch;
                }).toList();


                  if (_searchText.isEmpty) {
                    // No search: group by category
                    final Map<String, List<Product>> grouped = {};
                    for (var product in products) {
                      if (_selectedCategory != 'All' &&
                          product.category != _selectedCategory) continue;

                      final category = product.category ?? 'Others';
                      grouped.putIfAbsent(category, () => []);
                      grouped[category]!.add(product);
                    }

                    productWidgets = grouped.entries.map((entry) {
                      final category = entry.key;
                      final productsInCategory = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          categoryHeader(category),
                          ...productsInCategory.map((product) => productCard(product)),
                        ],
                      );
                    }).toList();
                  } else {
                    // Search active: ignore category grouping
                    productWidgets = filtered.map((product) => productCard(product)).toList();
                    if (productWidgets.isEmpty) {
                      productWidgets = [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              "No products found",
                              style: GoogleFonts.kameron(fontSize: 16, color: Colors.grey[700]),
                            ),
                          ),
                        ),
                      ];
                    }
                  }

                  return ListView(children: productWidgets);

                },
              ),
            ),
            ],
          ),
        ),
        floatingActionButton: (_userRole != 'admin') ? SizedBox.shrink()  :  FloatingActionButton(
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

String capitalizeEachWord(String text) {
  return text
      .split(' ')
      .map((word) =>
          word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' : '')
      .join(' ');
}
