import 'package:flutter/material.dart';
class THelperFunctions {
    /// Проверяет, включена ли тёмная тема для переданного [context].
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Возвращает полный размер экрана (ширина и высота) для [context].
  static Size screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  /// Возвращает высоту экрана для [context].
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Возвращает ширину экрана для [context].
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
}