import 'package:accountie/models/loan_model.dart';
import 'package:accountie/services/data_service.dart';
import 'package:flutter/material.dart';
import 'package:accountie/loans/payment_page.dart';
import 'package:provider/provider.dart';

class LoanDetailsPage extends StatelessWidget {
  final LoanModel loan;

  const LoanDetailsPage({super.key, required this.loan});

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Loan Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _detailRow('Party', loan.partyName),
            _detailRow('Status', loan.isOpen ? 'Open' : 'Closed'),
            _detailRow('Principal', '₹${loan.principalAmount.toStringAsFixed(2)}'),
            _detailRow('Interest Rate', '${loan.interestRate.toStringAsFixed(2)}%'),
            _detailRow('Start Date', loan.startDate.toLocal().toString().split(' ')[0]),
            if (loan.endDate != null)
              _detailRow('End Date', loan.endDate!.toLocal().toString().split(' ')[0]),
            _detailRow('Balance', '₹${loan.balanceAmount.toStringAsFixed(2)}'),
            _detailRow('Total Paid', '₹${loan.TotalPaid.toStringAsFixed(2)}'),
            _detailRow('Total Interest Paid', '₹${loan.TotalIntersetPaid.toStringAsFixed(2)}'),
            const SizedBox(height: 20),
            //show installments if available
            if (loan.installments.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Installments:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...loan.installments.map((installment) => _detailRow(
                        'Installment ${installment.installmentId}',
                        '₹${installment.paidAmount?.toStringAsFixed(2)} on ${installment.paidDate?.toLocal().toString().split(' ')[0]}',
                      )),
                ],
              ),
            ElevatedButton.icon(
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (_) => PaymentDialog(loan: loan),
                );
                await dataService.addLoan(loan, true); // persist updates
              },
              icon: const Icon(Icons.payment),
              label: const Text('Payment'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            Expanded(child: Text(value)),
          ],
        ),
      );
}