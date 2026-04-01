// lib/widgets/footer.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/utils/responsive.dart';

class AppFooter extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onCenterTap;

  const AppFooter({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onCenterTap,
  });

  @override
  Widget build(BuildContext context) {

    final isDesktop  = Responsive.isDesktop(context);
    final isTablet  = Responsive.isTablet(context);

    return SizedBox(
      height: 86, // container height including space for the floating button
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Bottom colored bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF6FE5F2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(Icons.dashboard_outlined, "Dashboard", 0, isDesktop,isTablet),
                  _navItem(Icons.inventory_2_outlined, "Inventory", 1, isDesktop,isTablet),
                  const SizedBox(width: 60), // gap for center button
                  _navItem(Icons.storefront_outlined, "Products", 2, isDesktop,isTablet),
                  _navItem(Icons.bar_chart_outlined, "Reports", 3, isDesktop,isTablet),
                ],
              ),
            ),
          ),

          // Floating center button (raised above the bar)
          Positioned(
            top: -18, // raises the button above the colored bar
            left: 0,
            right: 0,
            child: Center(child: _centerButton(isDesktop,isTablet)),
          ),
        ],
      ),
    );
  }

  Widget _centerButton(bool isDesktop, bool isTablet) {
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onCenterTap,
        customBorder: const CircleBorder(),
        child: Container(
          height: isDesktop ? 90 : isTablet? 80 :70,
          width: isDesktop ? 90 : isTablet? 80 :70,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF3CE7FA), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child:  Icon(
            Icons.point_of_sale,
            size: isDesktop ? 50 : isTablet? 40 : 30,
            color: Color(0xFF248994),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index, bool isDesktop, bool isTablet) {
    final bool isActive = currentIndex == index;

    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.black,
            size: isDesktop ? 29 : isTablet? 26 : 23,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.kameron(
              fontSize: isDesktop ? 15 : isTablet? 14 :13,
              fontWeight:  FontWeight.w500,
              color:  Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
