
import 'package:intl/intl.dart';
import 'package:pos_app/db/user.dart';
import 'package:flutter/material.dart';
import 'package:pos_app/db/reports.dart';
import 'package:pos_app/utils/boxShadow.dart';
import 'package:pos_app/widgets/RCOGSP.dart';
import 'package:pos_app/widgets/footer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/utils/responsive.dart';
import 'package:pos_app/widgets/sale_chart.dart';
import 'package:pos_app/widgets/topSellingProduct.dart';
import 'package:pos_app/services/exports/pdf/salesReport.dart';



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

String? _userRole;

DateTimeRange? selectedRange;

List<Map<String, dynamic>> salesTrend = [];
List<Map<String, dynamic>> rcogsp = [];
List<Map<String, dynamic>> topProducts = [];

final ScrollController _topProductsScrollController = ScrollController();

bool isExporting = false;


@override
void initState() {
  super.initState();
  loadReportsCard();
  loadSalesTrend();
  loadRCOGSP();
  loadTopSellingProducts();
  _getLoggedInUserRole();
}

@override
  void dispose() {
    _topProductsScrollController.dispose();
    super.dispose();
  }


DateTimeRange getEffectiveDateRange() {
  if (selectedFilter == 'Custom' && selectedRange != null) {
    return selectedRange!;
  }

  final now = DateTime.now();

  if (selectedFilter == 'Today') {
    return DateTimeRange(
      start: DateTime(now.year, now.month, now.day),
      end: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
  }

  if (selectedFilter == 'Weekly') {
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    final end = start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    return DateTimeRange(start: start, end: end);
  }


  return DateTimeRange(
    start: DateTime(now.year, now.month, now.day),
    end: DateTime(now.year, now.month, now.day),
  );
}

Future<void> _getLoggedInUserRole() async {

  final role = await UserDB().getLoggedInUserRole();

  if(!mounted) return;

  setState(() {
    _userRole = role;
  }); 

}



Future<void> _pickDateRange(BuildContext context) async {
  final DateTimeRange? picked = await showDateRangePicker(
    context: context,
    firstDate: DateTime(2020),
    lastDate: DateTime.now(),
    initialDateRange: selectedRange,
    builder: (context, child) {

       final isDark = Theme.of(context).brightness == Brightness.dark;

      return Theme(
    data: Theme.of(context).copyWith(
      colorScheme: isDark
          ? const ColorScheme.dark(
              primary: Color(0xFF3CE7FA),
              onPrimary: Colors.black,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            )
          : const ColorScheme.light(
              primary: Color(0xFF3CE7FA),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
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

    if (!mounted) return;

    setState(() {
      salesTrend = data;
      isSaleTrendLoading = false;
    });


  } catch (error) {
    debugPrint('Error fetching data, $error');
    if (!mounted) return;
    setState(() => isSaleTrendLoading = false);
  }
}

Future<void> loadRCOGSP() async {

  try {
    
    setState(() => isRCOGSPLoading = true);

    final data = await fetchRCOGSP(
      filter: selectedFilter,
      dateRange: selectedRange
    );

    if (!mounted) return;

    setState(() {
      rcogsp = data;
      isRCOGSPLoading = false;
    });




  } catch (error) {
    debugPrint('Error fetching data, $error');

    if (!mounted) return;

    setState(() => isRCOGSPLoading = false);
  }

}

Future<void> loadTopSellingProducts() async {

  try {
    
    setState(() => isTopProductsLoading = true);

    final products = await fetchTopProducts(
      filter: selectedFilter,
      dateRange: selectedRange
    );

    if (!mounted) return;

    setState(() {
      topProducts = products; 
      isTopProductsLoading = false;
    });

    setState(() => isTopProductsLoading = false);

  } catch (error) {
    debugPrint('Error fetching data,$error');
    if (!mounted) return;
    setState(() => isTopProductsLoading = false);
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


Future<void> _exportReport() async {
  try {

    setState(() => isExporting = true);

    final file = await exportReportPDF(
      reportCard: reportCard,
      salesTrend: salesTrend,
      rcogsp: rcogsp,
      topProducts: topProducts,
      dateRange: getEffectiveDateRange(),
      filter: selectedFilter,
    );

    if (!mounted) return;

    print(file.path);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report successfully exported'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    debugPrint('Export error: $e');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export failed: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }finally {
    if (mounted) {
      setState(() => isExporting = false);
    }
  }
}




  @override
  Widget build(BuildContext context) {

    final isTablet = Responsive.isTablet(context);
    final isDesktop = Responsive.isDesktop(context);
    final isLandscape = Responsive.isLandscape(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        shadowColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
        automaticallyImplyLeading: false,
        elevation: 5,
        toolbarHeight: isLandscape ? (isDesktop ? 50 : isTablet ? 40 : 35) : (isDesktop ? 70 : isTablet ? 60 : 50),
        title:Padding(
          padding: const EdgeInsets.fromLTRB(10,0,0,0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Reports",
                style: GoogleFonts.kameron(
                  fontSize: isLandscape ? (isDesktop ? 20 :isTablet ? 18 : 16) : (isDesktop ? 24 :isTablet ? 22 : 20),
                  fontWeight: FontWeight.bold,
                ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    
                    SizedBox(
                      height: isLandscape
                      ? Responsive.spacing(context, mobile: 30, tablet: 35, desktop: 40)
                      : Responsive.spacing(context, mobile: 40, tablet: 45, desktop: 50),
                      child: Material(
                        color: Color(0xFF3CE7FA), 
                        borderRadius: BorderRadius.circular(8),
                        elevation: 4,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                
                            Navigator.pushNamed(context, '/transaction');
                          },
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Center(
                              child: Text(
                                'Transaction Records',
                                style: GoogleFonts.kameron(
                                  fontSize: isLandscape ? (isDesktop ? 13 : isTablet ? 11 : 10) : (isDesktop ? 15 : isTablet ? 14 : 13),
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                     SizedBox(width: 10),

                    if(_userRole == 'admin') 
                    SizedBox(
                      height: isLandscape
                      ? Responsive.spacing(context, mobile: 30, tablet: 35, desktop: 40)
                      : Responsive.spacing(context,mobile: 40, tablet: 45, desktop: 50),
                      child: Material(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                        elevation: 4,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: _exportReport,
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Row(
                              children: [
                                Icon(Icons.download, size: 18, color: Colors.white),
                                SizedBox(width: 5),
                                Text(isExporting ?
                                  'Exporting' : 'Export',
                                  style: GoogleFonts.kameron(
                                    fontSize: isLandscape ? (isDesktop ? 13 : isTablet ? 11 : 10) : (isDesktop ? 15 : isTablet ? 14 : 13),
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
                )
              ],
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
                  fontSize: isLandscape 
                  ? Responsive.font(context, mobile: 16,tablet: 17, desktop: 19 )
                  : Responsive.font(context, mobile: 15,tablet: 21, desktop: 24 ),
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface
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
                        padding:  EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: isLandscape 
                            ? Responsive.font(context,mobile: 9.5, tablet: 10, desktop: 10) 
                            : Responsive.font(context,mobile: 12, tablet: 12, desktop: 14)),
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
                                  : '${DateFormat('MM/dd/yyyy').format(selectedRange!.start)}'
                                    ' - '
                                    '${DateFormat('MM/dd/yyyy').format(selectedRange!.end)}',
                              style: GoogleFonts.kameron(
                                fontSize: isLandscape 
                                ? Responsive.font(context, mobile: 13, tablet: 14, desktop: 16)
                                :  Responsive.font(context, mobile: 14, tablet: 17, desktop: 19),
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
                      dropdownColor: Colors.grey[100],
                      iconEnabledColor: Colors.black87,
                     value: selectedFilter,
                     items: ['Today', 'Weekly', 'Custom']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.kameron(
                      fontSize: isLandscape 
                        ? Responsive.font(context,mobile: 13, tablet: 14, desktop: 16)
                        : Responsive.font(context,mobile: 14, tablet: 17, desktop: 19),
                      color:Colors.black),)))
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
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12, 
                          vertical: isLandscape 
                            ? Responsive.font(context,mobile: 9.5, tablet: 10, desktop: 10) 
                            : Responsive.font(context,mobile: 12, tablet: 12, desktop: 14)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
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
                    double cardHeight = isLandscape 
                    ? Responsive.spacing(context, mobile: 60, tablet: 70, desktop: 90)
                    : Responsive.spacing(context, mobile: 80, tablet: 100, desktop: 120);
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

                SizedBox(height: 30,),

                isLandscape ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Sales Trend",style: GoogleFonts.kameron(
                              fontSize: isLandscape 
                                ? Responsive.font(context, mobile: 16,tablet: 17, desktop: 19 ) 
                                : Responsive.font(context, mobile: 16,tablet: 21, desktop: 24 ),
                              fontWeight: FontWeight.bold
                            ),),
                          ),
                      
                          SizedBox(height: 15,),
                          
                          Container(
                            height: Responsive.spacing(
                              context,
                              mobile: 300,
                              tablet: 350,
                              desktop: 400,),
                            margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: ShadowHelper.getShadow(context)
                              ),
                             child: isSaleTrendLoading
                              ? Center(child: CircularProgressIndicator.adaptive(
                                backgroundColor: Colors.blue
                              ),)
                              :salesTrend.isEmpty
                              ? Center(child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.area_chart_rounded, size: 40, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text("No data", style: GoogleFonts.kameron(fontSize: 14, fontWeight: FontWeight.w500, color:Colors.grey[700])),
                                ],
                              ))
                              : SaleChartWidget(salesTrend: salesTrend, isLoading: isSaleTrendLoading, selectedFilter: selectedFilter )
                          ),
                          
                        ],
                      ),
                    ),
                    SizedBox(width: 10,),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Revenue vs COGS vs Profit",style: GoogleFonts.kameron(
                              fontSize:  isLandscape 
                                ? Responsive.font(context, mobile: 16,tablet: 17, desktop: 19 ) 
                                : Responsive.font(context, mobile: 16,tablet: 21, desktop: 24 ),
                              fontWeight: FontWeight.bold
                            ),),
                          ),
                          SizedBox(height: 15,),
                          Container(
                            height: Responsive.spacing(
                              context,
                              mobile: 300,
                              tablet: 350,
                              desktop: 400,
                            ),
                            margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: ShadowHelper.getShadow(context)
                              ),
                             child: isRCOGSPLoading
                              ? Center(child: CircularProgressIndicator.adaptive(
                                backgroundColor: Colors.blue
                              ),)
                              :rcogsp.isEmpty
                              ? Center(child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.bar_chart_outlined, size: 40, color: Colors.grey[400]),
                                  Text("No data", style: GoogleFonts.kameron(fontSize: 14,fontWeight: FontWeight.w500, color:Colors.grey[700])),
                                ],
                              ))
                              : RcogspChartWidget(rcogsp: rcogsp, isLoading: isRCOGSPLoading )
                          ),
                          
                        ],
                      ),
                    ),
                  ],
                ):Column(
                  children: [
                     Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Sales Trend",style: GoogleFonts.kameron(
                              fontSize: isLandscape 
                                ? Responsive.font(context, mobile: 16,tablet: 17, desktop: 19 ) 
                                : Responsive.font(context, mobile: 16,tablet: 21, desktop: 24 ),
                              fontWeight: FontWeight.bold
                            ),),
                          ),
                      
                          SizedBox(height: 15,),
                          
                          Container(
                            height: Responsive.spacing(
                              context,
                              mobile: 300,
                              tablet: 350,
                              desktop: 400,),
                            margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: ShadowHelper.getShadow(context)
                              ),
                             child: isSaleTrendLoading
                              ? Center(child: CircularProgressIndicator.adaptive(
                                backgroundColor: Colors.blue
                              ),)
                              :salesTrend.isEmpty
                              ? Center(child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.area_chart_rounded, size: 40, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text("No data", style: GoogleFonts.kameron(fontSize: 14, fontWeight: FontWeight.w500, color:Colors.grey[700])),
                                ],
                              ))
                              : SaleChartWidget(salesTrend: salesTrend, isLoading: isSaleTrendLoading, selectedFilter: selectedFilter )
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
                              fontSize:  isLandscape 
                                ? Responsive.font(context, mobile: 16,tablet: 17, desktop: 19 ) 
                                : Responsive.font(context, mobile: 16,tablet: 21, desktop: 24 ),
                              fontWeight: FontWeight.bold
                            ),),
                          ),
                          SizedBox(height: 15,),
                          Container(
                            height: Responsive.spacing(
                              context,
                              mobile: 300,
                              tablet: 350,
                              desktop: 400,
                            ),
                            margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: ShadowHelper.getShadow(context)
                              ),
                             child: isRCOGSPLoading
                              ? Center(child: CircularProgressIndicator.adaptive(
                                backgroundColor: Colors.blue
                              ),)
                              :rcogsp.isEmpty
                              ? Center(child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.bar_chart_outlined, size: 40, color: Colors.grey[400]),
                                  Text("No data", style: GoogleFonts.kameron(fontSize: 14,fontWeight: FontWeight.w500, color:Colors.grey[700])),
                                ],
                              ))
                              : RcogspChartWidget(rcogsp: rcogsp, isLoading: isRCOGSPLoading )
                          ),
                          
                        ],
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
                        fontSize:  isLandscape 
                          ? Responsive.font(context, mobile: 15,tablet: 16, desktop: 18 ) 
                          : Responsive.font(context, mobile: 16,tablet: 21, desktop: 24 ),
                        fontWeight: FontWeight.bold
                      ),),
                    ),
                    SizedBox(height: 15,),
                     Container(
                          height: Responsive.spacing(
                          context,
                          mobile: 400,
                          tablet: 450,
                          desktop: 500,
                        ),
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                           boxShadow: ShadowHelper.getShadow(context)
                          
                        ),
                        child: isTopProductsLoading
                            ? Center(
                                child: CircularProgressIndicator.adaptive(
                                  backgroundColor: Colors.blue,
                                ),
                              )
                            : topProducts.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.trending_up_outlined, size: 40, color: Colors.grey[400]),
                                        const SizedBox(height: 8),
                                        Text(
                                          "No data",
                                          style: GoogleFonts.kameron(
                                              fontSize: 15, fontWeight: FontWeight.w500, color:Colors.grey[700]),
                                        ),
                                      ],
                                    ),
                                  )
                                : LayoutBuilder(
                                    builder: (context, constraints) {

                                      final bool isMobile = Responsive.isMobile(context);

                                      return 
                                        SingleChildScrollView(
                                          controller: _topProductsScrollController,
                                          scrollDirection: Axis.vertical,
                                          child: SingleChildScrollView(
                                                scrollDirection: Axis.horizontal,
                                                child: ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                   minWidth: constraints.maxWidth,
                                                   maxWidth: isMobile ? double.infinity : constraints.maxWidth,
                                                    ),
                                                    child: TopProductWidget(
                                                      products: topProducts,
                                                      isLoading: isTopProductsLoading,
                                                  ),
                                              ),
                                        )
                                        );
                                      
                                    },
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

    final isLandscape = Responsive.isLandscape(context);
    
    double iconContainerSize = isLandscape 
      ? Responsive.spacing(context,mobile: 27,tablet: 30,desktop: 45)
      : Responsive.spacing(context,mobile: 45,tablet: 48,desktop: 65);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ShadowHelper.getShadow(context)
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
                size: isLandscape
                 ? Responsive.font(context,mobile: 18,tablet: 20,desktop: 25)
                 : Responsive.font(context,mobile: 21,tablet: 25,desktop: 28)
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
                    fontSize: isLandscape 
                    ? Responsive.font(context,mobile: 13,tablet: 15,desktop: 17)
                    : Responsive.font(context,mobile: 13,tablet: 15,desktop: 20),
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.kameron(
                    fontSize: loading 
                      ? isLandscape ?  Responsive.font(context , mobile: 12.5, tablet: 13, desktop: 15,) : Responsive.font(context , mobile: 12, tablet: 14, desktop: 18,)
                      : isLandscape ? Responsive.font(context , mobile: 15, tablet: 16, desktop: 18,) : Responsive.font(context , mobile: 15, tablet: 17, desktop: 23,),
                    fontWeight: loading ? FontWeight.w500 :  FontWeight.bold,
                    color: loading ? Colors.grey[500] : Theme.of(context).colorScheme.onSurface,
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

