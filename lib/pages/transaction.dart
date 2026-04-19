import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/db/transaction.dart';
import 'package:intl/intl.dart';
import 'package:pos_app/pages/receipt.dart';
import 'package:pos_app/utils/boxShadow.dart';
import 'package:pos_app/utils/responsive.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/services/exports/pdf/transactionReports.dart';

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
    try {
      DateTime now = DateTime.now();
      int offset = _currentPage * _rowsPerPage;

      DateTime? start;
      DateTime? end;

      if (selectedFilter == 'Today') {
        start = DateTime(now.year, now.month, now.day);
        end = start.add(const Duration(days: 1));
      } else if (selectedFilter == 'Weekly') {
        start = now.subtract(const Duration(days: 7));
        end = now;
      } else if (selectedFilter == 'Custom' && selectedRange != null) {
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
          offset: offset,
        );
      });
    } catch (error) {
      debugPrint("Error refreshing transactions: $error");
    }
  }


  Future<List<Map<String, dynamic>>> fetchAllTransactionsForExport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await fetchTransactions(
      startDate: startDate,
      endDate: endDate,
  );  
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

  List<Map<String, dynamic>> groupTransactionsBySale(List<Map<String, dynamic>> transactions) {
    Map<int, Map<String, dynamic>> grouped = {};

    for (var t in transactions) {
      final id = t['transaction_id'];

      if (grouped.containsKey(id)) {
        grouped[id]!['products'].add({
          'product_name': t['product_name'],
          'quantity': t['quantity'],
          'price': t['price'],
        });
      } else {
        grouped[id] = {
          'id': id,
          'created_at': t['created_at'],
          'processed_by': t['username'],
          'payment_type': t['payment_type'],
          'status': t['status'],
          'total_amount': t['total_amount'],
          'change_amount': t['change_amount'],
          'amount_received': t['amount_received'],
          'action': t['action'],
          'products': [
            {
              'product_name': t['product_name'],
              'quantity': t['quantity'],
              'price': t['price'],
            }
          ],
        };
      }
    }
    return grouped.values.toList();
  }


