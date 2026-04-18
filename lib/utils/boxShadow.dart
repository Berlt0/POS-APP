import 'package:flutter/material.dart';

class ShadowHelper {
  static List<BoxShadow> getShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return [
      BoxShadow(
        color: isDark
            ? Colors.white.withOpacity(0.05) 
            : Colors.black.withOpacity(0.12), 
        blurRadius: 8,
        spreadRadius: 1,
        offset: const Offset(0, 3),
      ),
    ];
  }
}