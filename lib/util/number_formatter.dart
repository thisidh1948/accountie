class NumberFormatter {
  static String formatIndianNumber(double value) {
    bool isNegative = value < 0;
    value = value.abs();

    String formattedValue;
    if (value >= 10000000) {
      formattedValue = '${(value / 10000000).toStringAsFixed(2)}Cr';
    } else if (value >= 100000) {
      formattedValue = '${(value / 100000).toStringAsFixed(2)}L';
    } else if (value >= 1000) {
      formattedValue = '${(value / 1000).toStringAsFixed(2)}K';
    } else {
      formattedValue = value.toStringAsFixed(0);
    }

    return isNegative ? '-$formattedValue' : formattedValue;
  }
}