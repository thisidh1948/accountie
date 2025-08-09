// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';

class Greeter {
  final String name;
  Greeter(this.name);

  void sayHello() => print('Hello, $name!');
}

void main() {
  final records = [
    TRecord(DateTime(2023, 1, 15), 1000.0, true),
    TRecord(DateTime(2023, 1, 20), 500.0, false),
    TRecord(DateTime(2023, 1, 5), 1500.0, true),
    TRecord(DateTime(2023, 2, 10), 2000.0, true),
    TRecord(DateTime(2023, 2, 25), 300.0, false),
    TRecord(DateTime(2023, 2, 5), 700.0, false),
    TRecord(DateTime(2023, 3, 5), 700.0, true),
  ];
  final monthlyData = getMonthlyIncomeExpense45(records);
  for (var data in monthlyData) {
    print('Month: ${data.monthYear}, Income: ${data.income}, Expense: ${data.expense}');
  }
}

class MonthlyData {
  String monthYear;
  double income;
  double expense;
  MonthlyData(this.monthYear, this.income, this.expense);
}

class TRecord {
  DateTime transactionDate;
  double amount;
  bool type; // true for income, false for expense

  TRecord(this.transactionDate, this.amount, this.type); }

 List<MonthlyData> getMonthlyIncomeExpense45(List<TRecord> records) {
    final List<MonthlyData> monthlyData = [];
    for (var r in records) {
      final date = r.transactionDate;
      final monthYear = '${date.month}-${date.year}';
      final amount = r.amount;
      monthlyData.where((n) => n.monthYear == monthYear).map((n) => r.type ? n.income + amount : n.expense + amount);

      bool exists = false;
      for (var data in monthlyData) {
        if (data.monthYear == monthYear) {
          if (r.type) {
            data.income += amount;
          } else {
            data.expense += amount;
          }
          exists = true;
          continue;
        }
      }
      if (!exists) {
        monthlyData.add(MonthlyData(monthYear, r.type ? amount : 0.0, r.type ? 0.0 : amount));
      }
    }
    // Sort by month and year
    monthlyData.sort((a, b) {
      final aParts = a.monthYear.split('-');
      final bParts = b.monthYear.split('-');
      final aMonth = int.parse(aParts[0]);
      final aYear = int.parse(aParts[1]);
      final bMonth = int.parse(bParts[0]);
      final bYear = int.parse(bParts[1]);

      if (aYear != bYear) return aYear.compareTo(bYear);
      return aMonth.compareTo(bMonth);
    });
    return monthlyData;
  }

// List<BarChartGroupData> buildGroupedBarChart56(List<MonthlyData> data) {
//   List<BarChartGroupData> groups = [];
//   for (int i = 0; i < data.length; i++) {
//     final month = data[i];
//     groups.add(
//       BarChartGroupData(
//         x: i,
//         barRods: [
//           BarChartRodData(toY: month.income, color: Colors.green, width: 8, borderRadius: BorderRadius.circular(4)),
//           BarChartRodData(toY: month.expense, color: Colors.red, width: 8, borderRadius: BorderRadius.circular(4)),
//         ],
//         barsSpace: 4,
//       ),
//     );
//   }
//   return groups;
// }
