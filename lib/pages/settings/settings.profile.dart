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
      ),
      decoration: InputDecoration(
      prefixIcon: icon != null
          ? Icon(icon, color: const Color.fromARGB(255, 55, 116, 167))
          : null,

      labelText: label,
      errorText: errorText,

      suffixIcon: _isEdited(key)
    ? IconButton(
        icon: const Icon(Icons.close, color: Colors.red),
        onPressed: () => _revertField(key),
      )
    : null,

      filled: true,
      fillColor: enabled ? Colors.grey[100] : Colors.grey[300],
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



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Account Settings",
          style: GoogleFonts.kameron(
            fontWeight: FontWeight.bold,
            fontSize: Responsive.font(context, mobile: 18, tablet: 20, desktop: 22),
          ),
        ),
        backgroundColor: Colors.grey[100],
        elevation: 5,
        shadowColor: Colors.grey.withOpacity(0.5),
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

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Security",
                style: GoogleFonts.kameron(
                  fontSize: Responsive.font(context, mobile: 16, tablet: 18, desktop: 20),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

         
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.lock, color: Colors.black),
                label: Text(
                  "Change Password",
                  style: GoogleFonts.kameron(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6FE5F2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  // TODO: navigate to change password page
                },
              ),
            ),

            const SizedBox(height: 30),

          if(isDirty)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (isSaving || !isDirty) ? null : _saveProfile, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF30DD04),
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

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}