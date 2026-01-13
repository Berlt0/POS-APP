
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pos_app/db/product.dart';
import 'package:pos_app/models/products.dart';

class Addproduct extends StatefulWidget {
  const Addproduct({super.key});

  @override
  State<Addproduct> createState() => _POSState();
}

class _POSState extends State<Addproduct> {

  TextEditingController _productName = TextEditingController();
  TextEditingController _productCategory = TextEditingController();
  TextEditingController _barcode = TextEditingController();
  TextEditingController _price = TextEditingController();
  TextEditingController _cost = TextEditingController();
  TextEditingController _quantity = TextEditingController();
  TextEditingController _stockAlert = TextEditingController();
  TextEditingController _description = TextEditingController();

  String _productNameValue = '';
  String _productCategoryValue = '';
  String _barcodeValue = '';
  int _priceValue = 0;
  int _costValue = 0;
  int _quantityValue = 0;
  int _stockValue = 0;
  String _descripValue = '';

  String _stockUnit = 'pcs'; // default value
  final List<String> _units = ['pcs', 'liter', 'kg', 'meter'];

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();


  Future<String> saveImageLocally(File image) async {
  final dir = await getApplicationDocumentsDirectory();
  final newPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.png';
  final newImage = await image.copy(newPath);
  return newImage.path;
}

