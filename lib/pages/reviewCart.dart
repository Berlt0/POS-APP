import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/models/cartItem.dart';
import 'package:pos_app/db/database.dart';
import 'package:pos_app/db/user.dart';
import 'package:pos_app/db/debug.dart';

class ReviewCart extends StatefulWidget {
  const ReviewCart({super.key});

  @override
  State<ReviewCart> createState() => _ReviewCartState();
}

class _ReviewCartState extends State<ReviewCart> {
  late List<CartItem> items;
  late double subtotal;
  late double total;
  late int totalQty;

  bool _initialized = false;

  int total_amount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    items = args['items'] as List<CartItem>;
    subtotal = args['subtotal'] as double;
    total = args['total'] as double;
    totalQty = args['totalQuantity'] as int;

    _initialized = true;
  }



    Future<String?> _paymentModal() {
    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select Payment Method",
                style: GoogleFonts.kameron(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.credit_card),
                title: const Text("Credit / Debit Card"),
                onTap: () => Navigator.pop(context,'card'),
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: const Text("GCash"),
                onTap: () => Navigator.pop(context,'gcash'),
              ),
              ListTile(
                leading: const Icon(Icons.money),
                title: const Text("Cash"),
                onTap: ()  => Navigator.pop(context,'cash'),
              ),
            ],
          ),
        );
      },
    );
  }

  


  Future<void> _saveSale(String paymentType) async {
    final db = await AppDatabase.database;
    final int? userId = await UserDB().getLoggedInUserId();

    if(userId == null){
      debugPrint("No logged in user found.");
      return;
    }

    await db.transaction((txn) async {
    
      final saleId = await txn.insert('sales', {
        'user_id': userId, // replace with logged-in user ID
        'total_amount': total,
        'amount_received': total_amount, // you can add a field to enter cash received
        'change_amount': 0,       // calculate if needed
        'payment_type': paymentType,
        'created_at': DateTime.now().toIso8601String(),
      });

      
      for (var item in items) {
        await txn.insert('sale_items', {
          'sale_id': saleId,
          'product_id': item.productId,
          'product_name': item.name,
          'price': item.price,
          'quantity': item.quantity,
          'created_at': DateTime.now().toIso8601String(),
        });
      

      int updated = await txn.rawUpdate('''
        UPDATE products
        SET stock = stock - ?
        WHERE id = ? AND stock >= ?
      ''', [item.quantity, item.productId, item.quantity]);

      if (updated == 0) {
        throw Exception("Not enough stock for product ${item.name}");
      }
      }

       
      await txn.insert('transaction_history', {
        'user_id': userId,
        'action': 'SALE',
        'entity_type': 'sale',
        'entity_id': saleId,
        'description': 'Sale of ${items.length} items',
        'created_at': DateTime.now().toIso8601String(),
      });

     
      debugPrint('Sale saved with id: $saleId');
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        shadowColor: Colors.grey.withOpacity(0.5),
        elevation: 5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Padding(
          padding: const EdgeInsets.fromLTRB(1, 0, 0, 0),
          child: Text(
            "Review Cart",
            style: GoogleFonts.kameron(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 40),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart,
                  color: const Color.fromARGB(255, 16, 19, 187),
                  size: 24,
                ),
                const SizedBox(width: 6),
                Text(
                  'Cart Summary',
                  style: GoogleFonts.kameron(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = items[index];

                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: item.imagePath.isNotEmpty
                              ? Image.file(
                                  File(item.imagePath),
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'assets/Legendaries.png',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: GoogleFonts.kameron(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                '₱${item.price.toStringAsFixed(2)}',
                                style: GoogleFonts.kameron(
                                  fontSize: 13,
                                  color: const Color.fromARGB(255, 69, 161, 72),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'x${item.quantity}',
                              style: GoogleFonts.kameron(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₱${(item.price * item.quantity).toStringAsFixed(2)}',
                              style: GoogleFonts.kameron(fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _rowText("Total Items", totalQty.toString(),
                      fontSize: 15,),
                  const SizedBox(height: 5),
                  _rowText("Subtotal", '₱${subtotal.toStringAsFixed(2)}',
                      fontSize: 15, color: const Color.fromARGB(255, 18, 145, 23)),
                  const SizedBox(height: 5),
                  _rowText("Total", '₱${total.toStringAsFixed(2)}',
                      fontSize: 17, isBold: true, color: Colors.red),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6FE5F2),
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () async {
                final paymentType = await _paymentModal();
                if (paymentType != null) {
                  await _saveSale(paymentType);
                  await printTables();

                  setState(() {
                    items.clear();
                    totalQty = 0;
                    subtotal = 0;
                    total = 0;
                });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sale completed! Payment: $paymentType'),duration: Duration(seconds: 3)),
                  );

                  
                  Navigator.pop(context,true);
                }
              },
              child: Text(
                "Proceed to Payment",
                style: GoogleFonts.kameron(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _rowText(String label, String value,
      {bool isBold = false, double fontSize = 14, Color color = Colors.black}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.kameron(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: fontSize,
            color: color,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.kameron(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: fontSize,
            color: color,
          ),
        ),
      ],
    );
  }
}


