import 'package:flutter/material.dart';

/// Small helper for responsive layouts on phones, tablets, and large screens.
class Responsive {
  static double width(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double height(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static EdgeInsets pagePadding(BuildContext context) {
    final w = width(context);
    if (w >= 1200) return const EdgeInsets.symmetric(horizontal: 48, vertical: 24);
    if (w >= 800) return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    return const EdgeInsets.all(16);
  }

  /// Grid columns based on screen width.
  static int gridColumns(BuildContext context) {
    final w = width(context);
    if (w >= 1200) return 4;
    if (w >= 900) return 3;
    if (w >= 560) return 2;
    return 1;
  }

  /// Taller cards on narrow screens to avoid bottom overflow.
  static double gridAspectRatio(BuildContext context) {
    final columns = gridColumns(context);
    if (columns == 1) return 2.4;
    if (columns == 2) return 1.25;
    return 1.1;
  }

  static double titleSize(BuildContext context) {
    final w = width(context);
    if (w < 360) return 20;
    if (w < 600) return 22;
    return 24;
  }

  static double bodySize(BuildContext context) {
    final w = width(context);
    if (w < 360) return 13;
    return 14;
  }

  static double maxContentWidth(BuildContext context) {
    final w = width(context);
    if (w >= 1200) return 1100;
    if (w >= 900) return 900;
    return w;
  }
}
