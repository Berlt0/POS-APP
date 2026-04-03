import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/db/debug.dart';
import 'package:pos_app/utils/responsive.dart';
import 'package:pos_app/widgets/footer.dart';
import 'package:pos_app/services/session_service.dart';
import 'package:pos_app/db/product.dart';
import 'package:pos_app/db/sales.dart';
import 'package:pos_app/models/products.dart';
import 'package:pos_app/models/sales.dart';
import 'package:intl/intl.dart';
import 'package:pos_app/db/inventory.dart';
import 'package:fl_chart/fl_chart.dart';



class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _MyWidgetState();
}



class _MyWidgetState extends State<Home>  {

  int? userId;
  String? username;
  String? role;

  int? totalProducts = 0;
  int? todaySalesCount = 0;
  int? lowStockProductsCount = 0;
  double? todaysRevenue = 0;

  List<Sale> recentSales = [];
  List<LowStockProducts> lowStockProducts = [];
  bool isLoading = false;
  
  late Future<List<SaleChart>> _chartFuture;
  

  
  @override
   void initState() {
    super.initState();
    _loadSession();
    _countTotalProducts();
    _countTodaySales();
    _countLowStockProducts();
    _todaysRevenue();
    _fetchRecentSales();
    _fetchLowStockProducts();
    _chartFuture = _fetchChartData();
    printTables();
  }

  void _refreshDashboard() {
  _countTotalProducts();
  _countTodaySales();
  _countLowStockProducts();
  _todaysRevenue();
  _fetchRecentSales();
  _fetchLowStockProducts();
  _fetchChartData();
}


Future<void> _loadSession() async {
  final session = await SessionService.getSession();

  if (session != null) {
    print('SESSION FOUND');
    print('userId: ${session['user_id']}');
    print('username: ${session['username']}');
    print('role: ${session['role']}');

    setState(() {
      userId = session['user_id'];
      username = session['username'];
      role = session['role'];
    });
  } else {
    print('NO SESSION FOUND');
  }
}


Future<void> _countTotalProducts() async {
  
  int count = await ProductDB.countProducts();
  setState(() {
    totalProducts = count;
  });
}

Future<void> _countTodaySales() async {
  
  int count = await Sales.countTodaySales();
  setState(() {
    todaySalesCount = count;
  });
}


Future <void> _countLowStockProducts() async {

  final products = await ProductDB.getAllActiveProducts();

  setState(() {
    lowStockProductsCount = products.where((product) => product.stock <= product.lowStockAlert! ).length;
   
  });

} 


Future <void> _todaysRevenue() async {

  final revenue = await Sales.todaysRevenue();

  setState(() {
   todaysRevenue = revenue;
  });


}

Future<void> _fetchRecentSales() async {
  
  setState(() => isLoading = true);
  
  try{

    final recentSalesData = await Sales.fetchRecentSales();

    final sales =  recentSalesData.map((data) => Sale.fromMap(data)).toList();

    setState(() {
      recentSales = sales;
      isLoading = false;
    });

  }catch(error){
    print("Error fetching recent sales: $error");
    setState(() => isLoading = false);
  }

  
}


Future <void> _fetchLowStockProducts() async {

 try{

  final products = await InventoryDB.getLowStockProducts();

  setState(() {
    lowStockProducts = products;
  });


 }catch(error){
  print("Error fetching low stock products: $error");

  
  }
}


Future<List<SaleChart>> _fetchChartData() async {

  try{

  final data = await Sales.fetchWeeklySales();
  return data.map((e) => SaleChart.fromMap(e)).toList();

  }catch(error){
    print('Error fetching weekly sales: $error');
    return [];
  }


}




int _currentIndex = 0;



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: AppFooter(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() => _currentIndex = index);

