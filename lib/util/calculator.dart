

//Write a function to calculate total records balance ad return as double and need to include accounts initial balance as wel:

import 'package:accountie/models/account_model.dart';
import 'package:accountie/models/monthy_data.dart';
import 'package:accountie/models/record_model.dart';

double calculateTotalBalance(List<TRecord> records, List<Account> accounts) {
  double totalBalance = 0.0;

  for (var record in records) {
    if (record.type) {
      totalBalance += record.amount;
    } else {
      totalBalance -= record.amount;
    }
  }

  for (var account in accounts) {
    totalBalance += account.initialBalance;
  }

  return totalBalance;
}

double calculateAccountBalance(List<TRecord> records, String accountNumber) {
  double accountBalance = 0.0;

  for (var record in records) {
    if (record.account == accountNumber) {
      if (record.type) {
        accountBalance += record.amount;
      } else {
        accountBalance -= record.amount;
      }
    }
  }
  return accountBalance;
}

  double getMaxValue(List<MonthlyData> monthlyData) {
    if (monthlyData.isEmpty) {
      return 1000; // Default value when no data is available
    }
    double maxIncome = 0.0;
    double maxExpense = 0.0;

    for (var data in monthlyData) {
      maxIncome = data.income > maxIncome ? data.income : maxIncome;
      maxExpense = data.expense > maxExpense ? data.expense : maxExpense;
    }

    return (maxIncome > maxExpense ? maxIncome : maxExpense);
  }


  List<MonthlyData> getMonthlyIncomeExpense(List<TRecord> records) {
    final List<MonthlyData> monthlyData = [];
    for (var r in records) {
      final date = r.transactionDate;
      final monthYear = '${date.month}-${date.year}';
      final amount = r.amount;

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
        monthlyData.add(MonthlyData(month: date.month, year: date.year,
         income: r.type ? amount : 0.0, expense: r.type ? 0.0 : amount, monthYear: monthYear));
      }
    }
    // Sort by month and year
    monthlyData.sort(
      (a, b) => a.year != b.year ? a.year.compareTo(b.year) : a.month.compareTo(b.month),
    );
    return monthlyData;
  }
