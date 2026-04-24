import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/db/resetPassword.dart';
import 'package:pos_app/utils/responsive.dart';
import 'package:pos_app/utils/password_hashed.dart';

class ResetPass extends StatefulWidget {
  const ResetPass({super.key});

  @override
  State<ResetPass> createState() => _ResetPassState();
}

class _ResetPassState extends State<ResetPass> {
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  String? selectedCashier;

  String? newError;
  String? confirmError;

  List<String> cashiers = [];


  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadCashiers();

   
    newPassController.addListener(_refresh);
    confirmPassController.addListener(_refresh);
  }

  @override
  void dispose() {
    newPassController.removeListener(_refresh);
    confirmPassController.removeListener(_refresh);
    newPassController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {}); // Rebuild to update suffixIcon visibility
  }

  Widget buildField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
    String? errorText,
  }) {
    final bool hasText = controller.text.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: !isVisible,
        style: GoogleFonts.kameron(
          fontSize: Responsive.font(
            context,
            mobile: 16,
            tablet: 17,
            desktop: 19,
          ),
          color: Colors.black
        ),
        decoration: InputDecoration(
          prefixIcon: icon != null
              ? Icon(icon, color: const Color.fromARGB(255, 55, 116, 167))
              : null,
    
          suffixIcon: hasText
              ? IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility_off : Icons.visibility,
                    color: const Color.fromARGB(206, 55, 117, 167),
                  ),
                  onPressed: onVisibilityToggle,
                  tooltip: isVisible ? 'Hide Password' : 'Show Password',
                )
              : null,
          labelText: label,
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
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 19, 210, 231),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            dropdownColor: Colors.grey[100],
            value: cashiers.contains(selectedCashier) ? selectedCashier : null,
            hint: Text(
              "Select Cashier",
              style: GoogleFonts.kameron(
                fontSize: Responsive.font(context,mobile: 16, tablet: 17, desktop: 19),
                color: Colors.black
              ),
            ),
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down,color: Colors.black),
            items: cashiers.map((cashier) {
              return DropdownMenuItem(
                value: cashier,
                child: Text(
                  cashier,
                  style: GoogleFonts.kameron(
                    fontSize: Responsive.font(context,mobile: 16, tablet: 17, desktop: 19),
                    color: Colors.black
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCashier = value;
              });
            },
          ),
        ),
      ),
    );
  }

  void _submit() async {

   setState(() {
    newError = newPassController.text.length < 6
        ? "Min 6 characters"
        : null;

    confirmError = confirmPassController.text != newPassController.text
        ? "Password not match"
        : null;
  });

  if (newError != null ||
      confirmError != null ||
      selectedCashier == null) {
    return;
  }

  final confirm = await showResetPasswordConfirmModal(context);
  if (confirm != true) return;


    final hashedPassword = PasswordHelper.hashPassword(newPassController.text.trim());

    final success = await ResetPassword().resetPassword(
      name: selectedCashier!,
      password: hashedPassword,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password reset successful"),
          backgroundColor: Colors.green,
        ),
      );

      newPassController.clear();
      confirmPassController.clear();

      setState(() {
        selectedCashier = null;
        _newPasswordVisible = false;
        _confirmPasswordVisible = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Reset failed"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _loadCashiers() async {
    final data = await ResetPassword().getCashiers();
    setState(() {
      cashiers = data.map((e) => e['name'].toString()).toList();
    });
  }


Future<bool?> showResetPasswordConfirmModal(BuildContext context) async {
  final isTablet = Responsive.isTablet(context);
  final isDesktop = Responsive.isDesktop(context);
  final isLandscape = Responsive.isLandscape(context);
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showGeneralDialog<bool>(
    context: context,
    barrierLabel: "Reset Password",
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
              maxWidth: isLandscape
                  ? (isDesktop ? 320 : isTablet ? 280 : 240)
                  : (isDesktop ? 400 : isTablet ? 360 : 290),
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
                    "Reset Password?",
                    style: GoogleFonts.kameron(
                      fontSize: isLandscape
                          ? (isDesktop ? 18 : isTablet ? 16 : 14.5)
                          : (isDesktop ? 22 : isTablet ? 20 : 17),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Message
                  Text(
                    "This will update the selected user's password.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.kameron(
                      fontSize: isLandscape
                          ? (isDesktop ? 15 : isTablet ? 13 : 12.5)
                          : (isDesktop ? 16 : isTablet ? 15 : 14),
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.75),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

                      // Cancel
                      GestureDetector(
                        onTap: () => Navigator.pop(context, false),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.kameron(
                              fontSize: isLandscape
                                  ? (isDesktop ? 16 : isTablet ? 14 : 13)
                                  : (isDesktop ? 18 : isTablet ? 17 : 15),
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),

                      // Confirm
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF30DD04),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 26,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          "Confirm",
                          style: GoogleFonts.kameron(
                            fontSize: isLandscape
                                ? (isDesktop ? 16 : isTablet ? 14 : 13)
                                : (isDesktop ? 18 : isTablet ? 17 : 15),
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
          "Reset Password",
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
          icon: Icon(Icons.arrow_back_ios_new_sharp,
              size: Responsive.font(context, mobile: 25, tablet: 30, desktop: 35)),
          iconSize: Responsive.spacing(context, mobile: 28, tablet: 32, desktop: 36),
          color: Theme.of(context).colorScheme.onSurface,
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        leadingWidth: 50,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Reset cashier password.",style: GoogleFonts.kameron(
                  fontSize: Responsive.font(context, mobile: 18, tablet: 20, desktop: 22),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("Update account credentials to maintain secure login access.",style: GoogleFonts.kameron(
                fontSize: Responsive.font(context, mobile: 14, tablet: 15, desktop: 17),
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
              ),
            ),
            ],
          ),

          const SizedBox(height: 30),

            Text(
              "Select User",
              style: GoogleFonts.kameron(
                fontSize: Responsive.font(
                  context,
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                ),
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface
              ),
            ),
            const SizedBox(height: 10),
            buildDropdown(),
            const SizedBox(height: 20),

            Text(
              "New Password",
              style: GoogleFonts.kameron(
                fontSize: Responsive.font(
                  context,
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                ),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            buildField(
              label: "New Password",
              controller: newPassController,
              icon: Icons.lock,
              isVisible: _newPasswordVisible,
              onVisibilityToggle: () {
                setState(() => _newPasswordVisible = !_newPasswordVisible);
              },
              errorText: newError,
            ),

            buildField(
              label: "Confirm Password",
              controller: confirmPassController,
              icon: Icons.lock_outline,
              isVisible: _confirmPasswordVisible,
              onVisibilityToggle: () {
                setState(() => _confirmPasswordVisible = !_confirmPasswordVisible);
              },
              errorText: confirmError,
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                
                setState(() {
                  newError = newPassController.text.trim().isEmpty
                      ? "Field is empty"
                      : null;

                  confirmError = confirmPassController.text.trim().isEmpty
                      ? "Field is empty"
                      : null;
                });

                _submit();

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF30DD04),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Reset Password",
                  style: GoogleFonts.kameron(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}