  Future<void> _pickImage() async {
  final ImagePicker picker = ImagePicker();

      showModalBottomSheet(
        context: context,
        builder: (_) => Container(
          height: 120,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () async {
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      _selectedImage = File(image.path);
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
                      _selectedImage = File(image.path);
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


Future<void> _saveProduct() async {
  // Validate required fields
  if (_productName.text.isEmpty || _price.text.isEmpty || _quantity.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please fill all required fields"))
    );
    return;
  }

  // Parse numeric values
  double price = double.tryParse(_price.text) ?? 0;
  double? cost = _cost.text.isNotEmpty ? double.tryParse(_cost.text) : null;
  int stock = int.tryParse(_quantity.text) ?? 0;
  int? lowStock = _stockAlert.text.isNotEmpty ? int.tryParse(_stockAlert.text) : 10;

  // Save image locally
  String? imagePath;
  if (_selectedImage != null) {
    imagePath = await saveImageLocally(_selectedImage!);
  }

  // Create Product object
  final product = Product(
    name: _productName.text,
    price: price,
    stock: stock,
    cost: cost,
    category: _productCategory.text.isNotEmpty ? _productCategory.text : null,
    barcode: _barcode.text.isNotEmpty ? _barcode.text : null,
    lowStockAlert: lowStock,
    description: _description.text.isNotEmpty ? _description.text : null,
    imagePath: imagePath,
    createdAt: DateTime.now().toIso8601String(),
    lastUpdate: DateTime.now().toIso8601String(),
  );

  // Save to database
  await ProductDB.insert(product);

  // Show success message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("${product.name} added successfully!"))
  );


  // Clear form
  _productName.clear();
  _price.clear();
  _quantity.clear();
  _cost.clear();
  _productCategory.clear();
  _barcode.clear();
  _stockAlert.clear();
  _description.clear();
  setState(() {
    _selectedImage = null;
    _stockUnit = 'pcs';
  });
}


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
            "Add product",
            style: GoogleFonts.kameron(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black
            ),
            ),
        ),
        
      ),
      body: 
       SingleChildScrollView(
        padding:EdgeInsets.all(16),
          child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Product Name",
                        style: GoogleFonts.kameron(
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(height: 5,),
                      TextField(
                        controller: _productName,
                        decoration: InputDecoration(
                          hintText: '(ex. Nova)',
                          hintStyle: TextStyle(fontSize: 15,color: Colors.grey[600],fontStyle: FontStyle.italic),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            fillColor: Colors.grey[100],
                            filled: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 10)
                        ),
                        
                      ),
                      SizedBox(height: 5,),
                      Text(
                        "Category",
                        style: GoogleFonts.kameron(
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(height: 5,),
                      TextField(
                        controller: _productCategory,
                        decoration: InputDecoration(
                          hintText: '(ex. Snacks)',
                          hintStyle: TextStyle(fontSize: 15,color: Colors.grey[600],fontStyle: FontStyle.italic),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            fillColor: Colors.grey[100],
                            filled: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 10)
                        ),
                      ),
                      SizedBox(height: 5,),
                      Text(
                        "Barcode (optional)",
                        style: GoogleFonts.kameron(
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(height: 5,),
                      TextField(
                        controller: _barcode,
                        decoration: InputDecoration(
                          hintStyle: GoogleFonts.kameron(fontSize: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            fillColor: Colors.grey[100],
                            filled: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                            suffixIcon: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFF00E6FF),
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 99, 98, 98)
                                ),
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(15),
                                  bottomRight: Radius.circular(15)
                                )
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.qr_code_scanner, // or Icons.qr_code for barcode
                                  color: Colors.black,
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
                        style: GoogleFonts.kameron(fontSize: 17),
                      ),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: _pickImage, // open gallery when tapped
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: _selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  Icons.camera_alt,
                                  size: 50,
                                  color: Colors.grey[700],
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Tap to select image",
                        style: GoogleFonts.kameron(fontSize: 14, color: Colors.grey[900]),
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
                            fontSize: 17,
                          ),
                        ),
                        SizedBox(height: 5,),
                        TextField(
                          controller: _price,
                          decoration: InputDecoration(
                            hintText: '(ex. 20)',
                            hintStyle: TextStyle(fontSize: 15,color: Colors.grey[600],fontStyle: FontStyle.italic), 
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              fillColor: Colors.grey[100],
                              filled: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 10)
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
                            fontSize: 17,
                          ),
                        ),
                        SizedBox(height: 5,),
                        TextField(
                          controller: _cost,
                          decoration: InputDecoration(
                              hintText: '(ex. 15)',
                              hintStyle: TextStyle(fontSize: 15,color: Colors.grey[600],fontStyle: FontStyle.italic),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              fillColor: Colors.grey[100],
                              filled: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 10)
                          ),
                        ),
                        ],
                      ),
                    )
                  ],
                )
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
                          "Stock Quantity",
                          style: GoogleFonts.kameron(
                            fontSize: 17,
                          ),
                        ),
                        SizedBox(height: 5,),
                        TextField(
                          controller: _quantity,
                          decoration: InputDecoration(
                            hintText: '(ex. 12)',
                            hintStyle: TextStyle(fontSize: 15,color: Colors.grey[600],fontStyle: FontStyle.italic),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              fillColor: Colors.grey[100],
                              filled: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                              suffixIcon: Container(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 99, 98, 98)
                                ),
                                color: Color(0xFF00E6FF),
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(15),
                                  bottomRight: Radius.circular(15),
                                ),
                              ),
                              child: DropdownButton<String>(
                                value: _stockUnit,
                                underline: SizedBox(), 
                                icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                                dropdownColor: Colors.white,
                                items:  _units.map((unit) {
                                  return DropdownMenuItem<String>(
                                    value: unit,
                                    child: Text(
                                      unit,
                                      style: GoogleFonts.kameron(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500
                                      ),
                                    ),
                                  );
                                }).toList(), 
                                onChanged: (value) {
                                  setState(() {
                                    _stockUnit = value!;
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
                            fontSize: 17,
                          ),
                        ),
                        SizedBox(height: 5,),
                        TextField(
                          controller: _stockAlert,
                          decoration: InputDecoration(
                            hintText: '(ex. 5)',
                            hintStyle: TextStyle(fontSize: 15,color: Colors.grey[600],fontStyle: FontStyle.italic),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              fillColor: Colors.grey[100],
                              filled: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 10)
                          ),
                        ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
            SizedBox(height: 10,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Description (optional)",
                  style: GoogleFonts.kameron(
                  fontSize: 17,
                  ),
                  ),
                  SizedBox(height: 5,),
                  TextField(
                    controller: _description,
                    keyboardType: TextInputType.multiline, 
                    minLines: 2, 
                    maxLines: null,
                    decoration: InputDecoration(
                    hintText: 'Type here....',
                    hintStyle: TextStyle(fontSize: 15,color: Colors.grey[600],fontStyle: FontStyle.italic),
                    border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                    fillColor: Colors.grey[100],
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 10)
                  ),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Divider(thickness: 1,color:Colors.black,indent: 10,endIndent: 10,height: 40,),
            SizedBox(height: 5,),
            Center(
              child: ElevatedButton(
                onPressed:(){} ,
                style: ElevatedButton.styleFrom(
                   minimumSize: Size(200, 50), 
                  backgroundColor: Color(0xFF25FFA0), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), 
                  ),

                ),
                child: Row(
                   mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_circle_outline, size: 18,color: Colors.black,
                    ),
                    SizedBox(width: 5,),
                    Text(
                      "Add Another Product",
                      style: GoogleFonts.kameron(
                        fontSize: 15,
                        color: Colors.black
                      ),),
                  ],
                ),
                ),
            ),
            SizedBox(height: 50),
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                   minimumSize: Size(300, 50), 
                  backgroundColor: Color(0xFF00E6FF), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), 
                  ),
                ),
                onPressed: _saveProduct,
                child: Text("Save Product",
                style: GoogleFonts.kameron(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w500

                )
                ),
                ),
            )
          ],
        ), 
        ),
    );
  }
}