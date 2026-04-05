import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pos_app/db/product.dart';
import 'package:pos_app/db/sync.dart';
import 'package:pos_app/models/products.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:pos_app/utils/responsive.dart';

class Addproduct extends StatefulWidget {
  const Addproduct({super.key});

  @override
  State<Addproduct> createState() => _POSState();
}

class ProductFormState {

    TextEditingController productName = TextEditingController();
    TextEditingController productCategory = TextEditingController();
    TextEditingController barcode = TextEditingController();
    TextEditingController price = TextEditingController();
    TextEditingController cost = TextEditingController();
    TextEditingController quantity = TextEditingController();
    TextEditingController stockAlert = TextEditingController();
    TextEditingController description = TextEditingController();

    File? selectedImage;
    String stockUnit = 'pcs';
}



class _POSState extends State<Addproduct> {


  final List<String> _units = ['pcs', 'liter', 'kg', 'meter'];
  
  List<String> _categories = [];
  bool _isLoading = false;

  late StreamSubscription<dynamic> _connectivitySubscription;


  Future<void> loadCategoriesFromProducts() async {
    final allProducts = await ProductDB.getAllActiveProducts(); 
    final categorySet = <String>{};

    for (var product in allProducts) {
      if (product.category != null && product.category!.isNotEmpty) {
        categorySet.add(product.category!); 
      }
    }

    if(!mounted) return;
    setState(() {
      _categories = categorySet.toList(); 
    });
  }

  @override
  void initState() {
    super.initState();
    loadCategoriesFromProducts();

     _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
    if(result != ConnectivityResult.none){
      print("Internet detected. Syncing...");
      syncProducts();
    }
  });
  }

  @override
