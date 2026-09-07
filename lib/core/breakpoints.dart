import 'package:flutter/widgets.dart';

class Breakpoints {
  const Breakpoints._();

  static const double compact = 600;
  static const double medium = 900;
  static const double expanded = 1280;
  static const double contentMaxWidth = 1120;
}

enum LayoutSize { compact, medium, expanded }

LayoutSize layoutSizeOf(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;

  if (width >= Breakpoints.expanded) return LayoutSize.expanded;
  if (width >= Breakpoints.medium) return LayoutSize.medium;
  return LayoutSize.compact;
}
