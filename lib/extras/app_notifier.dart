import 'package:flutter/material.dart';

class AppNotifier {
  static ValueNotifier banTheme = ValueNotifier(false);

  static ValueNotifier banEvents = ValueNotifier(false);
  static ValueNotifier banRentas = ValueNotifier(false);
  static ValueNotifier banCantidad = ValueNotifier(false);
}