import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/utils/responsive.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {

  // Simulated role (replace with your real userData)
  String role = "cashier"; // change to "admin" to test

  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    contactController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Widget buildField({
    required String label,
    required TextEditingController controller,
    bool enabled = true,
    IconData? icon,
  }) {


    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        enabled: enabled,
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
          fillColor: enabled ? Colors.grey[100] : Colors.grey[300],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }



  void _saveProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile updated successfully"),
        backgroundColor: Colors.green,
      ),
    );
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
                "Profile Information",
                style: GoogleFonts.kameron(
                  fontSize: Responsive.font(context, mobile: 16, tablet: 18, desktop: 20),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            buildField(
              label: "Full Name",
              controller: nameController,
              icon: Icons.person,
              enabled: true,
            ),

            buildField(
              label: "Username",
              controller: usernameController,
              icon: Icons.account_circle,
              enabled: role == "admin", 
            ),

            buildField(
              label: "Email",
              controller: emailController,
              icon: Icons.email,
              enabled: role == "admin", 
            ),

            buildField(
              label: "Contact Number",
              controller: contactController,
              icon: Icons.phone,
            ),

            buildField(
              label: "Address",
              controller: contactController,
              icon: Icons.phone,
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

          
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF30DD04),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
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