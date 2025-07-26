import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:accountie/models/record_model.dart';
import 'package:accountie/services/data_service.dart';

class RecordListPage extends StatelessWidget {
  const RecordListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final records = List<Record>.from(dataService.records)
      ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Transactions"),
        centerTitle: true,
        elevation: 2,
      ),
      body: records.isEmpty
          ? const Center(child: Text("No records found."))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return _buildRecordTile(record);
              },
            ),
    );
  }

  Widget _buildRecordTile(Record record) {
    final isCredit = record.type;
    final color = isCredit ? Colors.green : Colors.red;
    final amountPrefix = isCredit ? '+' : '-';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(record),
            const SizedBox(height: 6),
            Text(
              "$amountPrefix ₹${record.amount.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _chip(record.category, Icons.category, Colors.blue),
                _chip(record.account, Icons.account_balance_wallet, Colors.indigo),
                if (record.tags != null)
                  ...record.tags!.map((tag) => _chip(tag, Icons.tag, Colors.teal)),
              ],
            ),
            const SizedBox(height: 6),
            if (record.description != null && record.description!.isNotEmpty)
              Text(
                record.description!,
                style: const TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Record record) {
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(record.transactionDate);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          record.subCategory,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        Text(
          dateStr,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _chip(String text, IconData icon, Color color) {
    return Chip(
      label: Text(text),
      avatar: Icon(icon, size: 16, color: Colors.white),
      backgroundColor: color.withOpacity(0.85),
      labelStyle: const TextStyle(color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
