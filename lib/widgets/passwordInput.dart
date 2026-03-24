import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

class PasswordInput {
  /// Opens a password input dialog and returns the entered password
  static Future<String?> show(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    bool _obscureText = true;

    return showAdaptiveDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Center(
              child: Text('Enter password', style: GoogleFonts.kameron(
                fontSize: 18,
                fontWeight: FontWeight.w500
              )),
            ),
            content: TextField(
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]'))
              ],
              controller: _controller,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: Text("Cancel", style: GoogleFonts.kameron(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, _controller.text);
                },
                child: Text("Confirm",style: GoogleFonts.kameron(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                )),
              ),
            ],
          ),
        );
      },
    );
  }
}