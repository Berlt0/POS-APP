import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ViewReceipt extends StatefulWidget {

  final Map<String, dynamic> transaction;

  const ViewReceipt({super.key,required this.transaction});

  @override
  State<ViewReceipt> createState() => _ViewReceiptState();
}

class _ViewReceiptState extends State<ViewReceipt> {
  

  @override
  Widget build(BuildContext context) {
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
                    Text('Date: '),
                    Text(DateFormat('MM/dd/yyyy').format(DateTime.parse(widget.transaction['created_at']))),
                  ],
                ),
                Divider(),
                Text('Transaction ID: ${widget.transaction['transaction_id']}'),
                Text('Item 2 - \$15.00'),
                Text('Item 3 - \$5.00'),
                Divider(),
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