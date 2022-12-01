import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";

class ColorUtils {
  factory ColorUtils() {
    return _singleton;
  }

  ColorUtils._internal();

  static final ColorUtils _singleton = ColorUtils._internal();

  Color borderColor() {
    final Brightness btn = SchedulerBinding.instance.window.platformBrightness;
    final bool isDarkMode = btn == Brightness.dark;
    return isDarkMode ? Colors.white : Colors.black;
  }

  Color iconColor() {
    final Brightness btn = SchedulerBinding.instance.window.platformBrightness;
    final bool isDarkMode = btn == Brightness.dark;
    return isDarkMode ? Colors.black : Colors.white;
  }
}
