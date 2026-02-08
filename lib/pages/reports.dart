
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:pos_app/db/reports.dart';
import 'package:pos_app/widgets/RCOGSP.dart';
import 'package:pos_app/widgets/footer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/utils/responsive.dart';
import 'package:pos_app/widgets/sale_chart.dart';
import 'package:pos_app/widgets/topSellingProduct.dart';


class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}


class _ReportsState extends State<Reports> {

String selectedFilter = 'Today';

Map<String, dynamic>? reportCard;
bool isLoading = false;
bool isSaleTrendLoading = false;
bool isRCOGSPLoading = false;
bool isTopProductsLoading = false;

DateTimeRange? selectedRange;

List<Map<String, dynamic>> salesTrend = [];
List<Map<String, dynamic>> rcogsp = [];
List<Map<String, dynamic>> topProducts = [];

final ScrollController _topProductsScrollController = ScrollController();


@override
void initState() {
  super.initState();
  loadReportsCard();
  loadSalesTrend();
  loadRCOGSP();
  loadTopSellingProducts();
}

@override
  void dispose() {
    _topProductsScrollController.dispose();
    super.dispose();
  }



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
      selectedFilter = 'Custom';
    });

    await loadReportsCard();
    await loadSalesTrend();
    await loadRCOGSP();
    await loadTopSellingProducts();

  }
}


Future<void> loadReportsCard() async {

  try {

    setState(() => isLoading = true);

    reportCard = await fetchReportCard(
      filter: selectedFilter,
      dateRange: selectedRange
    );

    setState(() => isLoading = false);

    
  } catch (error) {
    debugPrint("Error fetching report cards, $error");
    return;
  }

} 


Future<void> loadSalesTrend() async {
  try {
    
    setState(() => isSaleTrendLoading = true);

    final data = await fetchSalesTrend(
      filter: selectedFilter,
      dateRange: selectedRange
    );

    setState(() {
      salesTrend = data;
    });

    setState(() => isSaleTrendLoading = false);

  } catch (error) {
    debugPrint('Error fetching data, $error');
  }
}

Future<void> loadRCOGSP() async {

  try {
    
    setState(() => isSaleTrendLoading = true);

    final data = await fetchRCOGSP(
      filter: selectedFilter,
      dateRange: selectedRange
    );

    setState(() {
      rcogsp = data;
    });



    setState(() => isSaleTrendLoading = false);

  } catch (error) {
    debugPrint('Error fetching data, $error');
  }

}

Future<void> loadTopSellingProducts() async {

  try {
    
    setState(() => isTopProductsLoading = true);

    final products = await fetchTopProducts(
      filter: selectedFilter,
      dateRange: selectedRange
    );

    setState(() {
      topProducts = products; 
    });

    setState(() => isTopProductsLoading = false);

  } catch (error) {
    debugPrint('Error fetching data,$error');
  }

}




