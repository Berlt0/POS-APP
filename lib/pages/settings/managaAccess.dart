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

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: const Text("Remove Cashier"),
      content: Text("Are you sure you want to permanently delete $name?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);

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
          child: const Text(
            "Delete",
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}




  Widget buildUserCard(int index) {
    final user = cashiers[index];
    final isDisabled = int.tryParse(user["is_disabled"].toString()) == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
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
              onChanged: (value) => toggleStatus(index),
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
      backgroundColor: Colors.grey[50],
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
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
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
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Enable or disable access • Swipe to manage",
            style: GoogleFonts.kameron(
              fontSize: 14,
              color: Colors.grey.shade600,
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