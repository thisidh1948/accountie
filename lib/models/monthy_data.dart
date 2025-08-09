class MonthlyData {
   int month;
   int year;
   double income;
   double expense;
   String monthYear;

  MonthlyData({
    required this.month,
    required this.year,
    required this.income,
    required this.expense,
    required this.monthYear,
  });
}


String monthShortName(int month) {
    const names = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    if (month >= 1 && month <= 12) return names[month];
    return '';
  }