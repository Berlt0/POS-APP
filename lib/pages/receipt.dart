import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:pos_app/db/transaction.dart';
import 'package:pos_app/db/database.dart';


class ViewReceipt extends StatefulWidget {

  // final Map<String, dynamic> transaction;
  final dynamic transaction;

  const ViewReceipt({super.key,required this.transaction});

  @override
  State<ViewReceipt> createState() => _ViewReceiptState();
}

class _ViewReceiptState extends State<ViewReceipt> {
  Map<String, dynamic>? transaction;

  String? saleStatus;


    Future<void> _loadTransaction() async {
     
    if(widget.transaction is Map<String, dynamic>) {

      setState(() {
        transaction = widget.transaction;
      });

    }else if(widget.transaction is int) {

      final int transactionId = widget.transaction;

      final sale = await fetchTransactionDetails(transactionId);
      debugPrint(sale.toString());

      if (sale.isNotEmpty) {
        
        Map<String, dynamic> grouped = {
          'id': sale[0]['transaction_id'],
          'created_at': sale[0]['created_at'],
          'processed_by': sale[0]['username'],
          'payment_type': sale[0]['payment_type'],
          'status': sale[0]['status'],
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
      _initializeTransaction();
  }

  Future<void> _initializeTransaction() async {
    await _loadTransaction(); 

    if (transaction != null) {
    await _loadSaleStatus(transaction!['id']);
  }

    if (mounted) {
      setState(() {}); 
    }
}

Future<void> _loadSaleStatus(int saleId) async {
  final db = await AppDatabase.database;

  final result = await db.query(
    'sales',
    columns: ['status'],
    where: 'id = ?',
    whereArgs: [saleId],
    limit: 1,
  );

  if (!mounted || result.isEmpty) return;

  setState(() {
    saleStatus = (result.first['status'] as String?)?.trim().toLowerCase();
  });
}

  @override
  Widget build(BuildContext context) {
    
  if (transaction == null) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }    

  final List products  = transaction?['products'] ?? [];


  Future<void> _showVoidConfirmation(BuildContext context) async {
    final TextEditingController reasonController = TextEditingController();

    final String? reason = await showGeneralDialog<String>(
      context: context,
      barrierLabel: "Void Sale",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        print(transaction!['status']);
        return Center(
          child: Material(
            type: MaterialType.transparency,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Void Sale?",
                      style: GoogleFonts.kameron(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Please provide a reason to void this transaction.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.kameron(fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: reasonController,
                      autofocus: true,
                      style: GoogleFonts.kameron(),
                      decoration: InputDecoration(
                        hintText: 'Enter reason...',
                        hintStyle: GoogleFonts.kameron(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Cancel", style: GoogleFonts.kameron(color: Colors.black, fontWeight: FontWeight.w500)),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            if (reasonController.text.trim().isEmpty) return;
                            Navigator.pop(context, reasonController.text.trim());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 180, 37, 27),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text("Confirm Void", style: GoogleFonts.kameron(color: Colors.white, fontWeight: FontWeight.w500)),
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
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: child,
        );
      },
  );

 
  if (reason != null && context.mounted) {
    
     try {
      await voidSale(transaction!['id'], transaction!['processed_by'], reason);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Transaction Voided: $reason")),
    );
      Navigator.pop(context);
  } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error voiding transaction: $e")),
    );
  }
  }
}




    

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
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
                    SizedBox(height: 30,),
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
                    SizedBox(height: 30),
                  ],
                ),
              ),
              SizedBox(height: 80,),
              saleStatus == "voided" 
              ? Center(
                  child: Column(
                    children: [
                      Text(
                        'This sale is voided.',
                        style: GoogleFonts.kameron(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      Text(
                        'The operation has been cancelled.',
                        style: GoogleFonts.kameron(
                          color: const Color.fromARGB(232, 255, 82, 82),
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              :Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  actionButton(
                    value: 'Print',
                    color: const Color.fromARGB(255, 38, 116, 41),
                    onPressed: () {
                      // Implement print functionality
                    },
                    width: 120,
                    height: 45,
                  ),
                  SizedBox(width: 20),
                  actionButton(
                    value:  'Void',
                    color: const Color.fromARGB(255, 180, 37, 27),
                    onPressed: () { _showVoidConfirmation(context); },
                    width: 120,
                    height: 45,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}






Widget actionButton({
  required String value,
  required Color color,
  required VoidCallback onPressed,
  double width = 100,
  double height = 40,
}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 2,
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 1, 
      ),
      child: Text(
        value,
        style: GoogleFonts.kameron(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}



String capitalizeEachWord(String text) {
  return text
      .split(' ')
      .map((word) =>
          word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' : '')
      .join(' ');
}
