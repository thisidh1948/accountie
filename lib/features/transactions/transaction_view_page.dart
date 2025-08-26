import 'package:accountie/features/transactions/list_tile_struct.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:accountie/services/data_service.dart';
import 'package:intl/intl.dart';

class TransactionViewPage extends StatefulWidget {
  const TransactionViewPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TransactionViewPageState createState() => _TransactionViewPageState();
}

class _TransactionViewPageState extends State<TransactionViewPage> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final records = context.watch<DataService>().records;
    final categories =
        context.watch<DataService>().categories; // Fetch categories
    final accounts = context.watch<DataService>().accounts; // Fetch accounts

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left),
                onPressed: () {
                  setState(() {
                    _currentMonth =
                        DateTime(_currentMonth.year, _currentMonth.month - 1);
                  });
                },
              ),
              Text(
                DateFormat('MMMM yyyy').format(_currentMonth),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_right),
                onPressed: () {
                  setState(() {
                    _currentMonth =
                        DateTime(_currentMonth.year, _currentMonth.month + 1);
                  });
                },
              ),
            ],
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                final filteredRecords = records
                    .where((record) =>
                        record.transactionDate.year == _currentMonth.year &&
                        record.transactionDate.month == _currentMonth.month)
                    .toList();

                if (filteredRecords.isEmpty) {
                  return const Center(
                    child: Text('No Transactions'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredRecords.length,
                  itemBuilder: (context, index) {
                    final record = filteredRecords[index];
                    final titleText = (record.items != null &&
                            record.items!.isNotEmpty &&
                            record.items!.first.name != null &&
                            record.items!.first.name!.trim().isNotEmpty)
                        ? record.items!.first.name!
                        : (record.subCategory?.trim().isNotEmpty == true
                            ? record.subCategory!
                            : 'Unnamed');

                    return getListTile(
                        categories, record, titleText, context, accounts);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
