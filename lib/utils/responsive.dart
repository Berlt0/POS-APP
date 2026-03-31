import 'package:flutter/material.dart';

class Responsive {
  // Screen width
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double height(BuildContext context) =>
    MediaQuery.sizeOf(context).height;

  // Breakpoints
  static bool isMobile(BuildContext context) =>
      width(context) < 600;

  static bool isTablet(BuildContext context) =>
      width(context) >= 600 && width(context) < 1024;

  static bool isDesktop(BuildContext context) =>
      width(context) >= 1024;

  
  
  static double font(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
   final w = width(context);

  if (w >= 1024) return desktop ?? tablet ?? mobile;
  if (w >= 600) return tablet ?? mobile;
  return mobile;
  }



  
  static double spacing(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
     final w = width(context);

  if (w >= 1024) return desktop ?? tablet ?? mobile;
  if (w >= 600) return tablet ?? mobile;
  return mobile;
  }
}
