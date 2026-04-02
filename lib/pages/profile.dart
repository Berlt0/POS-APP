import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/utils/responsive.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  // You can later connect this with real user data
  final String userName = "John Doe";
  final String userEmail = "john.doe@posapp.com";
  final String userRole = "Admin";
  final String joinDate = "March 2025";

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
            const SizedBox(height: 25),

            // Profile Picture
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: isDesktop ? 65 : isTablet ? 60 : 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: const AssetImage('assets/Legendaries.png'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // User Name
            Text(
              userName,
              style: GoogleFonts.kameron(
                fontSize: isDesktop ? 28 : isTablet ? 24 : 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 8),

            // Email & Role
            Text(
              userEmail,
              style: GoogleFonts.kameron(
                fontSize: isDesktop ? 18 : isTablet ? 17 : 15,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                userRole,
                style: GoogleFonts.kameron(
                  fontSize: isDesktop ? 16 : isTablet ? 15 : 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Info Cards
            _buildInfoCard(
              icon: Icons.calendar_today,
              title: "Joined",
              value: joinDate,
              isResponsive: true,
            ),

            const SizedBox(height: 12),

            _buildInfoCard(
              icon: Icons.phone,
              title: "Phone",
              value: "+63 912 345 6789",
              isResponsive: true,
            ),

            const SizedBox(height: 12),

            _buildInfoCard(
              icon: Icons.store,
              title: "Branch",
              value: "Davao Main Store",
              isResponsive: true,
            ),

            const SizedBox(height: 40),

            // Action Buttons
            _buildActionButton(
              icon: Icons.edit,
              text: "Edit Profile",
              color: Colors.blue,
              onTap: () {
                // TODO: Open edit profile
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Edit Profile clicked")),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildActionButton(
              icon: Icons.lock,
              text: "Change Password",
              color: Colors.orange,
              onTap: () {
                // TODO: Change password
              },
            ),

            const SizedBox(height: 12),

            _buildActionButton(
              icon: Icons.logout,
              text: "Logout",
              color: Colors.red,
              onTap: () {
                // TODO: Logout logic
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Reusable Info Card
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required bool isResponsive,
  }) {
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
      child: Row(
        children: [
          Icon(icon, size: isDesktop ? 28 : isTablet ? 26 : 24, color: Colors.grey[700]),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.kameron(
                  fontSize: isDesktop ? 16 : isTablet ? 15 : 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.kameron(
                  fontSize: isDesktop ? 19 : isTablet ? 18 : 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Reusable Action Button
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