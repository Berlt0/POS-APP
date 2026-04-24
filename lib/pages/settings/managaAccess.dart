import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/db/manageAccess.dart';
import 'package:pos_app/utils/responsive.dart';

class ManageCashierAccess extends StatefulWidget {
  const ManageCashierAccess({super.key});

  @override
  State<ManageCashierAccess> createState() => _ManageCashierAccessState();
}

class _ManageCashierAccessState extends State<ManageCashierAccess> {
  List<Map<String, dynamic>> cashiers = [];



  @override
  void initState() {
    super.initState();
    _loadCashiers();
  }


  void toggleStatus(int index) async {
  final user = cashiers[index];
  final id = user["id"]; 

  final current = (user["is_disabled"] as int) == 1;
  final newValue = current ? 0 : 1;

  final success = await ManageAccess().toggleCashierStatus(
    id: id,
    isDisabled: newValue,
  );

  if (success) {
    setState(() {
      cashiers[index] = {
        ...user,
        "is_disabled": newValue, 
      };
    });
  }
}

  

 void _loadCashiers() async {
    final data = await ManageAccess().getCashiers();
    setState(() {
      cashiers = data.map((e) => Map<String, dynamic>.from(e)).toList();
    });
  }


  void deleteUser(int index) {
  final user = cashiers[index];
  final id = user["id"];
  final name = user["name"];

  showGeneralDialog<bool>(
    context: context,
    barrierLabel: "Delete Cashier",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.3),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      final isTablet = Responsive.isTablet(context);
      final isDesktop = Responsive.isDesktop(context);

      return Center(
        child: Material(
          color: Theme.of(context).colorScheme.surface, 
          borderRadius: BorderRadius.circular(16),
          type: MaterialType.transparency,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 380 : isTablet ? 350 : 290,
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
                    "Remove Cashier?",
                    style: GoogleFonts.kameron(
                      fontSize: isDesktop ? 22 : isTablet ? 20 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Message
                  Text(
                    "Are you sure you want to permanently delete $name?\nThis action cannot be undone.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.kameron(
                      fontSize: isDesktop ? 16 : isTablet ? 15.5 : 14.5,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(1)
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Cancel Button
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(false),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.kameron(
                              fontSize: isDesktop ? 18 : isTablet ? 17 : 15.5,
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      // Delete Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop(true); // Close dialog first

                          final success = await ManageAccess().removeCashier(id, name);

                          if (success) {
                            setState(() {
                              cashiers.removeAt(index);
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("$name has been removed"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Failed to delete user"),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                        child: Text(
                          "Delete",
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
          curve: Curves.easeOutBack,   // Nice bounce animation
        ),
        child: child,
      );
    },
  );
}


Future<bool?> showDisableCashierModal(
  BuildContext context,
  String name,
) {
  return showGeneralDialog<bool>(
    context: context,
    barrierLabel: "Disable Cashier",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.3),
    transitionDuration: const Duration(milliseconds: 300),

    pageBuilder: (context, anim1, anim2) {
      final isTablet = Responsive.isTablet(context);
      final isDesktop = Responsive.isDesktop(context);

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
                    "Disable Cashier?",
                    style: GoogleFonts.kameron(
                      fontSize: isDesktop ? 22 : isTablet ? 20 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Message
                  Text(
                    "Are you sure you want to disable $name?\nThey will no longer be able to access the system.",
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

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Cancel
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
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      // Disable Button
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
                          "Disable",
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
}


  Widget buildUserCard(int index) {
    final user = cashiers[index];
    final isDisabled = int.tryParse(user["is_disabled"].toString()) == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
  
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDisabled ? Colors.red : Colors.blue,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: ColorFiltered(
                  colorFilter: isDisabled
                      ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                      : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                  child: Image.asset(
                    "assets/Legendaries.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

  
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user["name"],
                    style: GoogleFonts.kameron(
                      fontSize: Responsive.font(
                        context,
                        mobile: 17,
                        tablet: 19,
                        desktop: 21,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDisabled ? Colors.red.shade50 : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          isDisabled ? "Disabled" : "Active",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDisabled ? Colors.red.shade700 : Colors.green.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),


            Switch(
              value: !isDisabled,
              activeColor: Colors.green,
              onChanged: (value) async {
                final user = cashiers[index];

                final isDisabled = (user["is_disabled"] as int) == 1;

                if (isDisabled) {
                  toggleStatus(index);
                  return;
                }

                final confirm = await showDisableCashierModal(
                  context,
                  user["name"],
                );

                if (confirm != true) return;

                toggleStatus(index);
              },
            ),

            const SizedBox(width: 8),

            // Delete Button
            IconButton(
              onPressed: () => deleteUser(index),
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              tooltip: "Delete Cashier",
            ),
          ],
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Manage Cashier Access",
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
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Text(
            "Cashier Accounts",
            style: GoogleFonts.kameron(
              fontSize: Responsive.font(
                context,
                mobile: 17,
                tablet: 19,
                desktop: 21,
              ),
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Enable or disable access • Swipe to manage",
            style: GoogleFonts.kameron(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
            ),
          ),
          const SizedBox(height: 20),

         
          ...List.generate(
            cashiers.length,
            (index) => buildUserCard(index),
          ),

          if (cashiers.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  "No cashier accounts found",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }
}