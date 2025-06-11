import 'package:intl/intl.dart';

/// A utility class to handle currency formatting consistently across the app
class CurrencyFormatter {
  /// Returns a formatted price in Nigerian Naira (₦) with proper formatting
  /// for display on all Android devices.
  /// 
  /// Handles large numbers by converting to K, M, B (thousands, millions, billions)
  /// for better readability.
  static String formatNaira(num amount, {bool useAbbreviations = true}) {
    // For large numbers, use abbreviations if requested
    if (useAbbreviations) {
      if (amount >= 1e9) {
        return '₦${(amount / 1e9).toStringAsFixed(1)}B';
      } else if (amount >= 1e6) {
        return '₦${(amount / 1e6).toStringAsFixed(1)}M';
      } else if (amount >= 1e3) {
        return '₦${(amount / 1e3).toStringAsFixed(1)}K';
      }
    }

    // Use proper NumberFormat for other amounts
    return NumberFormat.currency(
      locale: 'en_NG',
      symbol: '₦',
      decimalDigits: 0,
    ).format(amount);
  }

  /// Format a price without any currency symbol
  static String formatNumber(num amount) {
    return NumberFormat('#,###', 'en_NG').format(amount);
  }
  
  /// Format price with custom currency symbol
  static String formatWithSymbol(num amount, String symbol) {
    if (amount >= 1e9) {
      return '$symbol${(amount / 1e9).toStringAsFixed(1)}B';
    } else if (amount >= 1e6) {
      return '$symbol${(amount / 1e6).toStringAsFixed(1)}M';
    } else if (amount >= 1e3) {
      return '$symbol${(amount / 1e3).toStringAsFixed(1)}K';
    } else {
      return '$symbol${NumberFormat('#,###', 'en_NG').format(amount)}';
    }
  }

  /// Format percentage values (e.g., "25.5%")
  static String formatPercentage(num percentage, {int decimalPlaces = 1}) {
    return '${percentage.toStringAsFixed(decimalPlaces)}%';
  }

  /// Extract numeric value from a formatted currency string
  static num extractNumericValue(String formattedPrice) {
    // Remove all non-numeric characters except for decimal points
    final numericString = formattedPrice.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(numericString) ?? 0;
  }
}