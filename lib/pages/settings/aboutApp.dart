import 'package:flutter/material.dart';
import 'package:pos_app/utils/responsive.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutApp extends StatelessWidget {
  const AboutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
        title: Text(
          "About App",
          style: GoogleFonts.kameron(
            fontWeight: FontWeight.bold,
            fontSize: Responsive.font(
              context,
              mobile: 18,
              tablet: 20,
              desktop: 22,
            ),
          color: Theme.of(context).colorScheme.onSurface
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children:  [

            SizedBox(height: 30),

            Center(
              child: Icon(
                Icons.point_of_sale,
                size: 80,
              ),
            ),

            SizedBox(height: 10),

            Center(
              child: Text(
                "POS System",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 5),

            Center(
              child: Text(
                "Version 1.0.0",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ),

            SizedBox(height: 20),

            Center(
              child: Text(
                "A simple Point of Sale system for managing sales, inventory, and reports.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ),

            SizedBox(height: 20),

            Center(
              child: Text(
                "Developed by: Berlt0",
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}