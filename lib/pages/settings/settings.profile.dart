import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/utils/responsive.dart';
import 'package:pos_app/db/accountProfile.dart';
import 'package:pos_app/db/user.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {

  
  String? role; 

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool isSaving = false;

  String? nameError;
  String? emailError;
  String? contactError;
  String? addressError;

  bool isDirty = false;
  

  String? profileImagePath;

  Map<String, String> originalValues = {};
  bool _isPickingImage = false;


  @override
  void initState() {
    super.initState();
    _loadInfo();
  }


  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    contactController.dispose();
    addressController.dispose();
    super.dispose();
  }


void _markDirty() {
  setState(() {
    isDirty = _anyFieldEdited();
  });
}

void _revertAll() {
  setState(() {
    nameController.text = originalValues["name"] ?? '';
    emailController.text = originalValues["email"] ?? '';
    contactController.text = originalValues["contact"] ?? '';
    addressController.text = originalValues["address"] ?? '';

    profileImagePath = null; // reset image (optional)
    isDirty = false;
  });

  FocusScope.of(context).unfocus();
}

TextEditingController _getController(String key) {
  switch (key) {
    case "name":
      return nameController;
    case "email":
      return emailController;
    case "contact":
      return contactController;
    case "address":
      return addressController;
    default:
      return nameController;
  }
}

Color _getBorderColor(String key) {
  if (!_isEdited(key)) {
    return Colors.green;
  } else {
    return Colors.amber;
  }
}


 Widget buildField({
  required String key,
  required String label,
  required TextEditingController controller,
  bool enabled = true,
  IconData? icon,
  String? errorText,
  Function(String)? onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      enabled: enabled,
      onChanged: onChanged,
      style: GoogleFonts.kameron(
        fontSize: Responsive.font(context, mobile: 16, tablet: 17, desktop: 19),
        color: Colors.black
      ),
      decoration: InputDecoration(
      prefixIcon: icon != null
          ? Icon(icon, color: const Color.fromARGB(255, 55, 116, 167))
          : null,

      labelText: label,
      hintText: "Enter $label",
      hintStyle: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black54
            : Colors.grey,
      ),

      labelStyle: TextStyle(
        color: Colors.black54
      ),

    floatingLabelStyle: TextStyle(
    color: Colors.black,
    shadows: [
      Shadow(offset: Offset(1, 1), color: Colors.white),
      Shadow(offset: Offset(-1, -1), color: Colors.white),
      Shadow(offset: Offset(1, -1), color: Colors.white),
      Shadow(offset: Offset(-1, 1), color: Colors.white),
    ],
  ),

      errorText: errorText,

      suffixIcon: _isEdited(key)
    ? IconButton(
        icon: const Icon(Icons.close, color: Colors.red),
        onPressed: () => _revertField(key),
      )
    : null,

      filled: true,
      fillColor: enabled ? Colors.grey[200] : Colors.grey[300],
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
    ),
    ),
  );
}


  Future<void> _loadInfo() async {

    final userId = await UserDB().getLoggedInUserId();

    if (userId == null) {
    print("No logged-in user found");
    return;
  }

    final info = await Account().getAccountInfo(userId);

    if (info.isNotEmpty && mounted) {
    setState(() {
      nameController.text = info['name'] ?? '';
      emailController.text = info['email'] ?? '';
      contactController.text = info['contact_number'] ?? '';
      addressController.text = info['address'] ?? '';
      role = info['role'] ?? 'cashier';

      originalValues = {
        'name': info['name'] ?? '',
        'email': info['email'] ?? '',
        'contact': info['contact_number'] ?? '',
        'address': info['address'] ?? '',
      };

    });
  }

  }

bool _anyFieldEdited() {
  return nameController.text != (originalValues['name'] ?? '') ||
      emailController.text != (originalValues['email'] ?? '') ||
      contactController.text != (originalValues['contact'] ?? '') ||
      addressController.text != (originalValues['address'] ?? '');
}

  bool _isEdited(String key) {
  return _getController(key).text.trim() != (originalValues[key] ?? '').trim();
}

