import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/utils/responsive.dart';

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

  void _saveStoreInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Store information saved successfully"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Store Information",
          style: GoogleFonts.kameron(
            fontWeight: FontWeight.bold,
            fontSize:
                Responsive.font(context, mobile: 18, tablet: 20, desktop: 22),
          ),
        ),
        backgroundColor: Colors.grey[100],
        elevation: 3,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// STORE DETAILS
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Store Details",
                style: GoogleFonts.kameron(
                  fontSize: Responsive.font(
                      context,
                      mobile: 17,
                      tablet: 18,
                      desktop: 19),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

          EditableField(
                label: "Store Name",
                controller: storeNameController,
                icon: Icons.store,
            ),

              EditableField(
                label: "Phone Number",
                controller: phoneController,
                keyboardType: TextInputType.phone,
                icon: Icons.phone,
              ),
            

               EditableField(
                label: "Email",
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                icon: Icons.email,
              ),
            

            const SizedBox(height: 20),

            /// ADDRESS
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Address",
                style: GoogleFonts.kameron(
                  fontSize: Responsive.font(
                      context,
                      mobile: 17,
                      tablet: 18,
                      desktop: 19),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

           EditableField(
                label: "Street Address",
                controller: addressController,
                icon: Icons.home,
              ),
            

           EditableField(
                label: "City",
                controller: cityController,
                icon: Icons.location_city,
              ),
            

            EditableField(
                label: "Province",
                controller: provinceController,
                icon: Icons.map,
              ),
            

             EditableField(
                label: "ZIP Code",
                controller: zipController,
                keyboardType: TextInputType.number,
                icon: Icons.local_post_office,
              ),
            

            const SizedBox(height: 30),

          ],
        ),
      ),
    );
  }
}

/// 🔥 EDITABLE FIELD WITH ICON
class EditableField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final IconData? icon;

  const EditableField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.icon,
  });

  @override
  State<EditableField> createState() => _EditableFieldState();
}

class _EditableFieldState extends State<EditableField> {
  bool isEditing = false;

  String tempValue = "";

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
                      size: Responsive.font(
                        context,
                        mobile: 23,
                        tablet: 27,
                        desktop: 30,
                      ),
                      color: const Color.fromARGB(255, 55, 116, 167),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.label,
                      style: GoogleFonts.kameron(
                        fontSize: Responsive.font(
                            context,
                            mobile: 16.8,
                            tablet: 17.8,
                            desktop: 18.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                /// VALUE / INPUT
                isEditing
                    ? Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: TextField(
                          controller: widget.controller,
                          keyboardType: widget.keyboardType,
                          autofocus: true,
                          style: GoogleFonts.kameron(
                            fontSize: Responsive.font(
                                context,
                                mobile: 16.5,
                                tablet: 17.5,
                                desktop: 18.5),
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            border: UnderlineInputBorder(),
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          widget.controller.text,
                          style: GoogleFonts.kameron(
                            fontSize: Responsive.font(
                                context,
                                mobile: 16.5,
                                tablet: 17.5,
                                desktop: 18.5),
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[900]
                          ),
                        ),
                      ),
              ],
            ),
          ),

       
  isEditing
    ? Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          
          IconButton(
            icon: Icon(
              Icons.check,
              size: Responsive.font(
                  context,
                  mobile: 23,
                  tablet: 27,
                  desktop: 30),
              color: Colors.green,
            ),
            onPressed: () {
              setState(() {
                isEditing = false;
              });
            },
          ),

        
          IconButton(
            icon: Icon(
              Icons.close,
              size: Responsive.font(
                  context,
                  mobile: 23,
                  tablet: 27,
                  desktop: 30),
              color: Colors.red,
            ),
            onPressed: () {
              setState(() {
                widget.controller.text = tempValue; 
                isEditing = false;
              });
            },
          ),
        ],
      )
    : IconButton(
        icon: Icon(
          Icons.edit,
          size: Responsive.font(
              context,
              mobile: 23,
              tablet: 27,
              desktop: 30),
          color: const Color.fromARGB(255, 55, 116, 167),
        ),
        onPressed: () {
          setState(() {
            tempValue = widget.controller.text; 
            isEditing = true;
          });
        },
      ),

      
        ],
      ),
    );
  }
}