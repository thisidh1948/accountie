import 'package:accountie/loans/add_loan.dart';
import 'package:accountie/loans/loan_details_page.dart';
import 'package:accountie/models/loan_model.dart';
import 'package:accountie/services/data_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoansListPage extends StatelessWidget {
  const LoansListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final loans = dataService.loans;

    return Scaffold(
      appBar: AppBar(
        title: Text('Loans'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => dataService.refreshAllData(),
          ),
        ],
      ),
      body: loans.isEmpty
          ? Center(child: Text('No loans available.'))
          : ListView.builder(
              itemCount: loans.length,
              itemBuilder: (context, index) {
                final loan = loans[index];
                final interest = loan.calculateCurrentInterest();
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(loan.partyName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Balance: ₹${loan.balanceAmount.toStringAsFixed(2)}'),
                        Text(
                            'Interest Accrued: ₹${interest.toStringAsFixed(2)}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => LoanDetailsPage(loan: loan)),
                        );
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => LoanDetailsPage(loan: loan)),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => AddLoanPage(isGiven: true, isEdit: false)));
        },
        child: Icon(Icons.add),
        tooltip: 'Add New Loan',
      ),
    );
  }
}
