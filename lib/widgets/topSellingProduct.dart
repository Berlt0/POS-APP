import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/utils/responsive.dart';

class TopProductWidget extends StatefulWidget {

  final List<Map<String, dynamic>> products;
  final bool isLoading;

  const TopProductWidget({
    super.key,
    required this.products,
    this.isLoading = false
  });

  @override
  State<TopProductWidget> createState() => _TopProductWidgetState();
}

class _TopProductWidgetState extends State<TopProductWidget> {
  @override
  Widget build(BuildContext context) {

    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return  Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Theme.of(context).dividerColor
      ),
      child: DataTable(
              dividerThickness: 1, 
              headingRowColor: isDark ? MaterialStateProperty.all(const Color.fromARGB(255, 80, 152, 211)) : MaterialStateProperty.all(Colors.blue.shade100),
              headingRowHeight:isDesktop ? 57 : isTablet ? 52 : 47,
              dataRowHeight:  isDesktop ? 55 : isTablet ? 50 : 45, 
              columnSpacing: 50,
              columns: [
                DataColumn(label: Center(child:Text('Product ID', style: GoogleFonts.kameron(fontSize: Responsive.font(context, mobile: 15, tablet: 18, desktop: 21), fontWeight: FontWeight.w500,color: Colors.black)))),
                DataColumn(label: Center(child:Text('Product Name', style: GoogleFonts.kameron(fontSize: Responsive.font(context, mobile: 15, tablet: 18, desktop: 21), fontWeight: FontWeight.w500,color: Colors.black)))),
                DataColumn(label: Center(child:Text('Quantity Sold', style: GoogleFonts.kameron(fontSize: Responsive.font(context, mobile: 15, tablet: 18, desktop: 21), fontWeight: FontWeight.w500,color: Colors.black)))),
                DataColumn(label: Center(child:Text('Revenue', style: GoogleFonts.kameron(fontSize: Responsive.font(context, mobile: 15, tablet: 18, desktop: 21), fontWeight: FontWeight.w500,color: Colors.black)))),
               ],
              rows: widget.products.map((product) {
                return DataRow(cells: [
                  DataCell(Center(child:Text(product['product_id'].toString(),style: GoogleFonts.kameron(fontSize: Responsive.font(context, mobile: 14, tablet: 18, desktop: 21), fontWeight: FontWeight.w500,color: Colors.black)))),
                  DataCell(Center(child:Text(capitalizeEachWord(product['product_name']),style: GoogleFonts.kameron(fontSize: Responsive.font(context, mobile: 14, tablet: 18, desktop: 21), fontWeight: FontWeight.w500,color: Colors.black)))),
                  DataCell(Center(child:Text(product['total_sold'].toString(),style: GoogleFonts.kameron(fontSize: Responsive.font(context, mobile: 14, tablet: 18, desktop: 21), fontWeight: FontWeight.w500,color: Colors.black)))),
                  DataCell(Center(child:Text('₱${(product['revenue'] as double).toStringAsFixed(2)}',style: GoogleFonts.kameron(fontSize: Responsive.font(context, mobile: 14, tablet: 18, desktop: 21), fontWeight: FontWeight.w500,color: Colors.black)))),
                ]);
              }).toList(),
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