void _revertField(String key) {
  setState(() {
    _getController(key).text = originalValues[key] ?? '';
    isDirty = _anyFieldEdited(); 
  });
}


 void _saveProfile() async {


  setState(() {
    nameError = nameController.text.trim().isEmpty ? "Name is required" : null;
    emailError = !emailController.text.contains('@') ? "Invalid email" : null;
    contactError = contactController.text.length < 7 ? "Invalid number" : null;
    addressError = addressController.text.trim().isEmpty ? "Address required" : null;
  });

  if ([nameError, emailError, contactError, addressError]
      .any((e) => e != null)) {
    return;
  }

  setState(() => isSaving = true);

  final userId = await UserDB().getLoggedInUserId();

  if (userId == null) {
    setState(() => isSaving = false);
    return;
  }

  final success = await Account().updateAccount(
    id: userId,
    name: nameController.text.trim(),
    email: emailController.text.trim(),
    contact: contactController.text.trim(),
    address: addressController.text.trim(),
  );

  if (!mounted) return;

  setState(() { 
    isSaving = false;
    });

  if (success) {
    await _loadInfo();

      if (!mounted) return;

      setState(() {
        isDirty = false;
      });


    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile updated successfully"),
        backgroundColor: Colors.green,
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Update failed"),
        backgroundColor: Colors.red,
      ),
    );
  }
}


Future<void> _changePhoto() async {
  if (_isPickingImage) return; // prevent double open

  _isPickingImage = true;

  try {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        profileImagePath = picked.path;
        isDirty = true;
      });
    }
  } catch (e) {
    debugPrint("Image picker error: $e");
  } finally {
    _isPickingImage = false;
  }
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
                      // Keep Editing
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

                      // Discard
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


Future<void> _confirmSaveProfile() async {
  final isTablet = Responsive.isTablet(context);
  final isDesktop = Responsive.isDesktop(context);
  final isLandscape = Responsive.isLandscape(context);
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final confirm = await showGeneralDialog<bool>(
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
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 390 : isTablet ? 360 : 290,
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
                  /// TITLE
                  Text(
                    "Save Changes?",
                    style: GoogleFonts.kameron(
                      fontSize: isDesktop
                          ? 22
                          : isTablet
                              ? 20
                              : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// MESSAGE
                  Text(
                    "Are you sure you want to update your profile information?",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.kameron(
                      fontSize: isDesktop
                          ? 16
                          : isTablet
                              ? 15
                              : 14,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// BUTTONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      /// CANCEL
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
                              fontSize: isDesktop
                                  ? 18
                                  : isTablet
                                      ? 17
                                      : 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),

                      /// CONFIRM SAVE
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(206, 47, 221, 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 26,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: Text(
                          "Save",
                          style: GoogleFonts.kameron(
                            fontSize: isDesktop
                                ? 18
                                : isTablet
                                    ? 17
                                    : 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
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
    _saveProfile();
  }
}


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Account Settings",
          style: GoogleFonts.kameron(
            fontWeight: FontWeight.bold,
            fontSize: Responsive.font(context, mobile: 18, tablet: 20, desktop: 22),
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

           Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImagePath != null
                      ? FileImage(File(profileImagePath!))
                      : const AssetImage('assets/Legendaries.png'),
                ),

                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap:  _isPickingImage ? null : _changePhoto,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),

          
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Profile Information",
                style: GoogleFonts.kameron(
                  fontSize: Responsive.font(context, mobile: 16, tablet: 18, desktop: 20),
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface
                ),
              ),
            ),

            const SizedBox(height: 10),

            buildField(
              key: "name",
              label: "Full Name",
              controller: nameController,
              icon: Icons.person,
              enabled: true,
              errorText: nameError,
              onChanged: (value) {
                _markDirty();
                setState(() {
                  nameError = value.trim().isEmpty ? "Name is required" : null;
                });
              },
            ),


            buildField(
              key: "email",
              label: "Email",
              controller: emailController,
              icon: Icons.email,
              enabled: role == "admin", 
              errorText: emailError,
              onChanged: (value) {
                _markDirty();
                setState(() {

                  emailError = value.contains('@') ? null : "Invalid email";
                });
              },
            ),

            buildField(
              key: "contact",
              label: "Contact Number",
              controller: contactController,
              icon: Icons.phone,
              errorText: contactError,
              onChanged: (value) {
                _markDirty();
                
                setState(() {

                  contactError = value.length < 7 ? "Invalid number" : null;
                });
              },
            ),

            buildField(
              key: "address",
              label: "Address",
              controller: addressController,
              icon: Icons.location_on,
              errorText: addressError,
              onChanged: (value) {
                _markDirty();
                
                setState(() {
                  
                  addressError = value.trim().isEmpty ? "Address required" : null;
                });
              },
            ),


            const SizedBox(height: 30),

          if(isDirty) ... [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (isSaving || !isDirty) ? null : _confirmSaveProfile, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(206, 47, 221, 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "Save Changes",
                        style: GoogleFonts.kameron(
                          fontSize: Responsive.font(context, mobile: 15, tablet: 17, desktop: 19),
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