void dispose() {
  _connectivitySubscription.cancel(); 
  super.dispose();
}


  List<ProductFormState> forms = [ProductFormState()];
  // final ImagePicker _picker = ImagePicker();
  final int maxProductsPerSave = 5;


  Future<String> saveImageLocally(File image) async {
  final dir = await getApplicationDocumentsDirectory();
  final newPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.png';
  final newImage = await image.copy(newPath);
  return newImage.path;
}

  Future<void> _pickImage(int index) async {
  final ImagePicker picker = ImagePicker();

      showModalBottomSheet(
        context: context,
        builder: (_) => Container(
          height: 130,
          padding: EdgeInsetsDirectional.symmetric(horizontal: 13),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () async {
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  if(!mounted) return;
                  if (image != null) {
                    setState(() {
                      forms[index].selectedImage = File(image.path);
                    });
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a Photo'),
                onTap: () async {
                  final XFile? image = await picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    setState(() {
                      forms[index].selectedImage = File(image.path);
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

void addNewForm() {

   if (forms.length >= maxProductsPerSave) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("You can only add $maxProductsPerSave products before saving!"),
        duration: Duration(seconds: 2),
      ),
    );
    return; 
  }

  setState(() {
    forms.add(ProductFormState());
  });
}

Future<void> _saveProducts() async {

  for (var form in forms){
    
      if (form.productName.text.isEmpty || form.price.text.isEmpty || form.quantity.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all required fields"))
      );
      return;
    }

    
    double price = double.tryParse(form.price.text) ?? 0;
    double? cost = form.cost.text.isNotEmpty ? double.tryParse(form.cost.text) : null;
    int stock = int.tryParse(form.quantity.text) ?? 0;
    int? lowStock = form.stockAlert.text.isNotEmpty ? int.tryParse(form.stockAlert.text) : 10;

    // Save image locally
    String? imagePath;
    if (form.selectedImage != null) {
      imagePath = await saveImageLocally(form.selectedImage!);
    }

    final productName = form.productName.text.trim().toLowerCase();
    final productCategory = form.productCategory.text.trim().toLowerCase();
    final barcode = form.barcode.text.trim();
    final description = form.description.text.trim().toLowerCase();

    final formattedCategory = productCategory.isNotEmpty
    ? productCategory[0].toUpperCase() + productCategory.substring(1).toLowerCase()
    : null;

    // Create Product object
    final product = Product(
      name: productName,
      price: price,
      stock: stock,
      cost: cost,
      category: formattedCategory,
      barcode: barcode.isNotEmpty ? barcode: null,
      lowStockAlert: lowStock,
      description: description.isNotEmpty ? description : null,
      imagePath: imagePath,
      createdAt: DateTime.now().toIso8601String(),
      lastUpdate: DateTime.now().toIso8601String(),
    );


    await ProductDB.insert(product);
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Products added successfully!"))
  );


  // Clear form
  setState(() {
    forms = [ProductFormState()]; // reset to one form
  });
  
}

Widget productFormWidget(int index) {

    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final isDesktop = Responsive.isDesktop(context);

  final form = forms[index];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Product ${index + 1}", 
              style: GoogleFonts.kameron(
              fontSize: isDesktop ? 25 : isTablet ? 22 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.black
            )),
              forms.length > 1
              ? IconButton(
                  icon:  Icon(Icons.close, color: Colors.red , size: isDesktop ? 34 : isTablet ? 32 : 30 ,),
                  onPressed: () {
                    showGeneralDialog(
                      context: context,
                      barrierLabel: "Remove Product",
                      barrierDismissible: true,
                      barrierColor: Colors.black.withOpacity(0.5),
                      transitionDuration: const Duration(milliseconds: 300),

                      pageBuilder: (context, anim1, anim2) {
                        return Center(
                          child: Material(
                            type: MaterialType.transparency,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: isDesktop ? 380 : isTablet ? 350 : 270,
                              ),
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
                                      "Remove Product?",
                                      style: GoogleFonts.kameron(
                                        fontSize: isDesktop ? 21 : isTablet ? 20 : 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 7),
                                    Text(
                                      "Are you sure you want to remove this product?",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.kameron(
                                        fontSize:  isDesktop ? 20 : isTablet ? 18 : 14.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 45),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        GestureDetector(
                                          onTap: () => Navigator.pop(context),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "Cancel",
                                              style: GoogleFonts.kameron(
                                                fontSize:  isDesktop ? 21 : isTablet ? 18 : 15,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),

                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                                            backgroundColor: Colors.red,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              forms.removeAt(index);
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            "Remove",
                                            style: GoogleFonts.kameron(
                                              fontSize: isDesktop ? 21 : isTablet ? 19 : 15,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
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
                  },
                )
              : SizedBox(),

            ],
          ),
            
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5,),
                      Text(
                        "Product Name",
                        style: GoogleFonts.kameron(
                          fontSize: isDesktop ? 21 : isTablet ? 19 : 15,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      SizedBox(height: 5,),
                      TextField(
                         style: GoogleFonts.kameron(
                            fontSize: isDesktop ? 22 : isTablet ? 20 : 16
                          ),  
                        controller: form.productName,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
                        ],
                        decoration: InputDecoration(
                          hintText: '(ex. Nova)',
                          hintStyle: TextStyle(fontSize: isDesktop ? 19 : isTablet ? 16 : 14 ,color: Colors.grey[700],fontStyle: FontStyle.italic),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            fillColor: Colors.grey[100],
                            filled: true,
                            contentPadding: EdgeInsets.symmetric(vertical: isDesktop ? 18 : isTablet ? 16 : 10, horizontal: 13)
                        ),
                        
                      ),
                      SizedBox(height: 10,),
                      Text(
                        "Category",
                        style: GoogleFonts.kameron(
                          fontSize:  isDesktop ? 21 : isTablet ? 19 : 15,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      SizedBox(height: 5,),
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }

                          return _categories.where((category) =>
                            category.toLowerCase().contains(textEditingValue.text.toLowerCase())
                          );
                        },
                        displayStringForOption: (option) => option,
                        fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                          form.productCategory = controller;
                          return TextField(
                            controller: controller,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
                            ],
                            focusNode: focusNode,
                            onEditingComplete: onEditingComplete,
                            decoration: InputDecoration(
                              hintText: '(ex. Snacks)',
                              hintStyle:  TextStyle(fontSize: isDesktop ? 19 : isTablet ? 16 : 14 ,color: Colors.grey[700],fontStyle: FontStyle.italic),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              fillColor: Colors.grey[100],
                              filled: true,
                              contentPadding: EdgeInsets.symmetric(vertical: isDesktop ? 18 : isTablet ? 16 : 10, horizontal: 13),
                            ),
                          );
                        },
                        onSelected: (selection) {
                          form.productCategory.text = selection;
                        },
                      ),


                      SizedBox(height: 10,),
                      Text(
                        "Barcode (optional)",
                        style: GoogleFonts.kameron(
                          fontSize: isDesktop ? 21 : isTablet ? 19 : 15,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      SizedBox(height: 5,),
                      TextField(
                        controller: form.barcode,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
                        ],
                        decoration: InputDecoration(
                          hintStyle: GoogleFonts.kameron(fontSize: isDesktop ? 19 : isTablet ? 16 : 14 ,color: Colors.grey[700],fontStyle: FontStyle.italic),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            fillColor: Colors.grey[100],
                            filled: true,
                            contentPadding: EdgeInsets.symmetric(vertical: isDesktop ? 18 : isTablet ? 16 : 10, horizontal: 13),// MUST
                            suffixIcon: Container(
                              padding: EdgeInsetsDirectional.symmetric(vertical: isDesktop ? 4 : isTablet ? 3 : 2,horizontal:  isDesktop ? 10 : isTablet ? 7 : 5), 
                              decoration: BoxDecoration(
                                
                                color: Color(0xFF00E6FF),
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 99, 98, 98)
                                ),
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(isDesktop ? 7 : isTablet ? 10 : 10),
                                  bottomRight: Radius.circular(isDesktop ? 7 : isTablet ? 10 : 10)
                                )
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.qr_code_scanner, // or Icons.qr_code for barcode
                                  color: Colors.black ,size: isDesktop ? 32 : isTablet ? 30 : 25,
                                ),
                                onPressed: () {
                                  // TODO: add your barcode generation/scanner logic here
                                  print("Generate barcode or scan");
                                },
                              ),
                            ),
                        ),
                      ),
                      
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Product Image",
                        style: GoogleFonts.kameron(
                          fontSize:  isDesktop ? 21 : isTablet ? 19 : 15,
                        ),
                      ),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () => _pickImage(index), // open gallery when tapped
                        child: Container(
                          width: isDesktop ? 190 : isTablet ? 180 : 130,
                          height: isDesktop ? 170 : isTablet ? 160 : 130,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: form.selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.file(
                                    form.selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  Icons.camera_alt,
                                  size: isDesktop ? 60 : isTablet ? 55 : 45,
                                  color: Colors.grey[700],
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Tap to select image",
                        style: GoogleFonts.kameron(fontSize: isDesktop ? 18 : isTablet ? 16 : 14, color: Colors.grey[900]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                          "Price",
                          style: GoogleFonts.kameron(
                            fontSize:  isDesktop ? 21 : isTablet ? 19 : 15,
                            fontWeight: FontWeight.w500
                        ),
                        ),
                        SizedBox(height: 5,),
                        TextField(
                          controller: form.price,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]+\.?[0-9]{0,2}')),
                          ],
                          decoration: InputDecoration(
                            hintText: '(ex. 20)',
                            hintStyle: TextStyle(fontSize: isDesktop ? 19 : isTablet ? 16 : 14 ,color: Colors.grey[700],fontStyle: FontStyle.italic), 
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              fillColor: Colors.grey[100],
                              filled: true,
                              contentPadding: EdgeInsets.symmetric(vertical: isDesktop ? 18 : isTablet ? 16 : 10, horizontal: 13)
                          ),
                        ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10,),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                          "Cost (optional)",
                          style: GoogleFonts.kameron(
                            fontSize:  isDesktop ? 21 : isTablet ? 19 : 15,
                            fontWeight: FontWeight.w500
                        ),
                        ),
                        SizedBox(height: 5,),
                        TextField(
                          controller: form.cost,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]+\.?[0-9]{0,2}')),
                          ],
                          decoration: InputDecoration(
                              hintText: '(ex. 15)',
                              hintStyle: TextStyle(fontSize: isDesktop ? 19 : isTablet ? 16 : 14 ,color: Colors.grey[700],fontStyle: FontStyle.italic),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              fillColor: Colors.grey[100],
                              filled: true,
                              contentPadding: EdgeInsets.symmetric(vertical: isDesktop ? 18 : isTablet ? 16 : 10, horizontal: 10)
                          ),
                        ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
            SizedBox(height: 12,),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                          "Stock Quantity",
                          style: GoogleFonts.kameron(
                            fontSize:  isDesktop ? 21 : isTablet ? 19 : 15,
                            fontWeight: FontWeight.w500
                        ),
                        ),
                        SizedBox(height: 5,),
                        TextField(
                          controller: form.quantity,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                          decoration: InputDecoration(
                            hintText: '(ex. 12)',
                            hintStyle: TextStyle(fontSize: isDesktop ? 19 : isTablet ? 16 : 14 ,color: Colors.grey[700],fontStyle: FontStyle.italic),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              fillColor: Colors.grey[100],
                              filled: true,
                              contentPadding: EdgeInsets.symmetric(vertical: isDesktop ? 18 : isTablet ? 16 : 10, horizontal: 10),
                              suffixIcon: Container(
                                padding: EdgeInsets.symmetric(horizontal: 5, vertical: isDesktop ? 3 : isTablet ? 2 : 1 ),
                                decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 99, 98, 98)
                                ),
                                color: Color(0xFF00E6FF),
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(isDesktop ? 7 : isTablet ? 10 : 10),
                                  bottomRight: Radius.circular(isDesktop ? 7 : isTablet ? 10 : 10),
                                ),
                              ),
                              child: DropdownButton<String>(
                                value: form.stockUnit,
                                padding: EdgeInsets.only(top: isDesktop ? 8 : isTablet ? 5 : 0),
                                underline: SizedBox(), 
                                icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                                dropdownColor: Colors.white,
                                items:  _units.map((unit) {
                                  return DropdownMenuItem<String>(
                                    value: unit,
                                    child: Text(
                                      unit,
                                      style: GoogleFonts.kameron(
                                        fontSize: isDesktop ? 19 : isTablet ? 16 : 14 ,
                                        fontWeight: FontWeight.normal                                      ),
                                    ),
                                  );
                                }).toList(), 
                                onChanged: (value) {
                                  setState(() {
                                    form.stockUnit = value!;
                                  });
                                },
                                ),
                              )
                          ),
                        ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10,),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                          "Low Stock Alert",
                          style: GoogleFonts.kameron(
                            fontSize:  isDesktop ? 21 : isTablet ? 19 : 15,
                            fontWeight: FontWeight.w500
                        ),
                        ),
                        SizedBox(height: 5,),
                        TextField(
                          controller: form.stockAlert,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                          decoration: InputDecoration(
                            hintText: '(ex. 5)',
                            hintStyle: TextStyle(fontSize: isDesktop ? 19 : isTablet ? 16 : 14 ,color: Colors.grey[700],fontStyle: FontStyle.italic),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              fillColor: Colors.grey[100],
                              filled: true,
                              contentPadding: EdgeInsets.symmetric(vertical: isDesktop ? 18 : isTablet ? 16 : 10, horizontal: 10)
                          ),
                        ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
            SizedBox(height: 12,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Description (optional)",
                  style: GoogleFonts.kameron(
                            fontSize:  isDesktop ? 21 : isTablet ? 19 : 15,
                            fontWeight: FontWeight.w500
                        ),
                  ),
                  SizedBox(height: 5,),
                  TextField(
                    controller: form.description,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
                    ],
                    keyboardType: TextInputType.multiline, 
                    minLines: 2, 
                    maxLines: 3,
                    decoration: InputDecoration(
                    hintText: 'Type here....',
                    hintStyle: TextStyle(fontSize: isDesktop ? 19 : isTablet ? 16 : 14 ,color: Colors.grey[700],fontStyle: FontStyle.italic),
                    border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                    fillColor: Colors.grey[100],
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(vertical: isDesktop ? 26 : isTablet ? 24 : 12, horizontal: 10)
                  ),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Divider(thickness: 3,color:Colors.black,indent: 5,endIndent: 10,height: 40,),
            SizedBox(height: 5,),
    
    ],
    
    
    );
} 

  @override
  Widget build(BuildContext context) {

    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        toolbarHeight: isDesktop ? 80 : isTablet ? 70 : 60,
        backgroundColor: Colors.grey[100],
        shadowColor: Colors.grey.withOpacity(0.5),
        elevation: 3,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_sharp, size: isDesktop ? 35 : isTablet ? 30 :25,),   // or Icons.arrow_back
            iconSize: Responsive.spacing(context, mobile: 28, tablet: 32, desktop: 36), 
            color: Colors.black,
            onPressed: () => Navigator.pop(context),
            tooltip: 'Back',
          ),
      
          leadingWidth: 50,
        title: Text(
            "Add product",
            style: GoogleFonts.kameron(
              fontSize: isDesktop ? 22 : isTablet ? 20 :18,
              fontWeight: FontWeight.bold,
              color: Colors.black
            ),
            ),
        
      ),
      body: 
       SingleChildScrollView(
        padding:EdgeInsets.all(16),
          child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: forms.length,
              itemBuilder: (context,index) => productFormWidget(index),
            ),
             SizedBox(height: 48,),
            Center(
              child: ElevatedButton(
                onPressed: forms.length >= maxProductsPerSave ? null : addNewForm ,
                style: ElevatedButton.styleFrom(
                   minimumSize: Size(200,isDesktop ? 55 : isTablet ? 50 : 45,), 
                  backgroundColor: Color(0xFF25FFA0), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), 
                  ),

                ),
                child: Row(
                   mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_circle_outline, size: isDesktop ? 21 : isTablet ? 20 : 16 ,color: Colors.black,
                    ),
                    SizedBox(width: 5,),
                    Text(
                      "Add Another Product",
                      style: GoogleFonts.kameron(
                        fontSize: isDesktop ? 19 : isTablet ? 17 : 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w500
                      ),),
                  ],
                ),
                ),
            ),
            SizedBox(height: 40),
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                     minimumSize: Size(isDesktop ? 290 : isTablet ? 270 : 230, isDesktop ? 70 : isTablet ? 60 : 50), 
                    backgroundColor: Color(0xFF00E6FF), 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), 
                    ),
                  ),
                  onPressed: _isLoading ? null : () async {
                    setState(() { _isLoading = true; });
              
                    try{
                      await _saveProducts();
                      await syncProducts();
                    }catch(error){
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error saving products."),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 16,
                        left: 16,
                        right: 16,),
                      )
                      );
                    }finally{
                      if(!mounted) return;
                      setState(() { _isLoading = false; });
                    }
              
                  },
                  child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : 
                  Text("Save Product",
                  style: GoogleFonts.kameron(
                    color: Colors.black,
                    fontSize: isDesktop ? 20 : isTablet ? 19 : 15,
                    fontWeight: FontWeight.w500
              
                  )
                  ),
                  ),
              ),
            )
          ],
        ), 
        ),
    );
  }
}