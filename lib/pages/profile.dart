import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/pages/login.dart';
import 'package:pos_app/pages/settings/settings.dart';
import 'package:pos_app/utils/responsive.dart';
import 'package:pos_app/pages/home.dart';
import 'package:pos_app/services/session_service.dart';
import 'package:pos_app/db/summary.dart';
import 'package:pos_app/models/addCashier.dart';
import 'package:pos_app/utils/password_hashed.dart';
import 'package:pos_app/utils/boxShadow.dart';
import 'package:uuid/uuid.dart';

import 'package:provider/provider.dart';
import 'package:pos_app/providers/theme.provider.dart';

var uuid = Uuid();
String generateId() => Uuid().v4();

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

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String? nameError;
  String? usernameError;
  String? emailError;
  String? contactError;
  String? addressError;
  String? passwordError;


@override
void initState() {
  super.initState();
  _loadUser();
}

@override
void dispose() {
  usernameController.dispose();
  passwordController.dispose();
  nameController.dispose();
  emailController.dispose();
  contactController.dispose();
  addressController.dispose();
  super.dispose();
}

Future<void> _loadUser() async {
  final data = await Summary().getLoggedInUserInfo();

  if (data != null) {
    final summary = await Summary().getTodaysSummary(data['user_id']);

    List<Map<String, dynamic>> cashiers = [];
    if (data['role'] == 'admin') {

      cashiers = await Summary().allCashier();
    }

    if (!mounted) return;

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

Future<bool> _handleCashierInsertion() async {

  try {

          final hashedPassword = PasswordHelper.hashPassword(passwordController.text.trim());

          final cashier = Addcashier(
            global_id: generateId(),
            name: nameController.text.trim(),
            username: usernameController.text.trim(),
            email: emailController.text.trim(),
            contactNo: contactController.text.trim(),
            address: addressController.text.trim(),
            password: hashedPassword,
          );

          await Summary().insertCashier(cashier); 

          if (!mounted) return false;
  
            await _loadUser();
     
          return true;

        } catch (e) {

          if (!mounted) return false;

          String message = "Failed to add cashier. Please try again.";

          if (e.toString().contains("UNIQUE constraint failed")) {
            message = "This username or email already exists.";
          } else if (e.toString().contains("DatabaseException")) {
            message = "Database error occurred. Please check your input.";
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
            ),
          );

          
          return false;
        }
}

  @override
  Widget build(BuildContext context) {

    final themeProvider = Provider.of<ThemeProvider>(context);

    final isTablet = Responsive.isTablet(context);
    final isDesktop = Responsive.isDesktop(context);
    final isLandscape = Responsive.isLandscape(context);

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                    Icons.arrow_back, size: isLandscape ? (isDesktop ? 30 : isTablet ? 27 : 25) : (isDesktop ? 37 : isTablet ? 32 : 27),
                  ),
                ),
                Text('Profile',style: GoogleFonts.kameron(
                  fontSize: isLandscape ? (isDesktop ? 20 : isTablet ? 18 : 16) : (isDesktop ? 23 : isTablet ? 21 : 18),
                  fontWeight: FontWeight.bold
                ),),
                InkWell(
                  onTap: () {
                    themeProvider.toggleTheme();
                  },
                  child: Icon(
                    themeProvider.isDarkMode
                        ? Icons.dark_mode_rounded   
                        : Icons.wb_sunny_rounded,   
                    size: isLandscape ? (isDesktop ? 30 : isTablet ? 27 : 25) : (isDesktop ? 37 : isTablet ? 32 : 27),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20,),

            Center(
              child:CircleAvatar(
                radius: isLandscape ? (isDesktop ? 50 : isTablet ? 40 : 30) : (isDesktop ? 60 : isTablet ? 50 : 40),
                backgroundColor: Colors.grey[300],
                backgroundImage: const AssetImage('assets/Legendaries.png'),
              ),
            ),

            const SizedBox(height: 14),

            // User Name
            Text(
              capitalizeEachWord(userData?['username'] ?? 'User',),
              style: GoogleFonts.kameron(
                fontSize: isLandscape ? (isDesktop ? 22 : isTablet ? 20 : 17) : (isDesktop ? 28 : isTablet ? 24 : 21),
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),

            

        
            Text(
              userData?['email'] ?? '',
              style: GoogleFonts.kameron(
                fontSize: isLandscape ? (isDesktop ? 16 : isTablet ? 14 : 13.5) : (isDesktop ? 18 : isTablet ? 17 : 15),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  fontSize: (isDesktop ? 16 : isTablet ? 15 : 14),
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ),

            const SizedBox(height: 30),

          Align(
            alignment: Alignment.topLeft,
            child: Text('Personal Information',
            style: GoogleFonts.kameron(
              fontSize: isLandscape ? (isDesktop ? 18 : isTablet ? 16 : 15) : (isDesktop ? 20 : isTablet ? 18 : 16),
              fontWeight: FontWeight.bold
            ),),
          ),

          const SizedBox(height: 15),

            _buildInfoCard(),

          const SizedBox(height: 15),

          Align(
            alignment: Alignment.topLeft,
            child: Text("Today's Summary",
            style: GoogleFonts.kameron(
              fontSize: isLandscape ? (isDesktop ? 18 : isTablet ? 16 : 15) : (isDesktop ? 20 : isTablet ? 18 : 16),
              fontWeight: FontWeight.bold
            ),),
          ),
          
          const SizedBox(height: 15),

          if(userData?['role'] == 'admin')...[

          _salesSummaryAdmin(),
          SizedBox(height: 2,),
        Align(
        alignment: Alignment.bottomRight,
        child: ElevatedButton.icon(
          icon: Icon(
            Icons.person_add_rounded,
            size: isLandscape ? (isDesktop ? 22 : isTablet ? 20 : 18) : (isDesktop ? 24 : isTablet ? 22 : 19),
            color: Colors.black,
          ),
          label: Text(
            "Add Cashier",
            style: GoogleFonts.kameron(
              fontSize: isLandscape ? (isDesktop ? 18 : isTablet ? 16 : 14) : (isDesktop ? 20 : isTablet ? 17 : 14),
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF30DD04),
            foregroundColor: Colors.black,
            elevation: 5,
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 34 : isTablet ? 30 : 26,
              vertical: isDesktop ? 15 : isTablet ? 13 : 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _showAddCashierModal,
        ),
      ),

          ]else...[

          _saleSummaryCashier(),
         
          ],

          const SizedBox(height: 200),


          _buildActionButton(icon: Icons.settings, text: 'Settings', color:  Theme.of(context).colorScheme.onSurface, onTap: () async {
            Navigator.push( context, MaterialPageRoute(builder: (context) => const Settings()),);
              
            }),

            const SizedBox(height: 12),

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


Future<void> _showAddCashierModal() async {
  
  bool modalLoading = false;

  final isDesktop = Responsive.isDesktop(context);
  final isTablet = Responsive.isTablet(context);
  final isLandscape = Responsive.isLandscape(context);

    nameController.clear();
    usernameController.clear();
    emailController.clear();
    contactController.clear();
    addressController.clear();
    passwordController.clear();

    nameError = null;
    usernameError = null;
    emailError = null;
    contactError = null;
    addressError = null;
    passwordError = null;

  await showGeneralDialog(
    context: context,
    barrierLabel: "Add Cashier",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.3), 
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      return Center(
        child: Material(
            color: Theme.of(context).colorScheme.surface, 
            borderRadius: BorderRadius.circular(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 420 : isTablet ? 380 : 340,
              maxHeight: MediaQuery.of(context).size.height * 0.85, 
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: StatefulBuilder(
                builder: (context, setDialogState) {

                  return SingleChildScrollView(    
                    scrollDirection: Axis.vertical,    
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Add New Cashier",
                          style: GoogleFonts.kameron(
                            fontSize: isLandscape ? (isDesktop ? 20 : isTablet ? 18 : 17) : (isDesktop ? 22 : isTablet ? 20 : 18),
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 24),

               
                        TextField(
                          controller: nameController,
                          obscureText: false,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                            LengthLimitingTextInputFormatter(60)
                          ],
                          style: GoogleFonts.kameron(fontSize:  isLandscape ? (isDesktop ? 18 : isTablet ? 16 : 15) : (isDesktop ? 22 : isTablet ? 20 : 16)),
                          decoration: InputDecoration(
                            labelText: "Full Name",
                            labelStyle: GoogleFonts.kameron(
                              fontSize: isDesktop ? 19 : isTablet ? 17 : 15,
                              color: Colors.grey[900],
                              fontWeight: FontWeight.w500,
                            ),
                            errorText: nameError,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: EdgeInsets.symmetric(
                              vertical: isLandscape ? (isDesktop ? 12 : isTablet ? 10 : 9) : (isDesktop ? 18 : isTablet ? 15 : 10),
                              horizontal: 13,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        TextField(
                          controller: usernameController,
                          obscureText: false,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
                            LengthLimitingTextInputFormatter(30),
                          ],
                          style: GoogleFonts.kameron(fontSize:  isLandscape ? (isDesktop ? 18 : isTablet ? 16 : 15) : (isDesktop ? 22 : isTablet ? 20 : 16)),
                          decoration: InputDecoration(
                            labelText: "Username",
                            labelStyle: GoogleFonts.kameron(
                              fontSize: isDesktop ? 19 : isTablet ? 17 : 15,
                              color: Colors.grey[900],
                              fontWeight: FontWeight.w500,
                            ),
                            errorText: usernameError,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: EdgeInsets.symmetric(
                              vertical: isLandscape ? (isDesktop ? 12 : isTablet ? 10 : 9) : (isDesktop ? 18 : isTablet ? 15 : 10),
                              horizontal: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextField(
                        style: GoogleFonts.kameron(
                            fontSize: isDesktop ? 22 : isTablet ? 20 : 16
                          ),
                        controller: emailController,
                        obscureText: false,
                        inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._-]')),
                          ],
                        decoration: InputDecoration(
                          labelText: "Email Address",
                          labelStyle: GoogleFonts.kameron(fontSize:  isLandscape ? (isDesktop ? 18 : isTablet ? 16 : 15) : (isDesktop ? 22 : isTablet ? 20 : 16) ,color: Colors.grey[900], fontWeight: FontWeight.w500),  
                          errorText: emailError,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: EdgeInsets.symmetric(
                            vertical: isLandscape ? (isDesktop ? 12 : isTablet ? 10 : 9) : (isDesktop ? 18 : isTablet ? 15 : 10), 
                            horizontal: 13)
                        ),
                      ),

                    const SizedBox(height: 12),

                      TextField(
                        style: GoogleFonts.kameron(
                            fontSize: isDesktop ? 22 : isTablet ? 20 : 16
                          ),
                        controller: contactController,
                        obscureText: false,
                        inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]')),
                            LengthLimitingTextInputFormatter(15),
                          ],
                        decoration: InputDecoration(
                          labelText: "Contact Number",
                          labelStyle: GoogleFonts.kameron(fontSize:  isLandscape ? (isDesktop ? 18 : isTablet ? 16 : 15) : (isDesktop ? 22 : isTablet ? 20 : 16) ,color: Colors.grey[900], fontWeight: FontWeight.w500),  
                          errorText: contactError,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: EdgeInsets.symmetric(
                            vertical: isLandscape ? (isDesktop ? 12 : isTablet ? 10 : 9) : (isDesktop ? 18 : isTablet ? 15 : 10),
                            horizontal: 13)
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        style: GoogleFonts.kameron(
                            fontSize: isDesktop ? 22 : isTablet ? 20 : 16
                          ),
                        controller: addressController,
                        inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s,.-]')),
                          ],
                        obscureText: false,
                        decoration: InputDecoration(
                          labelText: "Address",
                          labelStyle: GoogleFonts.kameron(fontSize:  isLandscape ? (isDesktop ? 18 : isTablet ? 16 : 15) : (isDesktop ? 22 : isTablet ? 20 : 16) ,color: Colors.grey[900], fontWeight: FontWeight.w500),  
                          errorText: addressError,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: EdgeInsets.symmetric(
                            vertical: isLandscape ? (isDesktop ? 12 : isTablet ? 10 : 9) : (isDesktop ? 18 : isTablet ? 15 : 10),
                             horizontal: 13)
                        ),
                      ),

                      const SizedBox(height: 12),

                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'[\s]')),
                          ],
                          style: GoogleFonts.kameron(fontSize:  isLandscape ? (isDesktop ? 18 : isTablet ? 16 : 15) : (isDesktop ? 22 : isTablet ? 20 : 16)),
                          decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: GoogleFonts.kameron(fontSize: isDesktop ? 19 : isTablet ? 17: 15 ,color: Colors.grey[900], fontWeight: FontWeight.w500),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            errorText: passwordError,
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: EdgeInsets.symmetric(
                              vertical:isLandscape ? (isDesktop ? 12 : isTablet ? 10 : 9) : (isDesktop ? 18 : isTablet ? 15 : 10),
                              horizontal: 13,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                  Navigator.pop(context);
                                  
                                  nameController.clear();
                                  usernameController.clear();
                                  emailController.clear();
                                  contactController.clear();
                                  addressController.clear();
                                  passwordController.clear();

                                  if(!mounted) return;

                                  setState(() {
                                    nameError = null;
                                    usernameError = null;
                                    emailError = null;
                                    contactError = null;
                                    addressError = null;
                                    passwordError = null;
                                  });
                                },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Cancel",
                                  style: GoogleFonts.kameron(
                                    fontSize: isLandscape ? (isDesktop ? 18 : isTablet ? 16 : 14) : (isDesktop ? 21 : isTablet ? 18 : 15),
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF30DD04),
                                elevation: 4,
                                padding: EdgeInsets.symmetric(
                                  vertical: isDesktop ? 12 : isTablet ? 10 : 8,
                                  horizontal: isDesktop ? 32 : isTablet ? 28 : 24,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: modalLoading
                                  ? null
                                  : () async {
                                    
                                    setDialogState(() {
                         
                                      nameError = nameController.text.trim().isEmpty
                                              ? "Full name is required"
                                              : null;
                                          usernameError = usernameController.text.trim().isEmpty
                                              ? "Username is required"
                                              : null;
                                          emailError = emailController.text.trim().isEmpty
                                              ? "Email is required"
                                              : null;
                                          contactError = contactController.text.trim().isEmpty
                                              ? "Contact number is required"
                                              : null;
                                          addressError = addressController.text.trim().isEmpty
                                              ? "Address is required"
                                              : null;
                                          passwordError = passwordController.text.trim().isEmpty
                                              ? "Password is required"
                                              : null;
                                        });

                                    if ([nameError, usernameError, emailError, contactError, addressError, passwordError].any((e) => e != null)) {
                                          return;
                                        }

                                      setDialogState(() => modalLoading = true);

                                      final success = await _handleCashierInsertion();

                                      setDialogState(() => modalLoading = false);

                                      if (!mounted) return;

                                      if (success) {
                                          Navigator.pop(context);

                                          nameController.clear();
                                          usernameController.clear();
                                          emailController.clear();
                                          contactController.clear();
                                          addressController.clear();
                                          passwordController.clear();

                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text("Cashier added successfully!"),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }else{
                                          setDialogState(() => modalLoading = false);
                                        }

                                    },
                              child: modalLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.person_add_rounded,
                                          size: isDesktop ? 24 : isTablet ? 22 : 20, 
                                          color: Colors.black),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Add Cashier",
                                        style: GoogleFonts.kameron(
                                          fontSize: isLandscape ? (isDesktop ? 18 : isTablet ? 16 : 14) : (isDesktop ? 21 : isTablet ? 18 : 15),
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return ScaleTransition(
        scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
        child: child,
      );
    },
  );
}



  Widget _buildInfoCard() {
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ShadowHelper.getShadow(context),
      ),
      child: Column(
        crossAxisAlignment:CrossAxisAlignment.start,
        children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Contact Number:', style: GoogleFonts.kameron(
                   fontSize:  isDesktop ? 18 : isTablet ? 15 : 15,
                   fontWeight: FontWeight.w500,
                   color: Theme.of(context).colorScheme.onSurface
                ),),
                Text(userData?['contact_number'] ?? 'N/A', style: GoogleFonts.kameron(
                   fontSize:  isDesktop ? 18 : isTablet ? 17 : 15,
                   fontWeight: FontWeight.w500,
                   color: Theme.of(context).colorScheme.onSurface
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow:ShadowHelper.getShadow(context)
      ),
      child: Column(
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Transaction: ', style: GoogleFonts.kameron(
                   fontSize:  isDesktop ? 18 : isTablet ? 17 : 15,
                   fontWeight: FontWeight.w500,
                   color: Theme.of(context).colorScheme.onSurface
                ),),
                Text('${summaryData?['transaction_count'] ?? 0}', style: GoogleFonts.kameron(
                   fontSize:  isDesktop ? 18 : isTablet ? 17 : 15,
                   fontWeight: FontWeight.w500,
                   color: Theme.of(context).colorScheme.onSurface
                   
                ),)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Revenue: ', style: GoogleFonts.kameron(
                   fontSize:  isDesktop ? 18 : isTablet ? 17 : 15,
                   fontWeight: FontWeight.w500,
                   color: Theme.of(context).colorScheme.onSurface
                ),),
                Text('₱${((summaryData?['total_revenue'] ?? 0) as num).toStringAsFixed(2)}', style: GoogleFonts.kameron(
                   fontSize:  isDesktop ? 18 : isTablet ? 17 : 15,
                   fontWeight: FontWeight.w500,
                   color: Theme.of(context).colorScheme.onSurface
                ),)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Items Sold: ', style: GoogleFonts.kameron(
                   fontSize:  isDesktop ? 18 : isTablet ? 17 : 15,
                   fontWeight: FontWeight.w500,
                   color: Theme.of(context).colorScheme.onSurface
                ),),
                Text('${summaryData?['items_sold'] ?? 0}', style: GoogleFonts.kameron(
                   fontSize:  isDesktop ? 18 : isTablet ? 17 : 15,
                   fontWeight: FontWeight.w500,
                   color: Theme.of(context).colorScheme.onSurface
                ),)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Average sales: ', style: GoogleFonts.kameron(
                   fontSize:  isDesktop ? 18 : isTablet ? 17 : 15,
                   fontWeight: FontWeight.w500,
                   color: Theme.of(context).colorScheme.onSurface
                ),),
                Text('₱${((summaryData?['average_sales'] ?? 0) as num).toStringAsFixed(2)}', style: GoogleFonts.kameron(
                   fontSize:  isDesktop ? 18 : isTablet ? 17 : 15,
                   fontWeight: FontWeight.w500,
                   color: Theme.of(context).colorScheme.onSurface
                ),)
              ],
            ),
        ],
      ),
    );
  }


   Widget _cashierCard(Map<String,dynamic> cashier){

    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    final isLandscape = Responsive.isLandscape(context);

    return Container(
       margin: const EdgeInsets.only(bottom: 12),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: ShadowHelper.getShadow(context)
        ),
      child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Cashier:', style: GoogleFonts.kameron(
                    fontSize: isLandscape ? (isDesktop ? 18 : isTablet ? 16 : 14) : (isDesktop ? 20 : isTablet ? 18 : 16),
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface
                  ),),
                  SizedBox(width: 15,),
                Text(
                  capitalizeEachWord(cashier['name'] ?? cashier['username']),
                  style: GoogleFonts.kameron(
                    fontSize: isLandscape ? (isDesktop ? 18 : isTablet ? 16 : 14) : (isDesktop ? 20 : isTablet ? 18 : 16),
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface
                  ),
                ),
              ],
            ),
            Divider(thickness: 1,color: Theme.of(context).colorScheme.onSurface,),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Transactions: ', style: GoogleFonts.kameron(fontSize: isDesktop ? 18 : isTablet ? 17 : 15, fontWeight: FontWeight.w500,color: Theme.of(context).colorScheme.onSurface)),
                Text('${cashier['transaction_count'] ?? 0}', style: GoogleFonts.kameron(fontSize: isDesktop ? 18 : isTablet ? 17 : 15, fontWeight: FontWeight.w500,color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Revenue: ', style: GoogleFonts.kameron(fontSize: isDesktop ? 18 : isTablet ? 17 : 15, fontWeight: FontWeight.w500,color: Theme.of(context).colorScheme.onSurface)),
                Text('₱${((cashier['total_revenue'] ?? 0) as num).toStringAsFixed(2)}', style: GoogleFonts.kameron(fontSize: isDesktop ? 18 : isTablet ? 17 : 15, fontWeight: FontWeight.w500,color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Items Sold: ', style: GoogleFonts.kameron(fontSize: isDesktop ? 18 : isTablet ? 17 : 15, fontWeight: FontWeight.w500,color: Theme.of(context).colorScheme.onSurface)),
                Text('${cashier['items_sold'] ?? 0}', style: GoogleFonts.kameron(fontSize: isDesktop ? 18 : isTablet ? 17 : 15, fontWeight: FontWeight.w500,color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Average Sales: ', style: GoogleFonts.kameron(fontSize: isDesktop ? 18 : isTablet ? 17 : 15, fontWeight: FontWeight.w500,color: Theme.of(context).colorScheme.onSurface)),
                Text('₱${((cashier['average_sales'] ?? 0) as num).toStringAsFixed(2)}', style: GoogleFonts.kameron(fontSize: isDesktop ? 18 : isTablet ? 17 : 15, fontWeight: FontWeight.w500,color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
          ],
        ), 
    );
  }





  Widget _salesSummaryAdmin() {
  final isDesktop = Responsive.isDesktop(context);
  final isTablet = Responsive.isTablet(context);
  final isLandscape = Responsive.isLandscape(context);

  if (allCashiersSummary.isEmpty) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: ShadowHelper.getShadow(context)
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline_rounded,
                  size: isDesktop ? 72 : isTablet ? 62 : 52,
                  color:  Theme.of(context).iconTheme.color,
                ),
                const SizedBox(height: 20),
                Text(
                  "No Cashiers Yet",
                  style: GoogleFonts.kameron(
                    fontSize: isDesktop ? 23 : isTablet ? 21 : 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "You haven't added any cashier yet.\nTap the 'Add Cashier' button below to get started.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.kameron(
                    fontSize: isDesktop ? 16 : isTablet ? 15 : 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10,)
        ],
      );
    }


  return isLandscape  
  ? Wrap(
    spacing: 12,
    runSpacing: 12,
    children: allCashiersSummary.map((cashier) {
      return SizedBox(
        width: isLandscape ? MediaQuery.of(context).size.width / 2 - 24
          : double.infinity,
        child: _cashierCard(cashier)
        );
    }).toList(),
  )
  : Column(
    children: allCashiersSummary.map((cashier) {
      return _cashierCard(cashier);
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
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: ShadowHelper.getShadow(context)
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
