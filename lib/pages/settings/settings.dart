import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/pages/settings/resetPass.settings.dart';
import 'package:pos_app/pages/settings/settings.profile.dart';
import 'package:pos_app/pages/settings/settings.storeInfo.dart';
import 'package:pos_app/utils/responsive.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  Widget buildTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Color.fromARGB(255, 19, 210, 231), size: Responsive.font(context,mobile: 24,tablet: 27, desktop: 28)),
      title: Text(title,style: GoogleFonts.kameron(
        fontSize: Responsive.font(context,mobile: 16,tablet: 18, desktop: 19),
        fontWeight: FontWeight.w500
      ),),
      trailing:  Icon(Icons.arrow_forward_ios, size: Responsive.font(context,mobile: 16,tablet: 17, desktop: 17.5)),
      onTap: onTap,
    );
  }

  Widget buildSection(String title, List<Widget> children,) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: GoogleFonts.kameron(
                  fontWeight: FontWeight.bold,
                  fontSize: Responsive.font(context,mobile: 17,tablet: 19, desktop: 20),
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          ...children
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final isTablet = Responsive.isTablet(context);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: isDesktop ? 80 : isTablet ? 70 : 60,
        backgroundColor: Colors.grey[100],
        shadowColor: Colors.grey.withOpacity(0.5),
        elevation: 3,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_sharp, size: isDesktop ? 35 : isTablet ? 30 :25,),   
            iconSize: Responsive.spacing(context, mobile: 28, tablet: 32, desktop: 36), 
            color: Colors.black,
            onPressed: () => Navigator.pop(context),
            tooltip: 'Back',
          ),
      
          leadingWidth: 50,
        title: Text(
            "Settings",
            style: GoogleFonts.kameron(
              fontSize: isDesktop ? 22 : isTablet ? 20 :18,
              fontWeight: FontWeight.bold,
              color: Colors.black
            ),
            ),
        
      ),
      body: ListView(
        children: [

          // Account
          buildSection("Account", [
            buildTile(Icons.person, "Profile", () => Navigator.push(context,MaterialPageRoute(builder: (context) => const ProfileSettings()))),
          ]),

          // Store Info
          buildSection("Store Info", [
            buildTile(Icons.store, "Store Details", () => Navigator.push(context,MaterialPageRoute(builder: (context) => const StoreInfo()))),
          ]),

          // Payments
          buildSection("Payments", [
            buildTile(Icons.payment, "Payment Methods(Coming soon)", () {}),

          ]),

          buildSection("Backup", [
            buildTile(Icons.cloud, "Backup & Restore", () {}),
          ]),


          
          buildSection("Security", [
            buildTile(Icons.lock, "Reset Password", () => Navigator.push(context,MaterialPageRoute(builder: (context) => const ResetPass()))),
            buildTile(Icons.security, "Manage Cashier Access", () {}),
          ]),

          // System
          buildSection("System", [
            buildTile(Icons.info, "About App", () {}),
            buildTile(Icons.settings, "App Preferences", () {}),
          ]),
        ],
      ),
    );
  }
}