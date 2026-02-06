import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/pages/inventory.dart';
import 'package:pos_app/utils/responsive.dart';
import 'package:pos_app/widgets/footer.dart';
import 'package:pos_app/services/auth_service.dart';
import 'package:pos_app/db/database.dart';
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
    _fetchChartData();
    // _verifyToken(); // prints tokens to console when Home opens
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


// Future<void> _verifyToken() async {
//   final userId = await AuthService.getUserId();
//   final rawToken = await AuthService.getToken() ?? 'No token found';

//   String dbToken = 'No DB token';
//   if (userId != null) {
//     final db = await AppDatabase.database;
//     final result = await db.query('users', where: 'id = ?', whereArgs: [userId]);
//     if (result.isNotEmpty) {
//       dbToken = (result.first['token'] as String ?)?? 'No DB token found';
//     } else {
//       dbToken = 'User not found in DB';
//     }
//   }

//   print('Raw token in secure storage: $rawToken');
//   print('Hashed token in database: $dbToken');

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

  final products = await ProductDB.getAll();

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
                        style: GoogleFonts.kronaOne(
                          fontSize: Responsive.font(
                            context,
                            mobile: 18,
                            tablet: 20,
                            desktop: 22,
                          ),
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        // Temporary logout logic
                        await SessionService.clearSession(); // clears the session
                        print("User logged out");

                        // Optional: navigate to login page if you have one
                        Navigator.pushReplacementNamed(context, '/');
                      },
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          'https://picsum.photos/200',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dashboard",
                      style: GoogleFonts.kronaOne(
                        fontSize: Responsive.font(
                          context,
                          mobile: 15,
                          tablet: 20,
                          desktop: 26,
                        ),
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "Overview of your business performance",
                      style: GoogleFonts.kameron(
                        fontSize: Responsive.font(
                          context,
                          mobile: 12,
                          tablet: 14,
                          desktop: 16,
                        ),
                        fontWeight: FontWeight.normal,
                        color: Colors.grey,
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
                Text(
                  "Weekly Sales",
                  style: GoogleFonts.kronaOne(
                    fontSize: Responsive.font(
                      context,
                      mobile: 12.5,
                      tablet: 15,
                      desktop: 20,
                    ),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  height: Responsive.spacing(
                    context,
                    mobile: 250,
                    tablet: 300,
                    desktop: 350,
                  ),
                  margin: const EdgeInsets.only(top: 20),
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
                        child: FutureBuilder<List<SaleChart>>(
                              future: _fetchChartData(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return const Center(child: Text("Error loading chart"));
                                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return const Center(child: Text("No sales data for this week"));
                                }

                                final data = snapshot.data!; // non-null now
                                final spots = data.asMap().entries.map((entry) {
                                  final index = entry.key.toDouble();
                                  final value = entry.value.totalSales.toDouble();
                                  return FlSpot(index, value);
                                }).toList();

                                final titles = data.map((e) => e.date).toList();

                                return Padding(
                                  padding: const EdgeInsets.all(10),
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
                                          reservedSize: 16,
                                          interval: 1,
                                          getTitlesWidget: (value,meta) {
                                            final index = value.toInt();
                                            if (index >= 0 && index < titles.length) {
                                              return  Text(titles[index], style: const TextStyle(fontSize: 10,fontWeight: FontWeight.w500));
                                            }
                                            return const Text('');
                                          },
                                        ),
                                        ),
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                          showTitles: true,
                                          interval: 1,
                                           getTitlesWidget: (value, meta) {
                                            return Text(value.toInt().toString(), style: const TextStyle(fontSize: 12));
                                          },
                                        ),
                                      ),
                                    ),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: spots,
                                          isCurved: true,
                                          color: const Color.fromARGB(255, 14, 68, 161),
                                          barWidth: 2,
                                          dotData: FlDotData(show: true),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      
                    
                          
          
                const SizedBox(height: 25),
          // ── RESPONSIVE SECTION ──
          
                LayoutBuilder(
                  builder: (context, constraints) {
                    const double breakpoint = 800.0;
                    final bool isNarrow = constraints.maxWidth < breakpoint;

                    const double containerHeight = 350.0;

                    // Footer for Recent Sales
                    Widget salesFooter() {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            print("View Sales clicked");
                            // Add navigation or action here
                          },
                          child: Row(
                            children: [
                              Text(
                                "View Sales",
                                style: GoogleFonts.kameron(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              Icon( 
                                Icons.keyboard_arrow_right,
                                color: Colors.black,
                                size: 20,
                              )
                            ],
                          ),
                        ),
                      );
                    }

                    // Footer for Low Stock Alerts
                    Widget inventoryFooter() {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            print("Manage Inventory clicked");
                            // Add navigation or action here
                          },
                          child: Row(
                            children: [
                              Text(
                                "Manage Inventory",
                                style: GoogleFonts.kameron(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_right,
                                color: Colors.black,
                                size: 20,
                              )
                            ],
                          ),
                        ),
                      );
                    }

                    if (isNarrow) {
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
                                      ),
                                      SizedBox(width: 8),                               
                                      Text(
                                      "Recent Sales",
                                      style: GoogleFonts.kameron(
                                      fontSize: Responsive.font(
                                        context,
                                        mobile: 12.5,
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
                                  color: const Color(0xFF6FE5F2),
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
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (isLoading)
                                              Center(child: CircularProgressIndicator())
                                            else
                                              ...List.generate(recentSales.length, (index) => _buildSaleItem(index)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    salesFooter(),          // ← different footer
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

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
                                    
                                  ),
                              SizedBox(width: 8),
                              Text(
                                "Stock Alerts",
                                style: GoogleFonts.kameron(
                                  fontSize: Responsive.font(
                                    context,
                                    mobile: 12.5,
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
                                  color: const Color(0xFF6FE5F2),
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
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ...List.generate(lowStockProducts.length, (index) => _buildLowStockItem(index)),
                                          ],
                                        ),
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
                                      "Recent Sales",
                                      style: GoogleFonts.kameron(
                                      fontSize: Responsive.font(
                                        context,
                                        mobile: 12.5,
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
                                        child: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              ...List.generate(4, (index) => _buildSaleItem(index)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      salesFooter(),            // ← different footer
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
                                    mobile: 12.5,
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
                                        child: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              ...List.generate(2, (index) => _buildLowStockItem(index)),
                                            ],
                                          ),
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
    final formattedDate = DateFormat('MMMM d, y').format(date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Card(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
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
                        mobile: 13,
                        tablet: 15,
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
                        mobile: 12,
                        tablet: 14,
                        desktop: 16,
                      ),
                      color: const Color.fromARGB(255, 78, 78, 78),
                    ),
                  ),
                ],
              ),
              Text(
                '₱${sale.price * sale.quantity}',
                style: GoogleFonts.kameron(
                  fontSize: Responsive.font(
                    context,
                    mobile: 13,
                    tablet: 15,
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
          padding: const EdgeInsets.all(14),
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
                        mobile: 13,
                        tablet: 15,
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
                        mobile: 12,
                        tablet: 14,
                        desktop: 16,
                      ),
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: product.stock == 0 ? Colors.red : Color.fromARGB(255, 255, 165, 0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  product.stock == 0 ? 'Out of Stock' :  'Low Stock' ,
                  style: GoogleFonts.kameron(
                    fontSize: Responsive.font(
                      context,
                      mobile: 12,
                      tablet: 15,
                      desktop: 16,
                    ),
                    fontWeight: FontWeight.bold,
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
}

String capitalizeEachWord(String text) {
  return text
      .split(' ')
      .map((word) =>
          word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' : '')
      .join(' ');
}
