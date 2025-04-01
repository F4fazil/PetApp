import 'package:flutter/material.dart';

class ThemeColors {
  // Singleton instance
  static final ThemeColors _instance = ThemeColors._internal();
  factory ThemeColors() => _instance;
  ThemeColors._internal();

  // Store context (initialized once at app startup)
  BuildContext? _context;

  // Initialize with context from root widget
  static void init(BuildContext context) {
    _instance._context = context;
  }

  // Color getters
  Color get primary => _getScheme.primary;
  Color get onPrimary => _getScheme.onPrimary;
  Color get iconBackground => _getScheme.onPrimary;
  Color get onprimaryconatiner => _getScheme.onPrimaryContainer;

  // Add other color getters as needed...

  // Helper to get color scheme
  ColorScheme get _getScheme {
    assert(
      _context != null,
      'Context not initialized. Call ThemeColors.init() first',
    );
    return Theme.of(_context!).colorScheme;
  }
}
