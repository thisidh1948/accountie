import 'package:accountie/services/data_service.dart';
import 'package:accountie/util/calculator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TotalBalance extends StatefulWidget {
  const TotalBalance({super.key});

  @override
  _TotalBalanceState createState() => _TotalBalanceState();
}

class _TotalBalanceState extends State<TotalBalance> {
  @override
  Widget build(BuildContext context) {
    final records = context.watch<DataService>().records;
    final accounts = context.watch<DataService>().accounts;
    final total = calculateTotalBalance(records, accounts);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Total Balance: ₹$total',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
