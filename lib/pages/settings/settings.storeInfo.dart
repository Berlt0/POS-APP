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

  Widget buildField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    IconData? icon,
  }) {
    final isTablet = Responsive.isTablet(context);
    final isDesktop = Responsive.isDesktop(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.kameron(
          fontSize: Responsive.font(context, mobile: 15, tablet: 17, desktop: 19),
        ),
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: Color(0xFF6FE5F2)) : null,
          labelText: label,
          labelStyle: GoogleFonts.kameron(
            fontSize: Responsive.font(context, mobile: 14, tablet: 16, desktop: 18),
          ),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: isDesktop ? 18 : isTablet ? 16 : 12,
            horizontal: 12,
          ),
        ),
      ),
    );
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
    final isTablet = Responsive.isTablet(context);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Store Information",
          style: GoogleFonts.kameron(
            fontWeight: FontWeight.bold,
            fontSize: Responsive.font(context, mobile: 18, tablet: 20, desktop: 22),
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

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Store Details",
                style: GoogleFonts.kameron(
                  fontSize: Responsive.font(context, mobile: 16, tablet: 18, desktop: 20),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            buildField(
              label: "Store Name",
              controller: storeNameController,
            ),

            buildField(
              label: "Phone Number",
              controller: phoneController,
              keyboardType: TextInputType.phone,
  
            ),

            buildField(
              label: "Email",
              controller: emailController,
              keyboardType: TextInputType.emailAddress,

            ),

            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Address",
                style: GoogleFonts.kameron(
                  fontSize: Responsive.font(context, mobile: 16, tablet: 18, desktop: 20),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            buildField(
              label: "Street Address",
              controller: addressController,

            ),

            buildField(
              label: "City",
              controller: cityController,
            ),

            buildField(
              label: "Province",
              controller: provinceController,
            ),

            buildField(
              label: "ZIP Code",
              controller: zipController,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveStoreInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF30DD04),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Save Store Info",
                  style: GoogleFonts.kameron(
                    fontSize: Responsive.font(context, mobile: 15, tablet: 17, desktop: 19),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}