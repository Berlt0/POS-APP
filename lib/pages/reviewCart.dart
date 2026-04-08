import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/db/syncTransationHistory.dart';
import 'package:pos_app/models/cartItem.dart';
import 'package:pos_app/db/database.dart';
import 'package:pos_app/db/user.dart';
import 'package:pos_app/db/debug.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:pos_app/db/sync.dart';
import 'package:pos_app/utils/responsive.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();
String generateId() => Uuid().v4();

class ReviewCart extends StatefulWidget {
  const ReviewCart({super.key});

  @override
  State<ReviewCart> createState() => _ReviewCartState();
}

class PaymentResult {
  final String method;
  final double? amountReceived; 

  PaymentResult({required this.method, this.amountReceived});
}


class _ReviewCartState extends State<ReviewCart> {


  late List<CartItem> items;
  late double subtotal;
  late double total;
  late int totalQty;

  bool _initialized = false;

  int total_amount = 0;

  late StreamSubscription _connectivitySubscription;

  int? transactionId;

  @override
  void initState() {
    super.initState();

    _connectivitySubscription =Connectivity().onConnectivityChanged.listen((result) async {

      if(result != ConnectivityResult.none){
        print("Internet detected. Syncing...");
        await syncSales();
        await syncTransaction();
      }

    });
  }

  @override
void dispose() {
  _connectivitySubscription.cancel(); 
  super.dispose();
}


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


