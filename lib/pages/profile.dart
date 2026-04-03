import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/pages/login.dart';
import 'package:pos_app/utils/responsive.dart';
import 'package:pos_app/pages/home.dart';
import 'package:pos_app/services/session_service.dart';
import 'package:pos_app/db/summary.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {


  Map<String, dynamic>? userData;
  Map<String, dynamic>? summaryData;
  int? userId;
  bool isLoading = true;

  List<Map<String, dynamic>> allCashiersSummary = [];


@override
void initState() {
  super.initState();
  _loadUser();
}

Future<void> _loadUser() async {
  final data = await Summary().getLoggedInUserInfo();

  if (data != null) {
    final summary = await Summary().getTodaysSummary(data['user_id']);

    List<Map<String, dynamic>> cashiers = [];
    if (data['role'] == 'admin') {

      cashiers = await Summary().allCashier();
    }

    setState(() {
      userData = data;
      summaryData = summary;
      allCashiersSummary = cashiers;
      userId = data['user_id'];
      isLoading = false;
    });
  } else {
    setState(() {
      userData = data;
      isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[100],
      appBar: null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 50),


            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                InkWell(
                  
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Home()),
                  ),
                  child: Icon(
                    Icons.arrow_back, size: isDesktop ? 37 : isTablet ? 32 : 27,
                  ),
                ),
                Text('Profile',style: GoogleFonts.kameron(
                  fontSize: isDesktop ? 23 : isTablet ? 21 : 18,
                  fontWeight: FontWeight.bold
                ),),
                InkWell(
                  onTap: () {},
                  child: Icon(
                    Icons.edit_note, size: isDesktop ? 37 : isTablet ? 32 : 27,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20,),

            Center(
              child:CircleAvatar(
                radius: isDesktop ? 60 : isTablet ? 50 : 40,
                backgroundColor: Colors.grey[300],
                backgroundImage: const AssetImage('assets/Legendaries.png'),
              ),
            ),

            const SizedBox(height: 14),

            // User Name
            Text(
              capitalizeEachWord(userData?['username'] ?? 'User',),
              style: GoogleFonts.kameron(
                fontSize: isDesktop ? 28 : isTablet ? 24 : 21,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            

            // Email & Role
            Text(
              userData?['email'] ?? '',
              style: GoogleFonts.kameron(
                fontSize: isDesktop ? 18 : isTablet ? 17 : 15,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500
              ),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                capitalizeEachWord(userData?['role'] ?? 'Cashier'),
                style: GoogleFonts.kameron(
                  fontSize: isDesktop ? 16 : isTablet ? 15 : 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ),

            const SizedBox(height: 30),

          Align(
            alignment: AlignmentGeometry.topLeft,
            child: Text('Personal Information',
            style: GoogleFonts.kameron(
              fontSize: isDesktop ? 20 : isTablet ? 18 : 16,
              fontWeight: FontWeight.bold
            ),),
          ),

          const SizedBox(height: 15),

            _buildInfoCard(),

          const SizedBox(height: 15),

          Align(
            alignment: AlignmentGeometry.topLeft,
            child: Text("Today's Summary",
            style: GoogleFonts.kameron(
              fontSize: isDesktop ? 20 : isTablet ? 18 : 16,
              fontWeight: FontWeight.bold
            ),),
          ),
          
          const SizedBox(height: 15),

          if(userData?['role'] == 'admin')...[

          _salesSummaryAdmin(),

          ]else...[

          _saleSummaryCashier(),
          
          ],

          const SizedBox(height: 200),

          _buildActionButton(icon: Icons.settings, text: 'Settings', color: const Color.fromARGB(255, 58, 58, 58), onTap: () {}),

          const SizedBox(height: 10),

          _buildActionButton(icon: Icons.logout, text: 'Logout', color: Colors.red, onTap: () async {
            await SessionService.clearSession();
            Navigator.pushReplacement( context, MaterialPageRoute(builder: (context) => const LoginPage()),);
             
          }),

          const SizedBox(height: 50),

          ],
        ),
      ),
    );
  }



  Widget _buildInfoCard() {
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:CrossAxisAlignment.start,
        children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Contact Number:', style: GoogleFonts.kameron(
                   fontSize:  isDesktop ? 18 : isTablet ? 15 : 15,
                   fontWeight: FontWeight.w500
                ),),
                Text(userData?['contact_number'] ?? 'N/A', style: GoogleFonts.kameron(
                   fontSize:  isDesktop ? 18 : isTablet ? 17 : 15,
                   fontWeight: FontWeight.w500
                ),)
              ],
            )
        ],
      ),
    );
  }

  
  Widget _saleSummaryCashier() {

    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Transaction: ', style: GoogleFonts.kameron(
                   fontSize:  isDesktop ? 18 : isTablet ? 17 : 15,
                   fontWeight: FontWeight.w500
                ),),
                Text('${summaryData?['transaction_count'] ?? 0}', style: GoogleFonts.kameron(
                   fontSize:  isDesktop ? 18 : isTablet ? 17 : 15,
                   fontWeight: FontWeight.w500
                ),)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Revenue: ', style: GoogleFonts.kameron(
                   fontSize:  isDesktop ? 18 : isTablet ? 17 : 15,
                   fontWeight: FontWeight.w500
                ),),
                Text('₱${(summaryData?['total_revenue'] ?? 0).toStringAsFixed(2)}', style: GoogleFonts.kameron(
                   fontSize:  isDesktop ? 18 : isTablet ? 17 : 15,
                   fontWeight: FontWeight.w500
                ),)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Items Sold: ', style: GoogleFonts.kameron(
                   fontSize:  isDesktop ? 18 : isTablet ? 17 : 15,
                   fontWeight: FontWeight.w500
                ),),
                Text('${summaryData?['items_sold'] ?? 0}', style: GoogleFonts.kameron(
                   fontSize:  isDesktop ? 18 : isTablet ? 17 : 15,
                   fontWeight: FontWeight.w500
                ),)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Average sales: ', style: GoogleFonts.kameron(
                   fontSize:  isDesktop ? 18 : isTablet ? 17 : 15,
                   fontWeight: FontWeight.w500
                ),),
                Text('₱${((summaryData?['average_sales'] ?? 0) as num).toStringAsFixed(2)}', style: GoogleFonts.kameron(
                   fontSize:  isDesktop ? 18 : isTablet ? 17 : 15,
                   fontWeight: FontWeight.w500
                ),)
              ],
            ),
        ],
      ),
    );
  }


  Widget _salesSummaryAdmin() {
  final isDesktop = Responsive.isDesktop(context);
  final isTablet = Responsive.isTablet(context);

  return Column(
    children: allCashiersSummary.map((cashier) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Cashier:', style: GoogleFonts.kameron(
                    fontSize: isDesktop ? 20 : isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),),
                  SizedBox(width: 15,),
                Text(
                  capitalizeEachWord(cashier['name'] ?? cashier['username']),
                  style: GoogleFonts.kameron(
                    fontSize: isDesktop ? 20 : isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Divider(thickness: 1,),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Transactions: ', style: GoogleFonts.kameron(fontSize: isDesktop ? 18 : isTablet ? 17 : 15, fontWeight: FontWeight.w500)),
                Text('${cashier['transaction_count'] ?? 0}', style: GoogleFonts.kameron(fontSize: isDesktop ? 18 : isTablet ? 17 : 15, fontWeight: FontWeight.w500)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Revenue: ', style: GoogleFonts.kameron(fontSize: isDesktop ? 18 : isTablet ? 17 : 15, fontWeight: FontWeight.w500)),
                Text('₱${(cashier['total_revenue'] ?? 0).toStringAsFixed(2)}', style: GoogleFonts.kameron(fontSize: isDesktop ? 18 : isTablet ? 17 : 15, fontWeight: FontWeight.w500)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Items Sold: ', style: GoogleFonts.kameron(fontSize: isDesktop ? 18 : isTablet ? 17 : 15, fontWeight: FontWeight.w500)),
                Text('${cashier['items_sold'] ?? 0}', style: GoogleFonts.kameron(fontSize: isDesktop ? 18 : isTablet ? 17 : 15, fontWeight: FontWeight.w500)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Average Sales: ', style: GoogleFonts.kameron(fontSize: isDesktop ? 18 : isTablet ? 17 : 15, fontWeight: FontWeight.w500)),
                Text('₱${((cashier['average_sales'] ?? 0) as num).toStringAsFixed(2)}', style: GoogleFonts.kameron(fontSize: isDesktop ? 18 : isTablet ? 17 : 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      );
    }).toList(),
  );
}



  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: isDesktop ? 26 : isTablet ? 24 : 22),
            const SizedBox(width: 12),
            Text(
              text,
              style: GoogleFonts.kameron(
                fontSize: isDesktop ? 19 : isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
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
