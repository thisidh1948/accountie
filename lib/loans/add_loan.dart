import 'package:accountie/models/loan_model.dart';
import 'package:accountie/services/data_service.dart';
import 'package:accountie/widgets/custom_textform_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class AddLoanPage extends StatefulWidget {
  final LoanModel? loanEdit;
  final bool isGiven;
  final bool isEdit;
  const AddLoanPage(
      {Key? key, required this.isGiven, required this.isEdit, this.loanEdit})
      : super(key: key);

  @override
  _AddLoanPageState createState() => _AddLoanPageState();
}

class _AddLoanPageState extends State<AddLoanPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime _startDate = DateTime.now();
  DateTime _endDate =
      DateTime.now().add(Duration(days: 365)); // Default end date 30 days later
  LoanModel? _currentLoan;

  void initState() {
    super.initState();
    if (widget.isEdit && widget.loanEdit != null) {
      _currentLoan = widget.loanEdit;
    } else {
      _currentLoan = LoanModel(
        loanId: '',
        isGiven: widget.isGiven,
        isEmi: false,
        partyName: '',
        principalAmount: 0.0,
        interestRate: 0.0,
        startDate: DateTime.now(),
        isOpen: true,
        notes: null,
        installments: [],
        endDate: null,
        balanceAmount: 0.0,
        monthlyPayment: 0.0,
      );
    }
  }

  Future<void> _submit() async {
    final dataService = Provider.of<DataService>(context, listen: false);
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    _currentLoan!.startDate = _startDate;
    _currentLoan!.endDate = _endDate;
    if (widget.isEdit) {
      // Update existing loan
      await dataService.addLoan(_currentLoan!, true);
    } else {
      // Create new loan
      _currentLoan?.balanceAmount = _currentLoan!.principalAmount;
      _currentLoan!.loanId = FirebaseFirestore.instance.collection('loans').doc().id;
      await dataService.addLoan(_currentLoan!, false);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Loan' : 'Create New Loan'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              //Party Name
              CustomTextFormWidget(
                label: 'Party Name',
                initialValue: widget.isEdit ? _currentLoan!.partyName : '',
                icon: Icon(Icons.person),
                keyboardType: TextInputType.text,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter party name'
                    : null,
                onChanged: (value) {
                  if (_currentLoan != null) {
                    _currentLoan!.partyName = value;
                  }
                },
              ),
              const SizedBox(height: 10), //Principal Amount
              CustomTextFormWidget(
                label: 'Principal Amount',
                initialValue: widget.isEdit
                    ? _currentLoan!.principalAmount.toString()
                    : '',
                icon: const Icon(Icons.money),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter principal amount'
                    : null,
                onChanged: (value) {
                  if (_currentLoan != null) {
                    _currentLoan!.principalAmount =
                        value.isEmpty ? 0.0 : double.parse(value);
                  }
                  ;
                },
              ),
              const SizedBox(height: 10), //Interest Rate
              CustomTextFormWidget(
                label: 'Interest Rate (%)',
                initialValue:
                    widget.isEdit ? _currentLoan!.interestRate.toString() : '',
                icon: Icon(Icons.percent),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter interest rate'
                    : null,
                onChanged: (value) {
                  if (_currentLoan != null) {
                    _currentLoan!.interestRate =
                        value.isEmpty ? 0.0 : double.parse(value);
                  }
                  ;
                },
              ),
              const SizedBox(height: 10), // Start and End Date
              Row(
                crossAxisAlignment: CrossAxisAlignment
                    .center, // Align items vertically in the center
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text(
                          'Start Date: ${_startDate.toLocal().toString().split(' ')[0]}'),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () async {
                        final dt = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (dt != null) setState(() => _startDate = dt);
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text(
                          'End Date: ${_endDate.toLocal().toString().split(' ')[0]}'),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () async {
                        final dt = await showDatePicker(
                          context: context,
                          initialDate: _endDate,
                          firstDate: _startDate,
                          lastDate: DateTime(2100),
                        );
                        if (dt != null) setState(() => _endDate = dt);
                      },
                    ),
                  ),
                  Expanded(child: Text('Is Given:')),
                  Switch(
                    value: widget.isGiven,
                    onChanged: (value) {
                      setState(() {
                        _currentLoan!.isGiven = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment
                    .center, // Align items vertically in the center
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CustomTextFormWidget(
                      label: 'Monthly Payment',
                      initialValue: widget.isEdit
                          ? _currentLoan!.monthlyPayment?.toString()
                          : '',
                      icon: const Icon(Icons.payment),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        if (_currentLoan != null) {
                          _currentLoan!.monthlyPayment =
                              value.isEmpty ? null : double.parse(value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextFormWidget(
                      label: 'Compound Frequency',
                      initialValue: widget.isEdit
                          ? _currentLoan!.compoundFrequency?.toString()
                          : '',
                      icon: const Icon(Icons.repeat),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: false),
                      onChanged: (value) {
                        if (_currentLoan != null) {
                          _currentLoan!.compoundFrequency =
                              value.isEmpty ? null : int.tryParse(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CustomTextFormWidget(
                label: 'Notes',
                initialValue: widget.isEdit ? _currentLoan!.notes : '',
                icon: Icon(Icons.note),
                keyboardType: TextInputType.multiline,
                maxLines: 2,
                onChanged: (value) {
                  if (_currentLoan != null) {
                    _currentLoan!.notes = value;
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(widget.isEdit ? 'Edit Loan' : 'Create Loan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