  Future<String?> _cashPaymentModal() {

    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    final isMobile = Responsive.isMobile(context);

  final TextEditingController _controller = TextEditingController();

  return showGeneralDialog<String>(
    context: context,
    barrierLabel: "Cash Payment",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {

      String? _errorText;

      return Center(
        child: Material(
          type: MaterialType.transparency, 
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
            return ConstrainedBox(
              constraints:  BoxConstraints(
                maxWidth: isDesktop ? 400 : isTablet ? 380  : 300,
              ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Enter Amount Received",
                        style: GoogleFonts.kameron(
                            fontSize: isDesktop ? 21 : isTablet ? 20 : 17,
                            fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 25),
                      TextField(
                        controller: _controller,
                        style: GoogleFonts.kameron( 
                          fontSize: isDesktop ? 22 : isTablet ? 20 : 18,
                        ),
                        onChanged: (value){
                            if (_errorText != null) {
                              setStateDialog(() => _errorText = null);
                            }
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration:  InputDecoration(
                          prefixText: '₱ ',
                          errorText: _errorText,
                          errorStyle: GoogleFonts.kameron( 
                            fontSize: isDesktop ? 17 : isTablet ? 15 : 13,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          labelText: 'Amount Received',
                          labelStyle: GoogleFonts.kameron(
                            fontSize: isDesktop ? 19 : isTablet ? 18 : 17,
                            color: Colors.black
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: isMobile ? 12 : 18,
                            horizontal: 20
                          )
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, null),
                            child: Text("Cancel", style: GoogleFonts.kameron(fontSize: isDesktop ? 21 : isTablet ? 18 : 15, color: Colors.black,fontWeight: FontWeight.w500),),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.fromLTRB(17, 10, 17, 10),
                              backgroundColor: Color(0xFF00C853),
                            ),
                            onPressed: ()  {
                              final enteredAmount = double.tryParse(_controller.text);
                              
                              setStateDialog(() {
                                if (_controller.text.isEmpty) {
                                  _errorText = 'Amount is required';
                                } else if (enteredAmount == null) {
                                  _errorText = 'Invalid amount';
                                } else if (enteredAmount < total) {
                                  _errorText =
                                      'Must be at least ₱${total.toStringAsFixed(2)}';
                                } else {
                                  _errorText = null;
                                }
                              });
            
                              if (_errorText != null) return;
            
                              Navigator.pop(context, _controller.text);
                            },
                            child: Text("Confirm", style: GoogleFonts.kameron(fontSize: isDesktop ? 21 : isTablet ? 19 : 15, color: Colors.black, fontWeight: FontWeight.w500),),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
               );
            }
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
}

    Future<PaymentResult?> _paymentModal() {
    return showModalBottomSheet<PaymentResult>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {

        final isDesktop = Responsive.isDesktop(context);
        final isTablet = Responsive.isTablet(context);
        final isMobile = Responsive.isMobile(context);

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select Payment Method",
                style: GoogleFonts.kameron(
                  fontSize: isDesktop ? 25 : isTablet ? 22 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.credit_card, size: isDesktop ? 35 : isTablet ? 30 : 25, ),
                title: Text("Credit / Debit Card", style: GoogleFonts.kameron(fontSize: isDesktop ? 20 : isTablet ? 18 : 15, fontWeight: FontWeight.w500),),
                onTap: () => Navigator.pop(context,PaymentResult(method: 'card',amountReceived: null)),
              ),
              ListTile(
                leading: Icon(Icons.account_balance_wallet,  size: isDesktop ? 35 : isTablet ? 30 : 25,),
                title:  Text("GCash", style: GoogleFonts.kameron(fontSize: isDesktop ? 20 : isTablet ? 18 : 15, fontWeight: FontWeight.w500)),
                onTap: () => Navigator.pop(context,PaymentResult(method: 'gcash',amountReceived: null)),
              ),
              ListTile(
                leading: Icon(Icons.money,  size: isDesktop ? 35 : isTablet ? 30 : 25,),
                title:  Text("Cash", style: GoogleFonts.kameron(fontSize: isDesktop ? 20 : isTablet ? 18 : 15, fontWeight: FontWeight.w500)),
                onTap: () async {

                final amountString = await _cashPaymentModal();

                if(amountString != null){
                  final amountReceived = double.tryParse(amountString) ?? 0;
                  
                  Navigator.pop(context,PaymentResult(method: 'cash',amountReceived: amountReceived));
                  }

                },
              ),
              SizedBox(height: 20,)
            ],
          ),
        );
      },
    );
  }

  


  Future<int> _saveSale(PaymentResult payment) async {
    final db = await AppDatabase.database;
    final int? userId = await UserDB().getLoggedInUserId();
    final String? userGlobalId = await UserDB().getLoggedInUserGlobalId();
    

    if(userId == null){
      debugPrint("No logged in user found.");
      return 0;
    }

    final insertedTransactionId = await db.transaction((txn) async {

      final saleGlobalId = generateId();
    
      final saleId = await txn.insert('sales', {
        'global_id': saleGlobalId,
        'user_id': userId, 
        'user_global_id': userGlobalId,
        'total_amount': total,
        'amount_received': payment.amountReceived ?? 0, 
        'change_amount': (payment.amountReceived != null) ? (payment.amountReceived! - total) : 0,
        'status': 'completed',
        'payment_type': payment.method,
        'created_at': DateTime.now().toIso8601String(),
        'is_synced': 0,
      });

      
      for (var item in items) {
        await txn.insert('sale_items', {
          'global_id': generateId(),
          'sale_id': saleId,
          'sale_global_id': saleGlobalId,
          'product_id': item.productId,
          'product_global_id': item.productGlobalId,
          'product_name': item.name,
          'price': item.price,
          'quantity': item.quantity,
          'created_at': DateTime.now().toIso8601String(),
          'is_synced': 0,
        });
      

      int updated = await txn.rawUpdate('''
        UPDATE products
        SET stock = stock - ?,
            is_synced = 0,
            updated_at = ?
        WHERE id = ? AND stock >= ?
      ''', [item.quantity,DateTime.now().toIso8601String() ,item.productId, item.quantity]);

      if (updated == 0) {
        throw Exception("Not enough stock for product ${item.name}");
      }
      }

       
      final transactionId = await txn.insert('transaction_history', {
        'global_id': generateId(),
        'user_id': userId,
        'user_global_id':userGlobalId ,
        'action': 'SALE',
        'entity_type': 'sale',
        'entity_id': saleId,
        'description': 'Sale of ${items.length} items',
        'created_at': DateTime.now().toIso8601String(),
        'is_synced': 0,
      });

     
      debugPrint('Sale saved with id: $saleId');
      
      return transactionId;
    });

    transactionId = insertedTransactionId;
    return insertedTransactionId;
  
  }


  @override
  Widget build(BuildContext context) {

    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        shadowColor: Colors.grey.withOpacity(0.5),
        elevation: 5,
        toolbarHeight: isDesktop ? 80 : isTablet ? 70 : 60,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_sharp,size: isDesktop ? 35 : isTablet ? 30 :25),   // or Icons.arrow_back
            iconSize: Responsive.spacing(context, mobile: 25, tablet: 30, desktop: 35), 
            color: Colors.black,
            onPressed: () => Navigator.pop(context),
            tooltip: 'Back',
          ),
      
