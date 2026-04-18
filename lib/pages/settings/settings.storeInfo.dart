import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/utils/responsive.dart';
import 'package:pos_app/db/storeInfo.dart';

class StoreInfo extends StatefulWidget {
  const StoreInfo({super.key});

  @override
  State<StoreInfo> createState() => _StoreInfoState();
}

class _StoreInfoState extends State<StoreInfo> {
  final TextEditingController storeNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController provinceController = TextEditingController();
  final TextEditingController zipController = TextEditingController();

  Map<String, String> originalValues = {};
 
   bool forceEditingClose = false;
  int editingCount = 0;
  int? storeId;

  @override
  void initState() {
    super.initState();

    originalValues = {
      "storeName": "",
      "phone": "",
      "email": "",
      "address": "",
      "city": "",
      "province": "",
      "zip": "",
    };

    _loadStoreInfo();
  }


 void _loadStoreInfo() async {
  try {
    final data = await StoreInfoDB.getStoreInfo();

    if (data != null) {
      storeId = data['id'];
      storeNameController.text = data['store_name'] ?? '';
      phoneController.text = data['store_phone'] ?? '';
      emailController.text = data['store_email'] ?? '';
      addressController.text = data['street_address'] ?? '';
      cityController.text = data['city'] ?? '';
      provinceController.text = data['province'] ?? '';
      zipController.text = data['zip_code'] ?? '';

      originalValues = {
        "storeName": storeNameController.text,
        "phone": phoneController.text,
        "email": emailController.text,
        "address": addressController.text,
        "city": cityController.text,
        "province": provinceController.text,
        "zip": zipController.text,
      };

      setState(() {});
    }
  } catch (e) {
    debugPrint("Error loading store info: $e");
  }
}


void _handleEditing(bool isEditing) {
  setState(() {
    if (isEditing) {
      editingCount++;
    } else {
      editingCount--;
    }
  });
}


 void _saveAll() async {

  try {

  
    if(storeId == null) {

    await StoreInfoDB.insertStoreInfo(
      storeName: storeNameController.text,
      storePhone: phoneController.text,
      storeEmail: emailController.text,
      streetAddress: addressController.text,
      city: cityController.text,
      province: provinceController.text,
      zipCode: zipController.text,
    );

    originalValues = {
      "storeName": storeNameController.text,
      "phone": phoneController.text,
      "email": emailController.text,
      "address": addressController.text,
      "city": cityController.text,
      "province": provinceController.text,
      "zip": zipController.text,
    };

    setState(() {
    });

    await Future.delayed(const Duration(milliseconds: 100));


    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Store info saved successfully"),
        backgroundColor: Colors.green,
      ),
    );
  }
    
  } catch (e) {
    

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Failed to save: $e"),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  void _cancelAll() {
    storeNameController.text = originalValues["storeName"]!;
    phoneController.text = originalValues["phone"]!;
    emailController.text = originalValues["email"]!;
    addressController.text = originalValues["address"]!;
    cityController.text = originalValues["city"]!;
    provinceController.text = originalValues["province"]!;
    zipController.text = originalValues["zip"]!;

    setState(() {});
  }

  @override
  void dispose() {
    storeNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    cityController.dispose();
    provinceController.dispose();
    zipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Store Information",
          style: GoogleFonts.kameron(
            fontWeight: FontWeight.bold,
            fontSize:Responsive.font(context, mobile: 18, tablet: 20, desktop: 22),
            color: Theme.of(context).colorScheme.onSurface

          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

          SizedBox(height: 10,),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Store Details",
                style: GoogleFonts.kameron(
                  fontSize: Responsive.font(
                      context, mobile: 17, tablet: 18, desktop: 19),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            EditableField(label: "Store Name", controller: storeNameController, icon: Icons.store, onEditingChanged: _handleEditing,forceClose: forceEditingClose),
            EditableField(label: "Phone Number", controller: phoneController, icon: Icons.phone, onEditingChanged: _handleEditing,forceClose: forceEditingClose),
            EditableField(label: "Email", controller: emailController, icon: Icons.email, onEditingChanged: _handleEditing,forceClose: forceEditingClose,),

            const SizedBox(height: 20),

            /// ADDRESS
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Address",
                style: GoogleFonts.kameron(
                  fontSize: Responsive.font(
                      context, mobile: 17, tablet: 18, desktop: 19),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            EditableField(label: "Street Address", controller: addressController, icon: Icons.home, onEditingChanged: _handleEditing,forceClose: forceEditingClose),
            EditableField(label: "City", controller: cityController, icon: Icons.location_city, onEditingChanged: _handleEditing,forceClose: forceEditingClose),
            EditableField(label: "Province", controller: provinceController, icon: Icons.map, onEditingChanged: _handleEditing,forceClose: forceEditingClose),
            EditableField(label: "ZIP Code", controller: zipController, icon: Icons.local_post_office, onEditingChanged: _handleEditing,forceClose: forceEditingClose),

            const SizedBox(height: 50),


            if (editingCount > 0)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;

                  return isMobile
                      ? Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _saveAll,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  elevation: 6,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  "Save",
                                  style: GoogleFonts.kameron(
                                    fontSize: Responsive.font(
                                      context,
                                      mobile: 16,
                                      tablet: 17,
                                      desktop: 18,
                                    ),
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  
                                   _cancelAll();
                                  
                                   setState(() {
                                    editingCount = 0;
                                    forceEditingClose = true;
                                   });

                                  Future.delayed(const Duration(milliseconds: 50), () {
                                    setState(() {
                                      forceEditingClose = false;
                                    });
                                  });

                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  elevation: 6,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  "Cancel",
                                  style: GoogleFonts.kameron(
                                    fontSize: Responsive.font(
                                      context,
                                      mobile: 16,
                                      tablet: 17,
                                      desktop: 18,
                                    ),
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _saveAll,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    elevation: 6,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    "Save",
                                    style: GoogleFonts.kameron(
                                      fontSize: Responsive.font(
                                        context,
                                        mobile: 16,
                                        tablet: 17,
                                        desktop: 18,
                                      ),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _cancelAll,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    elevation: 6,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    "Cancel",
                                    style: GoogleFonts.kameron(
                                      fontSize: Responsive.font(
                                        context,
                                        mobile: 16,
                                        tablet: 17,
                                        desktop: 18,
                                      ),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                },
              ),

          ],
        ),
      ),
    );
  }
}

