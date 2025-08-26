import 'package:accountie/models/loan_model.dart';
import 'package:accountie/services/data_service.dart';
import 'package:accountie/widgets/custom_textform_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddLoanPage extends StatefulWidget {
  final LoanModel? loan;
  final bool isGiven;
  final bool isEdit;
  const AddLoanPage(
      {super.key, required this.isGiven, required this.isEdit, this.loan});

  @override
  AddLoanPageState createState() => AddLoanPageState();
}

class AddLoanPageState extends State<AddLoanPage> {
  final _formKey = GlobalKey<FormState>();
// Default end date 30 days later
  LoanModel? _currentLoan;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.loan != null) {
      _currentLoan = widget.loan;
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
    if (widget.isEdit) {
      _currentLoan?.recalculateFromScratch();
      await dataService.handleLoan(_currentLoan!, true);
    } else {
      _currentLoan?.isGiven = widget.isGiven;
      _currentLoan?.balanceAmount = _currentLoan!.principalAmount;
      _currentLoan!.loanId =
          FirebaseFirestore.instance.collection('loans').doc().id;
      await dataService.handleLoan(_currentLoan!, false);
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Loan' : 'Create New Loan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              //Party Name
              CustomTextFormWidget(
                label: 'Party Name',
                initialValue: widget.isEdit ? _currentLoan!.partyName : '',
                icon: const Icon(Icons.person),
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
                },
              ),
              const SizedBox(height: 10), //Interest Rate
              CustomTextFormWidget(
                label: 'Interest Rate (%)',
                initialValue:
                    widget.isEdit ? _currentLoan!.interestRate.toString() : '',
                icon: const Icon(Icons.percent),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                          'Start Date: ${_currentLoan?.startDate.toLocal().toString().split(' ')[0]}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final dt = await showDatePicker(
                          context: context,
                          initialDate:
                              _currentLoan?.startDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (dt != null) {
                          setState(() => _currentLoan?.startDate = dt);
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text(
                          'End Date: ${_currentLoan?.endDate?.toLocal().toString().split(' ')[0]}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final dt = await showDatePicker(
                          context: context,
                          initialDate: _currentLoan?.endDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (dt != null) {
                          setState(() => _currentLoan?.endDate = dt);
                        }
                      },
                    ),
                  ),
                  const Expanded(child: Text('Is Given:')),
                  Switch(
                    value: _currentLoan!.isGiven,
                    onChanged: (value) {
                      setState(() {
                        _currentLoan!.isGiven = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
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
                icon: const Icon(Icons.note),
                keyboardType: TextInputType.multiline,
                maxLines: 2,
                onChanged: (value) {
                  if (_currentLoan != null) {
                    _currentLoan!.notes = value;
                  }
                },
              ),
              const SizedBox(height: 20),
              if (widget.isEdit && _currentLoan!.installments.isNotEmpty)
                ...List.generate(_currentLoan!.installments.length, (index) {
                  final installment = _currentLoan!.installments[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Installment ${index + 1}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  initialValue: DateFormat('dd/MM/yyyy').format(
                                      installment.paidDate ?? DateTime.now()),
                                  keyboardType: TextInputType.datetime,
                                  decoration: const InputDecoration(
                                      labelText: 'Paid Date'),
                                  onChanged: (value) {
                                    installment.paidDate =
                                        _tryParseDate(value) ?? DateTime.now();
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue: installment.principalComponent
                                      .toStringAsFixed(2),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                      labelText: 'Principal'),
                                  onChanged: (value) {
                                    installment.principalComponent =
                                        double.tryParse(value) ?? 0.0;
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  initialValue: installment.interestComponent
                                      .toStringAsFixed(2),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                      labelText: 'Interest'),
                                  onChanged: (value) {
                                    installment.interestComponent =
                                        double.tryParse(value) ?? 0.0;
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue:
                                      installment.paidAmount.toStringAsFixed(2),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                      labelText: 'Paid Amount'),
                                  onChanged: (value) {
                                    installment.paidAmount =
                                        double.tryParse(value) ?? 0.0;
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                label: const Text('Delete'),
                                onPressed: () => {
                                  setState(() {
                                    _currentLoan!.installments.removeAt(index);
                                  })
                                },
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),

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

DateTime? _tryParseDate(String input) {
  try {
    return DateFormat('dd/MM/yyyy').parseStrict(input);
  } catch (_) {
    return null;
  }
}
