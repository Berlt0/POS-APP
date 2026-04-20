import 'package:flutter/material.dart';

class Responsive {


  static Size size(BuildContext context) =>
      MediaQuery.of(context).size;

  static double width(BuildContext context) =>
      size(context).width;

  static double height(BuildContext context) =>
      size(context).height;

  static Orientation orientation(BuildContext context) =>
      MediaQuery.of(context).orientation;

  static bool isLandscape(BuildContext context) =>
      orientation(context) == Orientation.landscape;

  static bool isPortrait(BuildContext context) =>
      orientation(context) == Orientation.portrait;
  


  static bool isMobile(BuildContext context) =>
      width(context) < 600;

  static bool isTablet(BuildContext context) =>
      width(context) >= 600 && width(context) < 1024;

  static bool isDesktop(BuildContext context) =>
      width(context) >= 1024;



  static double scale(BuildContext context) {
    final size = MediaQuery.of(context).size;

    double scaleFactor;

    // Base scaling by width
    if (size.width >= 1024) {
      scaleFactor = 1.0;
    } else if (size.width >= 600) {
      scaleFactor = 0.95;
    } else {
      scaleFactor = 1.0;
    }


    if (isLandscape(context)) {
      scaleFactor *= 0.95;
    }

    return scaleFactor;
  }


  static double font(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final w = width(context);
    double base;

    if (w >= 1024) {
      base = desktop ?? tablet ?? mobile;
    } else if (w >= 600) {
      base = tablet ?? mobile;
    } else {
      base = mobile;
    }

    return base * scale(context);
  }

  static double spacing(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final w = width(context);
    double base;

    if (w >= 1024) {
      base = desktop ?? tablet ?? mobile;
    } else if (w >= 600) {
      base = tablet ?? mobile;
    } else {
      base = mobile;
    }

    return base * scale(context);
  }


  static int gridCount(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return isLandscape(context) ? 4 : 3;
    return isLandscape(context) ? 3 : 2;
  }


  static double cardHeight(BuildContext context) {
    if (isDesktop(context)) {
      return isLandscape(context) ? 100 : 120;
    }

    if (isTablet(context)) {
      return isLandscape(context) ? 95 : 110;
    }

    return isLandscape(context) ? 70 : 75;
  }



  static EdgeInsets pagePadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.fromLTRB(32, 24, 32, 120);
    }

    if (isTablet(context)) {
      return EdgeInsets.fromLTRB(
        isLandscape(context) ? 24 : 20,
        20,
        isLandscape(context) ? 24 : 20,
        110,
      );
    }

    return EdgeInsets.fromLTRB(
      16,
      16,
      16,
      isLandscape(context) ? 80 : 110,
    );
  }



  static bool isCompactHeight(BuildContext context) =>
      MediaQuery.of(context).size.height < 600;

  static bool isWideLandscape(BuildContext context) =>
      isLandscape(context) && width(context) > 700;
}