/// 🔥 EDITABLE FIELD
class EditableField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final IconData? icon;
  final Function(bool)? onEditingChanged;
  final bool forceClose;

  const EditableField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.icon,
    this.onEditingChanged,
    this.forceClose = false,
  });

  @override
  State<EditableField> createState() => _EditableFieldState();
}

class _EditableFieldState extends State<EditableField> {
  bool isEditing = false;
  String tempValue = "";
 

  @override
void didUpdateWidget(covariant EditableField oldWidget) {
  super.didUpdateWidget(oldWidget);

  if (widget.forceClose && isEditing) {
    setState(() {
      isEditing = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  children: [
                    Icon(
                      widget.icon,
                      size: Responsive.font(context, mobile: 23, tablet: 27, desktop: 30),
                      color: const Color.fromARGB(255, 55, 116, 167),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.label,
                      style: GoogleFonts.kameron(
                        fontSize: Responsive.font(context, mobile: 17, tablet: 18, desktop: 19),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                isEditing
                    ? Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: TextField(
                          controller: widget.controller,
                          keyboardType: widget.keyboardType,
                          autofocus: true,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: UnderlineInputBorder(),
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(widget.controller.text),
                      ),
              ],
            ),
          ),

          isEditing
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check,
                          size: Responsive.font(context, mobile: 23, tablet: 27, desktop: 30),
                          color: Colors.green),
                      onPressed: () {
                        setState(() {
                          isEditing = false;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.close,
                          size: Responsive.font(context, mobile: 23, tablet: 27, desktop: 30),
                          color: Colors.red),
                      onPressed: () {
                        setState(() {
                          widget.controller.text = tempValue;
                          isEditing = false;
                        });
                        widget.onEditingChanged?.call(false);

                      },
                    ),
                  ],
                )
              : IconButton(
                  icon: Icon(Icons.edit,
                      size: Responsive.font(context, mobile: 23, tablet: 27, desktop: 30),
                      color: const Color.fromARGB(255, 55, 116, 167)),
                  onPressed: () {
                    setState(() {
                      tempValue = widget.controller.text;
                      isEditing = true;                      
                    });
                    widget.onEditingChanged?.call(true);
                    
                  },
                ),
        ],
      ),
    );
  }
}