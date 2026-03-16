import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pos_app/pages/home.dart';

class ViewReceipt extends StatefulWidget {

  final Map<String, dynamic> transaction;

  const ViewReceipt({super.key,required this.transaction});

  @override
  State<ViewReceipt> createState() => _ViewReceiptState();
}

class _ViewReceiptState extends State<ViewReceipt> {
  

  @override
  Widget build(BuildContext context) {
    
    final List products = widget.transaction['products'] ?? [];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'CASH RECEIPT',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.kameron(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Store name:'),
                    Text('Gilbert Convenience Store'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Address: '),
                    Text('Brgy. Balangasan, Pagadian City'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Date: '),
                    Text(DateFormat('MM/dd/yyyy').format(DateTime.parse(widget.transaction['created_at']))),
                  ],
                ),
                Divider(thickness: 2),
                SizedBox(height: 5),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Text(
                              'Product',
                              style: GoogleFonts.kameron(
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'QTY',
                              style: GoogleFonts.kameron(
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Price',
                              style: GoogleFonts.kameron(
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      )
                    ),
                    
                    ...products.map<Widget>((item) => Container(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Text(capitalizeEachWord(item['product_name'] ?? '')),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              item['quantity'].toString(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '\$${item['price'].toStringAsFixed(2)}',
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      )
                    )).toList(),
                  ],
                ),

                SizedBox(height: 5),
                Divider(thickness: 2),
                Text(
                  'Total: \$30.00',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text('Payment Method: Cash'),
                Text('Amount Received: \$50.00'),
                Text('Change Given: \$20.00'),
                SizedBox(height: 40),
                Center(
                  child: Text(
                    'Visit Again!',
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}