Future<void> _exportTransactions() async {
  try {
    setState(() => isLoading = true);

    DateTime now = DateTime.now();
    DateTime? start;
    DateTime? end;

    if (selectedFilter == 'Today') {
      start = DateTime(now.year, now.month, now.day);
      end = start.add(const Duration(days: 1));
    } else if (selectedFilter == 'Weekly') {
      start = now.subtract(const Duration(days: 7));
      end = now;
    } else if (selectedFilter == 'Custom' && selectedRange != null) {
      start = selectedRange!.start;
      end = selectedRange!.end;
    }

    final raw = await fetchAllTransactionsForExport(
      startDate: start,
      endDate: end,
    );

    if (raw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("No transactions to export"),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final file = await exportTransactionPDF(
      transactions: raw,
      dateRange: selectedRange,
      filter: selectedFilter,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Transaction records exported successfully!"),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Export failed: $e"),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );

    debugPrint("Export error: $e");
  } finally {
    setState(() => isLoading = false);
  }
}



  @override
  Widget build(BuildContext context) {

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        shadowColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
        automaticallyImplyLeading: false,
        elevation: 3,
        toolbarHeight: isDesktop ? 80 : isTablet ? 70 : 60,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_sharp, size: isDesktop ? 35 : isTablet ? 30 : 25),
          iconSize: Responsive.spacing(context, mobile: 25, tablet: 30, desktop: 35),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        leadingWidth: 50,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Transactions Records",
              style: GoogleFonts.kameron(
                fontSize: isDesktop ? 22 : isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(
                      height: Responsive.spacing(context,
                      mobile: 40, tablet: 45, desktop: 50),
                      child: Material(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                        elevation: 4,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap:  isLoading ? null : _exportTransactions,
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Row(
                              children: [
                                Icon(Icons.download, size: 18, color: Colors.white),
                                SizedBox(width: 5),
                                Text(isLoading ? "Exporting" :
                                  'Export',
                                  style: GoogleFonts.kameron(
                                    fontSize: isDesktop ? 15 : isTablet ? 14 : 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
          ],
        ),
      ),

   
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),
                    Text(
                      'Date Range',
                      style: GoogleFonts.kameron(
                        fontSize: Responsive.font(context, mobile: 15, tablet: 21, desktop: 24),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: () => _pickDateRange(context),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: Responsive.font(context, mobile: 12, tablet: 12, desktop: 14),
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey[100],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    selectedRange == null
                                        ? 'Select date range'
                                        : '${DateFormat('MM/dd/yyyy').format(selectedRange!.start)} - ${DateFormat('MM/dd/yyyy').format(selectedRange!.end)}',
                                    style: GoogleFonts.kameron(
                                      fontSize: Responsive.font(context, mobile: 14, tablet: 17, desktop: 19),
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Icon(Icons.date_range, color: Color.fromARGB(255, 68, 68, 68)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            dropdownColor: Colors.grey[100],
                            iconEnabledColor: Colors.black87,
                            value: selectedFilter,
                            items: ['Today', 'Weekly', 'Custom']
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e, style: GoogleFonts.kameron(fontSize: 16, color: Colors.black)),
                                    ))
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
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? Color.fromARGB(248, 233, 232, 232) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: ShadowHelper.getShadow(context)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return FutureBuilder<List<Map<String, dynamic>>>(
                              future: _transactionDatas,
                              builder: (context, snapshot) {
                                final isDesktop = Responsive.isDesktop(context);
                                final isTablet = Responsive.isTablet(context);
                                final isMobile = Responsive.isMobile(context);

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
                                  return SizedBox(
                                    height: MediaQuery.of(context).size.height - 400,
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                           Icon(Icons.receipt_long, size: 55, color: Colors.grey[400]),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No transactions found',
                                            style: GoogleFonts.kameron(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                final groupedTransactions = groupTransactionsBySale(transactions);

                                return SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: constraints.maxWidth,
                                        maxWidth: isMobile ? double.infinity : constraints.maxWidth,
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: DataTable(
                                          showCheckboxColumn: false,
                                          columnSpacing: isDesktop ? 38 : isTablet ? 35 : 30,
                                          headingRowColor:  MaterialStateProperty.all(const Color.fromARGB(228, 255, 255, 255)),
                                          dataRowHeight: isDesktop ? 60 : isTablet ? 55 : 45,
                                          headingRowHeight: isDesktop ? 58 : isTablet ? 55 : 50,
                                          columns: [
                                            DataColumn(label: Text('ID', style: GoogleFonts.kameron(fontSize: isDesktop ? 21 : isTablet ? 18 : 14.5, fontWeight: FontWeight.w500,color: Colors.black))),
                                            DataColumn(label: Text('Processed By', style: GoogleFonts.kameron(fontSize: isDesktop ? 21 : isTablet ? 18 : 14.5, fontWeight: FontWeight.w500,color: Colors.black))),
                                            DataColumn(label: Text('Date', style: GoogleFonts.kameron(fontSize: isDesktop ? 21 : isTablet ? 18 : 14.5, fontWeight: FontWeight.w500,color: Colors.black))),
                                            DataColumn(label: Text('Action', style: GoogleFonts.kameron(fontSize: isDesktop ? 21 : isTablet ? 18 : 14.5, fontWeight: FontWeight.w500,color: Colors.black))),
                                            DataColumn(label: Text('Payment Method', style: GoogleFonts.kameron(fontSize: isDesktop ? 21 : isTablet ? 18 : 14.5, fontWeight: FontWeight.w500,color: Colors.black))),
                                          ],
                                          rows: groupedTransactions.map((transaction) {
                                            return DataRow(
                                              onSelectChanged: (selected) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => ViewReceipt(transaction: transaction)),
                                                );
                                              },
                                              cells: [
                                                DataCell(Text(
                                                  (transaction['id'] ?? '').toString(),
                                                  style: GoogleFonts.kameron(fontSize: isDesktop ? 21 : isTablet ? 18 : 14,color: Colors.black),
                                                )),

                                                DataCell(Text(
                                                  capitalizeEachWord(transaction['processed_by']?.toString()),
                                                  style: GoogleFonts.kameron(fontSize: isDesktop ? 21 : isTablet ? 18 : 14,color: Colors.black),
                                                )),

                                                DataCell(Text(
                                                  transaction['created_at'] != null
                                                      ? DateFormat('MM/dd/yyyy').format(
                                                          DateTime.parse(transaction['created_at'].toString()),
                                                        )
                                                      : 'N/A',
                                                  style: GoogleFonts.kameron(fontSize: isDesktop ? 21 : isTablet ? 18 : 14,color: Colors.black),
                                                )),

                                                DataCell(Text(
                                                  transaction['action']?.toString() ?? 'N/A',
                                                  style: GoogleFonts.kameron(fontSize: isDesktop ? 21 : isTablet ? 18 : 14,color: Colors.black),
                                                )),

                                                DataCell(Text(
                                                  capitalizeEachWord(transaction['payment_type']?.toString()),
                                                  style: GoogleFonts.kameron(fontSize: isDesktop ? 21 : isTablet ? 18 : 14,color: Colors.black),
                                                )),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),   // ← Extra space so pagination doesn't overlap
                  ],
                ),
              ),
            ),
          ),

          // Fixed Pagination at the bottom (same as Inventory)
          if (_totalRows > 0)
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: const EdgeInsets.symmetric(vertical: 65),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage > 0
                        ? () {
                            setState(() {
                              _currentPage--;
                            });
                            _refreshTransactions();
                          }
                        : null,
                  ),
                  _buildPageNumbers(),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage < _totalPages - 1
                        ? () {
                            setState(() {
                              _currentPage++;
                            });
                            _refreshTransactions();
                          }
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

String capitalizeEachWord(String? text) {
  if (text == null || text.isEmpty) return 'N/A';

  return text
      .split(' ')
      .map((word) =>
          word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : '')
      .join(' ');
}