import 'package:accountie/models/loan_model.dart';
import 'package:flutter/material.dart';

class PaymentDialog extends StatefulWidget {
  final LoanModel loan;
  const PaymentDialog({super.key, required this.loan});

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  DateTime _paymentDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Make a Payment'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount'),
              validator: (val) {
                final value = double.tryParse(val ?? '');
                if (value == null || value <= 0) return 'Enter a valid amount';
                return null;
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              title: Text('Date: ${_paymentDate.toLocal().toString().split(' ')[0]}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final dt = await showDatePicker(
                  context: context,
                  initialDate: _paymentDate,
                  firstDate: widget.loan.startDate,
                  lastDate: DateTime.now(),
                );
                if (dt != null) setState(() => _paymentDate = dt);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final amount = double.parse(_amountController.text);
              widget.loan.payment(amount, _paymentDate);
              Navigator.pop(context);
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
