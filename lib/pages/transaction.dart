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

  int _currentPage = 0;
  final int _rowsPerPage = 15;
  int _totalRows = 0;
  int _totalPages = 0;

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

      int offset = _currentPage * _rowsPerPage; 

      DateTime? start;
      DateTime? end;


      if(selectedFilter == 'Today'){
        start = DateTime(now.year, now.month, now.day);
        end = start.add(Duration(days: 1));

      }
      else if (selectedFilter == 'Weekly') {

        start = now.subtract(const Duration(days: 7));
        end = now;
      } 
      else if (selectedFilter == 'Custom' && selectedRange != null) {

        start = selectedRange!.start;
        end = selectedRange!.end;

      }

      _totalRows = await countTransactions(
        startDate: start,
        endDate: end,
      );

       _totalPages = (_totalRows / _rowsPerPage).ceil();

        setState(() {
          _transactionDatas = fetchTransactions(
            startDate: start,
            endDate: end,
            limit: _rowsPerPage,
            offset: offset
          );
        });

    }catch(error){
      debugPrint("Error refreshing transactions: $error");
    }
    
  
  }

  @override
  void initState() {
    super.initState();
    _refreshTransactions();
  }


  Widget _buildPageNumbers() {
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_totalPages, (index) {

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: InkWell(
            onTap: () {
                    setState(() {
                      _currentPage = index;
                    });
                    _refreshTransactions();
                  },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _currentPage == index ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                (index + 1).toString(),
                style: TextStyle(
                  color: _currentPage == index ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }),
    );
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
                          setState(() {
                            selectedFilter = value!;
                            _currentPage = 0;   
                            
                          });

                            if (value == 'Custom') {
                              await _pickDateRange(context);
                            } else {
                              _refreshTransactions();
                            }     
          
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

              SizedBox(height: 20,),
               Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _currentPage > 0
                      ? () {
                        setState(() {
                          _currentPage--;
                        });
                        _refreshTransactions();
                      } : null,
                      icon: Icon(Icons.chevron_left)),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: _buildPageNumbers(),
                      ),

                      IconButton(
                      onPressed:  _currentPage < _totalPages - 1 ?() {
                        setState(() {
                          _currentPage++;
                        });
                        _refreshTransactions();
                      }:null,
                      icon: Icon(Icons.chevron_right)),
                    ],
                  )


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