        switch(index){
          case 0: 
            Navigator.pushNamed(context, '/home');
            break;
          case 1:
            Navigator.pushNamed(context, '/inventory');
            break;
          case 2:
            Navigator.pushNamed(context, '/products');
            break;
          case 3:
            Navigator.pushNamed(context, '/reports');
            break;
          
        }
      },
      onCenterTap: () async {
         final shouldRefresh = await Navigator.pushNamed(context, '/pos');

          if (shouldRefresh == true) {
            _refreshDashboard();
          }

      },
    ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          Color(0xFF3CE7FA),
                          Color(0xFF248994),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        "Leo and Mae",
                        style: GoogleFonts.kameron(
                          fontSize: Responsive.font(
                            context,
                            mobile: 20,
                            tablet: 25,
                            desktop: 30,
                          ),
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {

                        

                        Navigator.pushReplacementNamed(context, '/profile');
                      },
                      child: Container(
                        padding: EdgeInsets.all(3), // thickness of gradient border
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: Responsive.font(
                            context,
                            mobile: 18,
                            tablet: 21,
                            desktop: 23,
                          ),
                          backgroundColor: Colors.white,
                          backgroundImage: const AssetImage('assets/Legendaries.png'), // inner color
                          
                        ),
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dashboard",
                      style: GoogleFonts.kameron(
                        fontSize: Responsive.font(
                          context,
                          mobile: 20,
                          tablet: 30,
                          desktop: 35,
                        ),
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "Overview of your business performance",
                      style: GoogleFonts.kameron(
                        fontSize: Responsive.font(
                          context,
                          mobile: 13,
                          tablet: 15,
                          desktop: 17,
                        ),
                        fontWeight: FontWeight.w500,
                        color: const Color.fromARGB(255, 58, 57, 57),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
          
                // Stats Cards
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
                    double cardHeight = Responsive.spacing(
                      context,
                      mobile: 75,
                      tablet: 110,
                      desktop: 120,
                    );
          
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        mainAxisExtent: cardHeight,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        final cards = [
                          _buildStatCard(
                            icon: Icons.shopping_bag_outlined,
                            iconColor: Colors.blue,
                            iconBgColor: Colors.blue.shade50,
                            title: "Total Products",
                            value: totalProducts.toString(),
                          ),
                          _buildStatCard(
                            icon: Icons.attach_money,
                            iconColor: Colors.green,
                            iconBgColor: Colors.green.shade50,
                            title: "Today's Revenue",
                            value: '₱${todaysRevenue?.toStringAsFixed(2) ?? '0'}',
                          ),
                          _buildStatCard(
                            icon: Icons.shopping_cart_outlined,
                            iconColor: Colors.purple,
                            iconBgColor: Colors.purple.shade50,
                            title: "Today's Sales",
                            value: todaySalesCount.toString(),
                          ),
                          _buildStatCard(
                            icon: Icons.warning_amber_rounded,
                            iconColor: Colors.red,
                            iconBgColor: Colors.red.shade50,
                            title: "Low Stocks Alert",
                            value: lowStockProductsCount.toString(),
                          ),
                        ];
                        return cards[index];
                      },
                    );
                  },
                ),
          
                const SizedBox(height: 25),
                Row(
                  children: [
                     Icon(
                      Icons.stacked_line_chart_rounded, 
                      color: Colors.blue, 
                      size: Responsive.font(context, mobile: 25, tablet: 28, desktop: 31),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Weekly Sales",
                      style: GoogleFonts.kameron(
                        fontSize: Responsive.font(
                          context,
                          mobile: 14.5,
                          tablet: 18,
                          desktop: 20,
                        ),
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12,),

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
                           boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: FutureBuilder<List<SaleChart>>(
                              future: _chartFuture,
                              builder: (context, snapshot) {

                                final isDesktop = Responsive.isDesktop(context);
                                final isTablet = Responsive.isTablet(context);

                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return const Center(child: Text("Error loading chart"));
                                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                         Icon(
                                          Icons.show_chart_outlined, // icon representing charts/sales
                                          size: 35,
                                          color: Colors.grey.withOpacity(0.6),
                                        ),
                                        const SizedBox(height: 12),
                                        Text("No sales data for this week",
                                        style: GoogleFonts.kameron(
                                          fontSize: isDesktop ? 18 : isTablet ? 16 :14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                        ),
                                      ],
                                    ));
                                }

                                final data = snapshot.data!; // non-null now
                                final spots = data.asMap().entries.map((entry) {
                                  final index = entry.key.toDouble();
                                  final value = entry.value.totalSales.toDouble();
                                  return FlSpot(index, value);
                                }).toList();

                                final titles = data.map((e) {
                                  final date = DateTime.parse(e.date);
                                  return DateFormat('MM/dd/yy').format(date); 
                                }).toList();

                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 15),
                                  child: LineChart(
                                    duration: Duration(milliseconds: 800),
                                    curve: Curves.bounceIn,
                                    LineChartData(
                                      minY: 0,
                                      gridData: FlGridData(show: true),
                                      borderData: FlBorderData(
                                        show: true,
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      titlesData: FlTitlesData(
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 14,
                                          interval: 1,
                                          getTitlesWidget: (value,meta) {
                                            final index = value.toInt();
                                            if (index >= 0 && index < titles.length) {
                                              return  Text(titles[index], style: TextStyle(fontSize: isDesktop ? 13 : isTablet ? 12 :  11,fontWeight: FontWeight.w500));
                                            }
                                            return const Text('');
                                          },
                                        ),
                                        ),
                                        
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                          reservedSize: 20,
                                          showTitles: true,
                                          interval: 5,
                                           getTitlesWidget: (value, meta) {
                                            return Text(
                                                '${value.toInt()}',
                                                style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w500)
                                              );
                                          },
                                        ),
                                      ),
                                       rightTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 20,
                                        interval: 5,
                                        getTitlesWidget: (value, meta) {
                                            return Text(
                                                '${value.toInt()}',
                                                style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w500)
                                              );
                                          },
                                        

                                    ),
                                  ),
                                  topTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                        showTitles: false,

                                    ),
                                  ),
                                      
                                    ),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: spots,
                                          isCurved: true,
                                          color: const Color.fromARGB(255, 14, 68, 161),
                                          barWidth: 3,
                                          dotData: FlDotData(show: true),
                                           belowBarData: BarAreaData(
                                            show: true,
                                            color: const Color.fromARGB(100, 14, 68, 161), 
                                            gradient: LinearGradient(
                                              colors: [
                                                Color.fromARGB(150, 14, 68, 161),
                                                Color.fromARGB(0, 14, 68, 161),   
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        
                      
                    
                          
          
                const SizedBox(height: 35),
          // ── RESPONSIVE SECTION ──
          
                LayoutBuilder(
                  builder: (context, constraints) {
                    const double breakpoint = 800.0;
                    final bool isNarrow = constraints.maxWidth < breakpoint;

                    const double containerHeight = 450;
                    
                    final isDesktop = Responsive.isDesktop(context);
                    final isTablet = Responsive.isTablet(context);

                    // Footer for Recent Sales
                    Widget salesFooter() {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: InkWell(
                          onTap: () {
                            print("View Sales clicked");
                            // Add navigation or action here
                          },
                          borderRadius: BorderRadius.circular(8), 
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                            child:Row(
                              mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "View Sales",
                                style: GoogleFonts.kameron(
                                  fontSize: isDesktop ? 19 : isTablet ? 17 : 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              Icon( 
                                Icons.keyboard_arrow_right,
                                color: Colors.black,
                                size: isDesktop ? 24 : isTablet ? 22 : 20,
                              )
                            ],
                          ),
                          ),
                        ),
                      );
                    }

                    // Footer for Low Stock Alerts
                    Widget inventoryFooter() {

                      final isDesktop = Responsive.isDesktop(context);
                      final isTablet = Responsive.isTablet(context);
                      


                      return Align(
                        alignment: Alignment.centerLeft,
                        child: InkWell(
                          onTap: () {
                            print("Manage inventorty clicked");
                            // Add navigation or action here
                          },
                          borderRadius: BorderRadius.circular(8), 
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            child:Row(
                              mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Manage Inventory",
                                style: GoogleFonts.kameron(
                                  fontSize: isDesktop ? 19 : isTablet ? 17 : 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              Icon( 
                                Icons.keyboard_arrow_right,
                                color: Colors.black,
                                size: isDesktop ? 24 : isTablet ? 22 : 20,
                              )
                            ],
                          ),
                          ),
                        ),
                      );
                    }

                    if (isNarrow) {

                      final isDesktop = Responsive.isDesktop(context);
                      final isTablet = Responsive.isTablet(context);
                      

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Recent Sales
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        color: Color(0xFF074C04),
                                         size: isDesktop ? 31 : isTablet ? 28 : 25,
                                      ),
                                      SizedBox(width: 6),                               
                                      Text(
                                      "Recent Sold Products",
                                      style: GoogleFonts.kameron(
                                      fontSize: Responsive.font(
                                        context,
                                        mobile: 14.5,
                                        tablet: 18,
                                        desktop: 20,
                                      ),
                                      
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 25),
                              Container(
                                height: containerHeight,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Color(0xFF6FE5F2),
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
                                child: Column(
                                  children: [
                                    Expanded(
                                      
                                      child: isLoading
                                          ? const Center(child: CircularProgressIndicator())
                                          : recentSales.isEmpty
                                              ? Center(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.receipt_long, size: 35, color: Color.fromARGB(214, 0, 0, 0)),
                                                      SizedBox(height: 10),
                                                      Text(
                                                        "No sales today",
                                                        style: GoogleFonts.kameron(
                                                          fontSize: isDesktop ? 18 : isTablet ? 16 : 14,
                                                          fontWeight: FontWeight.w500,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : ListView(
                                                  children: [
                                                    ...List.generate(
                                                      recentSales.length,
                                                      (index) => _buildSaleItem(index),
                                                    ),
                                                  ],
                                                ),
                                    ),
                                    const SizedBox(height: 8),
                                    salesFooter(),          // ← different footer
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 35),

                          // Low Stock Alerts
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Color(0xFFFF0000),
                                    size: isDesktop ? 31 : isTablet ? 28 : 25,
                                    
                                  ),
                              SizedBox(width: 6),
                              Text(
                                "Stock Alerts",
                                style: GoogleFonts.kameron(
                                  fontSize: Responsive.font(
                                    context,
                                    mobile: 14.5,
                                    tablet: 18,
                                    desktop: 20,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                               ],
                              ),
                              SizedBox(height: 25),
                              Container(
                                height: containerHeight,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Color(0xFF6FE5F2),
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
                                child: Column(
                                  children: [
                                    Expanded(
                                        child: lowStockProducts.isEmpty
                                            ? Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.inventory_2_outlined, size: 35, color: const Color.fromARGB(214, 0, 0, 0)),
                                                    SizedBox(height: 10),
                                                    Text(
                                                      "No low stock items",
                                                      style: GoogleFonts.kameron(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : ListView(
                                                children: [
                                                  ...List.generate(
                                                    lowStockProducts.length,
                                                    (index) => _buildLowStockItem(index),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    const SizedBox(height: 8),
                                    inventoryFooter(),      // ← different footer
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    } else {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        color: Color(0xFF074C04),
                                      ),
                                      SizedBox(width: 8),                               
                                      Text(
                                      "Recent Sale",
                                      style: GoogleFonts.kameron(
                                      fontSize: Responsive.font(
                                        context,
                                        mobile: 14.5,
                                        tablet: 20,
                                        desktop: 20,
                                      ),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),

                                Container(
                                  height: containerHeight,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF6FE5F2),
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
                                  child: Column(
                                    children: [
                                      Expanded(
                                      child: isLoading
                                          ? const Center(child: CircularProgressIndicator())
                                          : recentSales.isEmpty
                                              ? Center(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.receipt_long, size: 35, color: Color.fromARGB(214, 0, 0, 0)),
                                                      SizedBox(height: 10),
                                                      Text(
                                                        "No sales today",
                                                        style: GoogleFonts.kameron(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w500,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : ListView(
                                                  children: [
                                                    ...List.generate(
                                                      recentSales.length,
                                                      (index) => _buildSaleItem(index),
                                                    ),
                                                  ],
                                                ),
                                    ),
                          const SizedBox(height: 8),
                          salesFooter(),
                           ],
                            ),
                          ),
                        ],
                      ),
                    ),
                                           const SizedBox(width: 25),
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                 Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Color(0xFFFF0000),
                                    
                                  ),
                              SizedBox(width: 8),
                              Text(
                                "Low Stock Alerts",
                                style: GoogleFonts.kameron(
                                  fontSize: Responsive.font(
                                    context,
                                    mobile: 14.5,
                                    tablet: 20,
                                    desktop: 20,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                               ],
                              ),
                              SizedBox(height: 20),
                                Container(
                                  height: containerHeight,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF6FE5F2),
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
                                  child: Column(
                                    children: [
                                     Expanded(
                                        child: lowStockProducts.isEmpty
                                            ? Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.inventory_2_outlined, size: 35, color: const Color.fromARGB(214, 0, 0, 0)),
                                                    SizedBox(height: 10),
                                                    Text(
                                                      "No low stock items",
                                                      style: GoogleFonts.kameron(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : ListView(
                                                children: [
                                                  ...List.generate(
                                                    lowStockProducts.length,
                                                    (index) => _buildLowStockItem(index),
                                                  ),
                                                ],
                                              ),
                                      ),
                                      const SizedBox(height: 8),
                                      inventoryFooter(),          // ← different footer
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaleItem(int index) {
    
    if(index >= recentSales.length) return SizedBox();

    final sale = recentSales[index];

    final date = DateTime.parse(sale.createdAt);
    final formattedDate = DateFormat('MMMM d, yy').format(date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Card(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${capitalizeEachWord(sale.product_name)} (${sale.quantity})',
                    style: GoogleFonts.kameron(
                      fontSize: Responsive.font(
                        context,
                        mobile: 14,
                        tablet: 16,
                        desktop: 18,
                      ),
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formattedDate,
                    style: GoogleFonts.kameron(
                      fontSize: Responsive.font(
                        context,
                        mobile: 13,
                        tablet: 14,
                        desktop: 15,
                      ),
                      color: Color.fromARGB(255, 43, 42, 42),
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              ),
              Text(
                '₱${(sale.price * sale.quantity).toStringAsFixed(2)}',
                style: GoogleFonts.kameron(
                  fontSize: Responsive.font(
                    context,
                    mobile: 14,
                    tablet: 16,
                    desktop: 18,
                  ),
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLowStockItem(int index) {
    
    if(index >= lowStockProducts.length) return SizedBox();

    final product = lowStockProducts[index];


    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Card(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    capitalizeEachWord(product.name),
                    style: GoogleFonts.kameron(
                      fontSize: Responsive.font(
                        context,
                        mobile: 14,
                        tablet: 16,
                        desktop: 18,
                      ),
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "Stocks: ${product.stock} ${product.stock_unit}",
                    style: GoogleFonts.kameron(
                      fontSize: Responsive.font(
                        context,
                        mobile: 13,
                        tablet: 14,
                        desktop: 15,
                      ),
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 43, 42, 42),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: product.stock == 0 ? Colors.red : Color.fromARGB(237, 241, 157, 0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  product.stock == 0 ? 'Out of Stock' :  'Low Stock' ,
                  style: GoogleFonts.kameron(
                    fontSize: Responsive.font(
                      context,
                      mobile: 13.5,
                      tablet: 15,
                      desktop: 16,
                    ),
                    fontWeight: FontWeight.w600,
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String value,
  }) {
    double iconContainerSize = Responsive.spacing(
      context,
      mobile: 43,
      tablet: 46,
      desktop: 49,
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
                  desktop: 28,
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
                      desktop: 18,
                    ),
                    fontWeight: FontWeight.w300,
                    color: const Color.fromARGB(255, 46, 46, 46),
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
}

String capitalizeEachWord(String text) {
  return text
      .split(' ')
      .map((word) =>
          word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' : '')
      .join(' ');
}
