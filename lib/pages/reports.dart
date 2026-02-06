import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:pos_app/widgets/footer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/utils/responsive.dart';

class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}


class _ReportsState extends State<Reports> {

int totalTransaction = 0;
double revenue = 0;
double profit = 0;
double margin = 0;


String selectedFilter = 'Today';

DateTimeRange? selectedRange;

Future<void> _pickDateRange(BuildContext context) async {
  final DateTimeRange? picked = await showDateRangePicker(
    context: context,
    firstDate: DateTime(2020),
    lastDate: DateTime.now(),
    initialDateRange: selectedRange,
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Color(0xFF3CE7FA), 
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null) {
    setState(() {
      selectedRange = picked;
    });


    // _fetchReports(picked.start, picked.end);
  }
}







  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        shadowColor: Colors.grey.withOpacity(0.5),
        automaticallyImplyLeading: false,
        elevation: 5,
        title:Padding(
          padding: const EdgeInsets.fromLTRB(20,0,0,0),
          child: Text(
            "Reports",
            style: GoogleFonts.kameron(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black
            ),
            ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
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
                      items: const [
                        DropdownMenuItem(
                          value: 'Today',
                          child: Text('Today'),
                        ),
                        DropdownMenuItem(
                          value: 'Weekly',
                          child: Text('Weekly'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedFilter = value!;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFF00E6FF),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
                ),
                  SizedBox(height: 18),
                  LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
                    double cardHeight = Responsive.spacing(
                      context,
                      mobile: 80,
                      tablet: 100,
                      desktop: 120,
                    );
          
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        mainAxisExtent: cardHeight,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        final cards = [
                          _buildStatCard(
                            context: context,
                            icon: Icons.shopping_cart_outlined,
                            iconColor: Colors.blue,
                            iconBgColor: Colors.blue.shade50,
                            title: "Total Sales",
                            value: '123',
                          ),
                          _buildStatCard(
                            context: context,
                            icon: Icons.attach_money,
                            iconColor: Colors.green,
                            iconBgColor: Colors.green.shade50,
                            title: "Revenue",
                            value: '₱12',
                          ),
                          _buildStatCard(
                            context: context,
                            icon: Icons.stacked_line_chart,
                            iconColor: Colors.purple,
                            iconBgColor: Colors.purple.shade50,
                            title: "Gross Profit",
                            value: '12',
                          ),
                          _buildStatCard(
                            context: context,
                            icon: Icons.percent_outlined,
                            iconColor: Color(0xFF7C6D00),
                            iconBgColor: Color(0xFFF5EEB6),
                            title: "Gross Margin",
                            value: '12',
                          ),
                          
                        ];
                        return cards[index];
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppFooter(
        currentIndex: 3,
        onTap: (index) {
          if(index == 0){
            Navigator.pushReplacementNamed(context, '/home');
          }else if(index == 1){
            Navigator.pushReplacementNamed(context, '/inventory');
          }else if(index == 2){
            Navigator.pushReplacementNamed(context, '/products');
          }else if(index == 3){
            Navigator.pushReplacementNamed(context, '/reports');
          }
        },
        onCenterTap: (){
           Navigator.pushReplacementNamed(context, '/pos');
        },
      ),
    );
  }
}



 Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String value,
  }) {
    double iconContainerSize = Responsive.spacing(
      context,
      mobile: 45,
      tablet: 48,
      desktop: 65,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: Row(
        children: [
          Container(
            height: iconContainerSize,
            width: iconContainerSize,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor,
                size: Responsive.font(
                  context,
                  mobile: 22,
                  tablet: 25,
                  desktop: 32,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.kameron(
                    fontSize: Responsive.font(
                      context,
                      mobile: 13,
                      tablet: 15,
                      desktop: 20,
                    ),
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.kameron(
                    fontSize: Responsive.font(
                      context,
                      mobile: 15,
                      tablet: 17,
                      desktop: 23,
                    ),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
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
