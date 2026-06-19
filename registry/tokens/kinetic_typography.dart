import 'package:flutter/material.dart';

abstract class KineticTypography {
  static const String fontFamily = 'Inter';

  static const TextStyle bodySmall   = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.5);
  static const TextStyle bodyMedium  = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);
  static const TextStyle bodyLarge   = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5);
  static const TextStyle labelSmall  = TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
  static const TextStyle labelMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
  static const TextStyle labelLarge  = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
  static const TextStyle heading4    = TextStyle(fontSize: 20, fontWeight: FontWeight.w700);
  static const TextStyle heading3    = TextStyle(fontSize: 24, fontWeight: FontWeight.w700);
  static const TextStyle heading2    = TextStyle(fontSize: 30, fontWeight: FontWeight.w700);
  static const TextStyle heading1    = TextStyle(fontSize: 36, fontWeight: FontWeight.w800);
}
