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
  bool isDirty = false;
  bool isSaving = false;
  int? storeId;

  @override
  void initState() {
    super.initState();
    _loadStoreInfo();
  }

  Future<void> _loadStoreInfo() async {
    try {
      final data = await StoreInfoDB.getStoreInfo();

      if (data != null && mounted) {
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

  void _markDirty() {
    setState(() {
      isDirty = _anyFieldEdited();
    });
  }

  bool _anyFieldEdited() {
    return storeNameController.text != (originalValues['storeName'] ?? '') ||
        phoneController.text != (originalValues['phone'] ?? '') ||
        emailController.text != (originalValues['email'] ?? '') ||
        addressController.text != (originalValues['address'] ?? '') ||
        cityController.text != (originalValues['city'] ?? '') ||
        provinceController.text != (originalValues['province'] ?? '') ||
        zipController.text != (originalValues['zip'] ?? '');
  }

  bool _isEdited(String key) {
    final controller = _getController(key);
    return controller.text.trim() != (originalValues[key] ?? '').trim();
  }

  TextEditingController _getController(String key) {
    switch (key) {
      case "storeName":
        return storeNameController;
      case "phone":
        return phoneController;
      case "email":
        return emailController;
      case "address":
        return addressController;
      case "city":
        return cityController;
      case "province":
        return provinceController;
      case "zip":
        return zipController;
      default:
        return storeNameController;
    }
  }

  void _revertField(String key) {
    setState(() {
      _getController(key).text = originalValues[key] ?? '';
      isDirty = _anyFieldEdited();
    });
  }

  Color _getBorderColor(String key) {
    return _isEdited(key) ? Colors.amber : Colors.green;
  }

  Future<void> _saveAll() async {
    if (!isDirty) return;

    setState(() => isSaving = true);

    try {
      if (storeId == null) {
        await StoreInfoDB.insertStoreInfo(
          storeName: storeNameController.text.trim(),
          storePhone: phoneController.text.trim(),
          storeEmail: emailController.text.trim(),
          streetAddress: addressController.text.trim(),
          city: cityController.text.trim(),
          province: provinceController.text.trim(),
          zipCode: zipController.text.trim(),
        );
      } else {
        await StoreInfoDB.updateStoreInfo(
          id: storeId!,
          storeName: storeNameController.text.trim(),
          storePhone: phoneController.text.trim(),
          storeEmail: emailController.text.trim(),
          streetAddress: addressController.text.trim(),
          city: cityController.text.trim(),
          province: provinceController.text.trim(),
          zipCode: zipController.text.trim(),
        );
      }

      await _loadStoreInfo();

      if (!mounted) return;

      setState(() {
        isDirty = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Store information saved successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
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

  Widget buildField({
    required String key,
    required String label,
    required TextEditingController controller,
    IconData? icon,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: (_) => _markDirty(),
        style: GoogleFonts.kameron(
          fontSize: Responsive.font(context, mobile: 16, tablet: 17, desktop: 19),
          color: Colors.black,
        ),
        decoration: InputDecoration(
          prefixIcon: icon != null
              ? Icon(icon, color: const Color.fromARGB(255, 55, 116, 167))
              : null,

          labelText: label,
          hintText: "Enter $label",
          floatingLabelStyle: TextStyle(
          color: Colors.black,
          shadows: [
            Shadow(offset: Offset(1, 1), color: Colors.white),
            Shadow(offset: Offset(-1, -1), color: Colors.white),
            Shadow(offset: Offset(1, -1), color: Colors.white),
            Shadow(offset: Offset(-1, 1), color: Colors.white),
          ],
        ),

          filled: true,
          fillColor: Colors.grey[200],

          // Dynamic border color: Green = unchanged, Amber = edited
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: _getBorderColor(key),
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: _getBorderColor(key),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: _getBorderColor(key),
              width: 2,
            ),
          ),

          // Show cancel button only when field is edited
          suffixIcon: _isEdited(key)
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _revertField(key),
                )
              : null,
        ),
      ),
    );
  }


  void _revertAll() {
  setState(() {
    storeNameController.text = originalValues["storeName"] ?? '';
    phoneController.text = originalValues["phone"] ?? '';
    emailController.text = originalValues["email"] ?? '';
    addressController.text = originalValues["address"] ?? '';
    cityController.text = originalValues["city"] ?? '';
    provinceController.text = originalValues["province"] ?? '';
    zipController.text = originalValues["zip"] ?? '';

    isDirty = false;
  });

  FocusScope.of(context).unfocus(); // optional: close keyboard
}

Future<void> _confirmCancel() async {
  final isTablet = Responsive.isTablet(context);
  final isDesktop = Responsive.isDesktop(context);
  final isLandscape = Responsive.isLandscape(context);
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final confirm = await showGeneralDialog<bool>(
    context: context,
    barrierLabel: "Discard Changes",
    barrierDismissible: false,
    barrierColor: isDark
        ? Colors.black.withOpacity(0.9)
        : Colors.black.withOpacity(0.6),
    transitionDuration: const Duration(milliseconds: 300),

    pageBuilder: (context, anim1, anim2) {
      return Center(
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          type: MaterialType.transparency,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 390 : isTablet ? 400 : 290,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    "Discard Changes?",
                    style: GoogleFonts.kameron(
                      fontSize: isDesktop ? 22 : isTablet ? 20 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Message
                  Text(
                    "All unsaved changes will be lost.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.kameron(
                      fontSize: isDesktop ? 16 : isTablet ? 15.5 : 14.5,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(1),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Cancel / Keep Editing
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(false),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          child: Text(
                            "Keep Editing",
                            style: GoogleFonts.kameron(
                              fontSize: isDesktop ? 18 : isTablet ? 17 : 15.5,
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      // Confirm / Discard
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 12,
                          ),
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: Text(
                          "Discard",
                          style: GoogleFonts.kameron(
                            fontSize: isDesktop ? 18 : isTablet ? 17 : 15.5,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },

    transitionBuilder: (context, anim1, anim2, child) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutBack,
        ),
        child: child,
      );
    },
  );

  if (confirm == true) {
    _revertAll();
  }
}


Future<bool?> _confirmSave() async {
  final isTablet = Responsive.isTablet(context);
  final isDesktop = Responsive.isDesktop(context);
  final isLandscape = Responsive.isLandscape(context);
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return await showGeneralDialog<bool>(
    context: context,
    barrierLabel: "Save Changes",
    barrierDismissible: false,
    barrierColor: isDark
        ? Colors.black.withOpacity(0.9)
        : Colors.black.withOpacity(0.6),
    transitionDuration: const Duration(milliseconds: 300),

    pageBuilder: (context, anim1, anim2) {
      return Center(
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 390 : isTablet ? 400 : 290,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Text(
                    "Save Changes?",
                    style: GoogleFonts.kameron(
                      fontSize: isDesktop ? 22 : isTablet ? 20 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Do you want to save the updated store information?",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.kameron(
                      fontSize: isDesktop ? 16 : isTablet ? 15.5 : 14.5,
                      height: 1.4,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(false),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.kameron(
                              fontSize: isDesktop ? 18 : isTablet ? 17 : 15.5,
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(206, 47, 221, 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: Text(
                          "Save",
                          style: GoogleFonts.kameron(
                            fontSize: isDesktop ? 18 : isTablet ? 17 : 15.5,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ),
        ),
      );
    },

    transitionBuilder: (context, anim1, anim2, child) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutBack,
        ),
        child: child,
      );
    },
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
            fontSize: Responsive.font(context, mobile: 18, tablet: 20, desktop: 22),
            color: Theme.of(context).colorScheme.onSurface,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          
          const SizedBox(height: 20),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Store's basic information.",style: GoogleFonts.kameron(
                  fontSize: Responsive.font(context, mobile: 18, tablet: 20, desktop: 22),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("Make sure details are accurate as they may appear on receipts and reports.",style: GoogleFonts.kameron(
                fontSize: Responsive.font(context, mobile: 14, tablet: 15, desktop: 17),
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
              ),
            ),
            ],
          ),

           const SizedBox(height: 30),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Store Details",
                style: GoogleFonts.kameron(
                  fontSize: Responsive.font(context, mobile: 16, tablet: 18, desktop: 20),
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),

            const SizedBox(height: 16),

            buildField(
              key: "storeName",
              label: "Store Name",
              controller: storeNameController,
              icon: Icons.store,
            ),

            buildField(
              key: "phone",
              label: "Phone Number",
              controller: phoneController,
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),

            buildField(
              key: "email",
              label: "Email",
              controller: emailController,
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Address",
                style: GoogleFonts.kameron(
                  fontSize: Responsive.font(context, mobile: 16, tablet: 18, desktop: 20),
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),

            const SizedBox(height: 16),

            buildField(
              key: "address",
              label: "Street Address",
              controller: addressController,
              icon: Icons.home,
            ),

            buildField(
              key: "city",
              label: "City",
              controller: cityController,
              icon: Icons.location_city,
            ),

            buildField(
              key: "province",
              label: "Province",
              controller: provinceController,
              icon: Icons.map,
            ),

            buildField(
              key: "zip",
              label: "ZIP Code",
              controller: zipController,
              icon: Icons.local_post_office,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 40),

            if (isDirty) ...[
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isSaving
                    ? null
                    : () async {
                        final confirm = await _confirmSave();
                        if (confirm == true) {
                          await _saveAll();
                        }
                      },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(206, 47, 221, 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                  ),
                  child: isSaving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2.5,
                          ),  
                        )
                      : Text(
                          "Save Changes",
                          style: GoogleFonts.kameron(
                            fontSize: Responsive.font(context, mobile: 16, tablet: 17, desktop: 19),
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 15,),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: (isSaving || !isDirty) ? null : _confirmCancel,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Cancel Changes",
                        style: GoogleFonts.kameron(
                          fontSize: Responsive.font(context, mobile: 16, tablet: 17, desktop: 19),
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),

                ],
            const SizedBox(height: 30),

            
          ],
        ),
      ),
    );
  }
}