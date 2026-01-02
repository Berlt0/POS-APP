// lib/widgets/footer.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    // The whole bottomNavigationBar must have a definite height.
    // We use a SizedBox so Scaffold can measure it reliably.
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
                  _navItem(Icons.dashboard_outlined, "Dashboard", 0),
                  _navItem(Icons.inventory_2_outlined, "Inventory", 1),
                  const SizedBox(width: 60), // gap for center button
                  _navItem(Icons.storefront_outlined, "Products", 2),
                  _navItem(Icons.bar_chart_outlined, "Reports", 3),
                ],
              ),
            ),
          ),

          // Floating center button (raised above the bar)
          Positioned(
            top: -18, // raises the button above the colored bar
            left: 0,
            right: 0,
            child: Center(child: _centerButton()),
          ),
        ],
      ),
    );
  }

  Widget _centerButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onCenterTap,
        customBorder: const CircleBorder(),
        child: Container(
          height: 70,
          width: 70,
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
          child: const Icon(
            Icons.point_of_sale,
            size: 30,
            color: Color(0xFF248994),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final bool isActive = currentIndex == index;

    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? Colors.black : const Color.fromARGB(202, 0, 0, 0),
            size: 22,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.kameron(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Colors.black : const Color.fromARGB(202, 0, 0, 0),
            ),
          ),
        ],
      ),
    );
  }
}
