import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/db/transaction.dart';
import 'package:intl/intl.dart';


class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {

  String selectedFilter = 'Today';
  DateTimeRange? selectedRange;
  Future<List<Map<String, dynamic>>>? _transactionDatas;
  bool isLoading = false;


  Future<void> _pickDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: selectedRange,
    );

    if (picked != null) {
      setState(() {
        selectedRange = picked;
        selectedFilter = 'Custom';
      
      });

      await _refreshTransactions();
    }
  }


  Future<void> _refreshTransactions() async {

    try{

      DateTime now = DateTime.now();

      if(selectedFilter == 'Today'){
        DateTime start = DateTime(now.year, now.month, now.day);
        DateTime end = start.add(Duration(days: 1));

        setState(() {
          _transactionDatas = fetchTransactions(startDate: start, endDate: end);
        });

      }
      else if (selectedFilter == 'Weekly') {

        DateTime start = now.subtract(const Duration(days: 7));

        setState(() {
          
          _transactionDatas = fetchTransactions(
            startDate: start,
            endDate: now,
          );
        });

      } 
      else if (selectedFilter == 'Custom' && selectedRange != null) {

        setState(() {
          _transactionDatas = fetchTransactions(
            startDate: selectedRange!.start,
            endDate: selectedRange!.end,
          );
        });

      }


    }catch(error){
      print("Error refreshing transactions: $error");
    }
    
  
  }

  @override
  void initState() {
    super.initState();
    _refreshTransactions();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         backgroundColor: Colors.grey[100],
        shadowColor: Colors.grey.withOpacity(0.5),
        automaticallyImplyLeading: false,
        elevation: 3,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context,true),
        ),
        title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Transactions Records",
                style: GoogleFonts.kameron(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ),
              ),
            ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5,),
                Text(
                  'Date Range',
                  style: GoogleFonts.kameron(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  )
                ),
                SizedBox(height: 10,),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () => _pickDateRange(context),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedRange == null
                                    ? 'Select date range'
                                    : '${DateFormat('MM/dd/yyyy').format(selectedRange!.start)}'
                                      ' - '
                                      '${DateFormat('MM/dd/yyyy').format(selectedRange!.end)}',
                                style: GoogleFonts.kameron(
                                  fontSize: 15,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                              const Icon(
                                Icons.date_range,
                                color: Color.fromARGB(255, 68, 68, 68)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10,),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                       value: selectedFilter,
                       items: ['Today', 'Weekly', 'Custom']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.kameron(fontSize: 16, color:Colors.black),)))
                      .toList(),
                        onChanged: (value) async {
                          setState(() async{
                            selectedFilter = value!;   
                            
                            if (value == 'Custom') {
                              await _pickDateRange(context);
                            } else {
                              _refreshTransactions();
                            }     
                          });

                          await _refreshTransactions();
          
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                  ),
                  SizedBox(height: 15,),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _transactionDatas,
                    builder: (context, snapshot){
                    

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading transactions records',
                          style: GoogleFonts.kameron(color: Colors.black),
                        ),
                      );
                    }

                    final transactions = snapshot.data ?? [];

                    if (transactions.isEmpty) {
                    return Center(
                      child: Text(
                        'No transactions records found',
                        style: GoogleFonts.kameron(color: Colors.black),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text('ID',style: tableTextStyle(fontSize: 15, fontWeight: FontWeight.w500),)),
                          DataColumn(label: Text('Date',style: tableTextStyle(fontSize: 15, fontWeight: FontWeight.w500),)),
                          DataColumn(label: Text('Action',style: tableTextStyle(fontSize: 15, fontWeight: FontWeight.w500),)),
                          DataColumn(label: Text('Payment Method',style: tableTextStyle(fontSize: 15, fontWeight: FontWeight.w500),)),
                        ],
                        rows: transactions.map<DataRow>((transaction) {
                          return DataRow(cells: [
                            DataCell(Text(transaction['transaction_id'].toString())),
                            DataCell(Text(DateFormat('MM/dd/yyyy').format(DateTime.parse(transaction['created_at'])))),
                            DataCell(Text(transaction['action'])),
                            DataCell(Text(transaction['payment_type'])),
                          ]);
                        }).toList(),
                      ),
                    ),
                  );


                    }
                  ),




            ],
          ),
        ),
      ),
    );
  }
}



TextStyle tableTextStyle({
  double fontSize = 16,
  FontWeight fontWeight = FontWeight.normal,
  Color color = Colors.black,
}) {
  return GoogleFonts.kameron(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
  );
}