String _valueOrLoading(String key, {bool peso = false}) {
  if (isLoading || reportCard == null) {
    return 'Loading...';
  }

  final value = reportCard![key];

  if (value is num) {
    return peso
        ? '₱${value.toStringAsFixed(2)}'
        : value.toString();
  }

  return value.toString();
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
                     items: ['Today', 'Weekly', 'Custom']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.kameron(fontSize: 16, color:Colors.black),)))
                    .toList(),
                      onChanged: (value) async {
                        setState(() {
                          selectedFilter = value!;
                        });

                          if (value == 'Custom' && selectedRange == null) return;

                          await loadReportsCard();
                          await loadSalesTrend();
                          await loadRCOGSP();
                          await loadTopSellingProducts();
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
                            value: _valueOrLoading('totalSales'),
                          ),
                          _buildStatCard(
                            context: context,
                            icon: Icons.attach_money,
                            iconColor: Colors.green,
                            iconBgColor: Colors.green.shade50,
                            title: "Revenue",
                            value: _valueOrLoading('revenue',peso: true),
                          ),
                          _buildStatCard(
                            context: context,
                            icon: Icons.stacked_line_chart,
                            iconColor: Colors.purple,
                            iconBgColor: Colors.purple.shade50,
                            title: "Gross Profit",
                            value: _valueOrLoading('profit', peso: true),
                          ),
                          _buildStatCard(
                            context: context,
                            icon: Icons.percent_outlined,
                            iconColor: Color(0xFF7C6D00),
                            iconBgColor: Color(0xFFF5EEB6),
                            title: "Gross Margin",
                            value: _valueOrLoading('margin',peso: true),
                          ),
                          
                        ];
                        return cards[index];
                      },
                    );
                  },
                ),

                SizedBox(height: 20,),

                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Sales Trend",style: GoogleFonts.kameron(
                        fontSize: Responsive.font(context, mobile: 17,tablet: 21, desktop: 24 ),
                        fontWeight: FontWeight.bold
                      ),),
                    ),
                    Container(
                      height: Responsive.spacing(
                        context,
                        mobile: 250,
                        tablet: 300,
                        desktop: 350,
                      ),
                      margin: const EdgeInsets.only(top: 13),
                      decoration: BoxDecoration(
                      color: Color(0xFF3CE7FA),
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
                    child: Container(
                      margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                       child: isSaleTrendLoading
                        ? Center(child: CircularProgressIndicator.adaptive(
                          backgroundColor: Colors.blue
                        ),)
                        :salesTrend.isEmpty
                        ? Center(child: Text("No data", style: GoogleFonts.kameron()))
                        : SaleChartWidget(salesTrend: salesTrend, isLoading: isSaleTrendLoading )
                    ),
                    ),
                  ],
                ),
                SizedBox(height: 25,),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Revenue vs COGS vs Profit",style: GoogleFonts.kameron(
                        fontSize: Responsive.font(context, mobile: 17,tablet: 21, desktop: 24 ),
                        fontWeight: FontWeight.bold
                      ),),
                    ),
                    Container(
                      height: Responsive.spacing(
                        context,
                        mobile: 250,
                        tablet: 300,
                        desktop: 350,
                      ),
                      margin: const EdgeInsets.only(top: 13),
                      decoration: BoxDecoration(
                      color: Color(0xFF3CE7FA),
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
                    child: Container(
                      margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                       child: isRCOGSPLoading
                        ? Center(child: CircularProgressIndicator.adaptive(
                          backgroundColor: Colors.blue
                        ),)
                        :rcogsp.isEmpty
                        ? Center(child: Text("No data", style: GoogleFonts.kameron()))
                        : RcogspChartWidget(rcogsp: rcogsp, isLoading: isRCOGSPLoading )
                    ),
                    ),
                  ],
                ),
                SizedBox(height: 25,),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Top Selling Products",style: GoogleFonts.kameron(
                        fontSize: Responsive.font(context, mobile: 17,tablet: 21, desktop: 24 ),
                        fontWeight: FontWeight.bold
                      ),),
                    ),
                    Container(
                      height: Responsive.spacing(
                        context,
                        mobile: 400,
                        tablet: 450,
                        desktop: 500,
                      ),
                      margin: const EdgeInsets.only(top: 13),
                      decoration: BoxDecoration(
                        color: Color(0xFF3CE7FA),
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
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: isTopProductsLoading
                            ? Center(
                                child: CircularProgressIndicator.adaptive(
                                  backgroundColor: Colors.blue,
                                ),
                              )
                            : topProducts.isEmpty
                                ? Center(
                                    child: Text(
                                      "No data",
                                      style: GoogleFonts.kameron(
                                          fontSize: 15, fontWeight: FontWeight.w500),
                                    ),
                                  )
                                : LayoutBuilder(
                                    builder: (context, constraints) {
                                      return Scrollbar(
                                        thumbVisibility: true,
                                        controller: _topProductsScrollController,
                                        child: SingleChildScrollView(
                                          controller: _topProductsScrollController,
                                          scrollDirection: Axis.vertical,
                                          child: ConstrainedBox(
                                            constraints:
                                                BoxConstraints(minWidth: constraints.maxWidth),
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: TopProductWidget(
                                                products: topProducts,
                                                isLoading: isTopProductsLoading,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    ),

                  ],
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
    bool loading = value == 'Loading...';
    
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
                    fontWeight: FontWeight.w500,
                    color: const Color.fromARGB(255, 44, 44, 44),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.kameron(
                    fontSize: loading 
                      ? Responsive.font(context , mobile: 12, tablet: 14, desktop: 18,)
                      : Responsive.font(context , mobile: 15, tablet: 17, desktop: 23,),
                    fontWeight: loading ? FontWeight.w500 :  FontWeight.bold,
                    color: loading ? Colors.grey[500] : Colors.black,
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

