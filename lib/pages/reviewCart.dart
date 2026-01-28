import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/models/cartItem.dart';

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
              onPressed: () {
                
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