          leadingWidth: 50,
        title: Text(
            "Review Cart",
            style: GoogleFonts.kameron(
              fontSize: isDesktop ? 22 : isTablet ? 20 :18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart,
                  color: const Color.fromARGB(255, 16, 19, 187),
                  size: isDesktop ? 35 : isTablet ? 30 : 23,
                ),
                const SizedBox(width: 6),
                Text(
                  'Cart Summary',
                  style: GoogleFonts.kameron(
                    fontSize: isDesktop ? 24 : isTablet ? 22 : 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = items[index];

                  return Container(
                    padding: const EdgeInsets.fromLTRB(12,12,12,12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                       BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 4,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
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
                                  width: isDesktop ? 80 : isTablet ? 80 : 50,
                                  height: isDesktop ? 80 : isTablet ? 70 : 50,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'assets/Legendaries.png',
                                  width: isDesktop ? 80 : isTablet ? 80 : 50,
                                  height: isDesktop ? 80 : isTablet ? 70 : 50,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                capitalizeEachWord(item.name),
                                style: GoogleFonts.kameron(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isDesktop ? 24 : isTablet ? 20 : 15,
                                ),
                              ),
                              Text(
                                '₱${item.price.toStringAsFixed(2)}',
                                style: GoogleFonts.kameron(
                                  fontSize: isDesktop ? 20 : isTablet ? 16 : 13,
                                  color: const Color.fromARGB(255, 55, 134, 58),
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
                                fontSize: isDesktop ? 22 : isTablet ? 18 : 15,
                              ),
                            ),
                            Text(
                              '₱${(item.price * item.quantity).toStringAsFixed(2)}',
                              style: GoogleFonts.kameron(fontSize: isDesktop ? 20 : isTablet ? 17 : 14, fontWeight: FontWeight.w500),
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
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                 BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                          ),
                ],
              ),
              child: Column(
                children: [
                  _rowText("Total Items", totalQty.toString(),
                      fontSize: isDesktop ? 19 : isTablet ? 17 : 14,
                    weight: FontWeight.w500),
                  const SizedBox(height: 3),
                  _rowText("Subtotal", '₱${subtotal.toStringAsFixed(2)}',
                      fontSize:  isDesktop ? 20 : isTablet ? 18 : 15, color:  Colors.black, weight: FontWeight.w500),
                  const SizedBox(height: 3),
                  _rowText("Total", '₱${total.toStringAsFixed(2)}',
                      fontSize:  isDesktop ? 22 : isTablet ? 20 : 16, weight: FontWeight.bold, color: Colors.red),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 3,
                backgroundColor: const Color(0xFF6FE5F2),
                minimumSize:  Size(double.infinity, isMobile ? 45 : 48),
              ),
              onPressed: () async {
                  final payment = await _paymentModal();


                if (payment != null) {
                  final transId = await _saveSale(payment);
                  if (transId <= 0) return;
                  await printTables();

                  //  try {
                  //   await syncSales();
                  //   await syncTransaction(); 
                  //   debugPrint("Transaction synced successfully!");
                  // } catch (e) {
                  //   debugPrint("Sync failed, will retry later: $e");
                  // }

                  setState(() {
                    items.clear();
                    totalQty = 0;
                    subtotal = 0;
                    total = 0;
                });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sale completed! Payment: ${payment.method}'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                     margin: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 16,
                      left: 16,
                      right: 16,
                    ),
                    duration: Duration(seconds: 3)),
                    
                  );

                  

                  Navigator.pop(context, transId );
                }
              },
              child: Text(
                "Proceed to Payment",
                style: GoogleFonts.kameron(
                  fontSize: isDesktop ? 20 : isTablet ? 18 : 15,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 7,)
          ],
        ),
      ),
    );
  }


  Widget _rowText(String label, String value,
      {required  weight, double fontSize = 14, Color color = Colors.black}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.kameron(
            fontWeight: weight,
            fontSize: fontSize,
            color: color,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.kameron(
            fontWeight: weight,
            fontSize: fontSize,
            color: color,
          ),
        ),
      ],
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