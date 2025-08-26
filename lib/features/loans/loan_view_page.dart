import 'package:accountie/features/loans/add_loan.dart';
import 'package:accountie/models/loan_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:accountie/services/data_service.dart';
import 'package:accountie/features/loans/loan_details_page.dart';

class LoanViewPage extends StatefulWidget {
  const LoanViewPage({super.key});

  @override
  _LoanViewPageState createState() => _LoanViewPageState();
}

class _LoanViewPageState extends State<LoanViewPage> {
  bool _isGiven = true;

  @override
  Widget build(BuildContext context) {
    final loans = context.watch<DataService>().loans;
    final List<LoanModel> filteredLoans =
        loans.where((loan) => loan.isGiven == _isGiven).toList();
    String title = _isGiven ? 'Given Loans' : 'Received Loans';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(title),
            const SizedBox(width: 10),
            Card(
              elevation: 4,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  filteredLoans
                      .fold(0.0, (sum, loan) => sum + loan.balanceAmount)
                      .toStringAsFixed(2),
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.greenAccent.shade400,
                  ),
                  overflow: TextOverflow.fade,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Switch(
            value: _isGiven,
            onChanged: (value) => setState(() => _isGiven = value),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredLoans.length,
        itemBuilder: (context, index) {
          final loan = filteredLoans[index];
          final double interest = loan.calculateCurrentInterest();
          final toBePaid = loan.balanceAmount + interest;

          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loan.partyName,
                      style: TextStyle(
                          fontSize: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .fontSize!)),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Bal: ${loan.balanceAmount.toStringAsFixed(2)} ',
                          style: const TextStyle(
                              color: Colors.grey, fontStyle: FontStyle.italic)),
                      Text(
                          'Int%: ${loan.calculateCurrentInterest().toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: Colors.grey, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ],
              ),
              trailing: Text(toBePaid.toStringAsFixed(2),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          Theme.of(context).textTheme.titleLarge!.fontSize!)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoanDetailsPage(loan: loan),
                  ),
                );
              },
              onLongPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddLoanPage(
                        loan: loan, isGiven: loan.isGiven, isEdit: true),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddLoanPage(isGiven: _isGiven, isEdit: false),
            ),
          );
        },
        tooltip: 'Add New Loan',
        child: const Icon(Icons.add),
      ),
    );
  }
}
