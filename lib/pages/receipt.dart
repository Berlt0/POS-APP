import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
// import 'package:pos_app/pages/home.dart';
import 'package:pos_app/db/transaction.dart';

class ViewReceipt extends StatefulWidget {

  // final Map<String, dynamic> transaction;
  final dynamic transaction;

  const ViewReceipt({super.key,required this.transaction});

  @override
  State<ViewReceipt> createState() => _ViewReceiptState();
}

class _ViewReceiptState extends State<ViewReceipt> {
  Map<String, dynamic>? transaction;


    Future<void> _loadTransaction() async {
     
    if(widget.transaction is Map<String, dynamic>) {

      setState(() {
        transaction = widget.transaction;
      });

    }else if(widget.transaction is int) {

      final int transactionId = widget.transaction;

      final sale = await fetchTransactionDetails(transactionId);

      if (sale.isNotEmpty) {
        
        Map<String, dynamic> grouped = {
          'id': sale[0]['transaction_id'],
          'created_at': sale[0]['created_at'],
          'processed_by': sale[0]['username'],
          'payment_type': sale[0]['payment_type'],
          'total_amount': sale[0]['total_amount'],
          'change_amount': sale[0]['change_amount'],
          'amount_received': sale[0]['amount_received'],
          'action': sale[0]['action'],
          'products': sale.map((t) => {
            'product_name': t['product_name'],
            'quantity': t['quantity'],
            'price': t['price'],
          }).toList(),
        };

      setState((){

        transaction = grouped;

      });

    }
    }
  }

   @override
    void initState() {
      super.initState();
      _loadTransaction();
  }

  @override
  Widget build(BuildContext context) {
    
  if (transaction == null) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }    

    final List products  = transaction?['products'] ?? [];
    

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
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Store name:',style: GoogleFonts.kameron(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),),
                    Text('Gilbert Convenience Store',style: GoogleFonts.kameron(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Address: ',style: GoogleFonts.kameron(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),),
                    Text('Brgy. Balangasan, Pagadian City',style: GoogleFonts.kameron(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),),
                  ],
                ),      
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Date: ',style: GoogleFonts.kameron(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),),
                    Text(
                      transaction!['created_at'] != null
                          ? DateFormat('MM/dd/yyyy').format(DateTime.parse(transaction!['created_at']))
                          : 'N/A',
                      style: GoogleFonts.kameron(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Payment Method: ',style: GoogleFonts.kameron(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),),
                    Text(capitalizeEachWord(transaction!['payment_type'] ?? ''),style: GoogleFonts.kameron(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),),
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
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'QTY',
                              style: GoogleFonts.kameron(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
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
                                fontWeight: FontWeight.w600,
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
                            child: Text(capitalizeEachWord(item['product_name'] ?? ''), style: GoogleFonts.kameron(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              item['quantity'].toString(),
                              textAlign: TextAlign.center,
                            style: GoogleFonts.kameron(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '\₱${item['price'].toStringAsFixed(2)}',
                              textAlign: TextAlign.right,
                              style: GoogleFonts.kameron(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      )
                    )).toList(),
                  ],
                ),

                SizedBox(height: 5),
                Divider(thickness: 2),
                SizedBox(height: 10),
               Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TOTAL AMOUNT:', style: GoogleFonts.kameron(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    )),
                    Text('\₱${(transaction!['total_amount'] ?? 0).toStringAsFixed(2)}', style: GoogleFonts.kameron(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('AMOUNT RECEIVED:', style: GoogleFonts.kameron(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    )),
                    Text('\₱${(transaction!['amount_received'] ?? 0).toStringAsFixed(2)}',style: GoogleFonts.kameron(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('CHANGE:', style: GoogleFonts.kameron(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    )),
                    Text('\₱${(transaction!['change_amount'] ?? 0).toStringAsFixed(2)}',style: GoogleFonts.kameron(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),),
                  ],
                ),
                
                SizedBox(height: 40),
                Center(
                  child: Text(
                    'Thank you for your purchase!',
                    style: GoogleFonts.kameron(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w400
                    ),
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


String capitalizeEachWord(String text) {
  return text
      .split(' ')
      .map((word) =>
          word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' : '')
      .join(' ');
}
