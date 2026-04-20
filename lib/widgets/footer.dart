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
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);

    final isLandscape = Responsive.isLandscape(context);

    return SizedBox(
      height: 100, 
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom:20,
            left: isLandscape ? 250 : 20,
            right: isLandscape ? 250 : 20,
            child: Container(
              height: isLandscape ? 58 : 62,
              decoration: BoxDecoration(
                color: const Color(0xFF6FE5F2),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.16),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.30),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _navItem( context, Icons.dashboard_outlined, "Dashboard", 0, isDesktop, isTablet),
                  _navItem( context, Icons.inventory_2_outlined, "Inventory", 1, isDesktop, isTablet),
                  const SizedBox(width: 80), 
                  _navItem( context, Icons.storefront_outlined, "Products", 2, isDesktop, isTablet),
                  _navItem( context, Icons.bar_chart_outlined, "Reports", 3, isDesktop, isTablet),
                ],
              ),
            ),
          ),


          Positioned(
            bottom: isLandscape ? 35 : 39, 
            left: 0,
            right: 0,
            child: Center(
              child: _centerButton(context,isDesktop, isTablet),
            ),
          ),
        ],
      ),
    );
  }

  Widget _centerButton( BuildContext context ,bool isDesktop, bool isTablet) {
    final isLandscape = Responsive.isLandscape(context);

    final double size = isLandscape
      ? (isDesktop ? 70 : isTablet ? 64 : 58)
      : (isDesktop ? 78 : isTablet ? 70 : 64);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onCenterTap,
        customBorder: const CircleBorder(),
        splashColor: const Color(0xFF3CE7FA).withOpacity(0.25),
        child: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF3CE7FA),
              width: 4.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
              BoxShadow(
                color: const Color(0xFF3CE7FA).withOpacity(0.30),
                blurRadius: 14,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Icon(
            Icons.point_of_sale,
            size: isDesktop ? 42 : isTablet ? 37 : 33,
            color: const Color(0xFF248994),
          ),
        ),
      ),
    );
  }

  Widget _navItem( BuildContext context, IconData icon, String label, int index, bool isDesktop, bool isTablet) {

      final isLandscape = Responsive.isLandscape(context);


     final double iconSize = isLandscape
        ? (isDesktop ? 22 : isTablet ? 20 : 18)
        : (isDesktop ? 26 : isTablet ? 24 : 20);

    final double fontSize = isLandscape
        ? (isDesktop ? 15 : isTablet ? 13 : 11)
        : (isDesktop ? 13.5 : isTablet ? 12.5 : 11.5);


    return InkWell(
      onTap: () => onTap(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.black87,
            size: iconSize
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.kameron(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}