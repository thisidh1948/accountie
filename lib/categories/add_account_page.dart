import 'package:accountie/widgets/icon_picker_widget.dart';
import 'package:accountie/widgets/color_picker.dart';
import 'package:accountie/widgets/date_picker_form_field.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:accountie/models/account_model.dart'; // Adjust the import path for Account model

class AddAccountDialog extends StatefulWidget {
  final Account? initialAccount;
  const AddAccountDialog({super.key, this.initialAccount});

  @override
  State<AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends State<AddAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _accountholderController;
  late final TextEditingController _InitbalanceController;
  late final TextEditingController _bankNameController;
  late final TextEditingController _accountNumberController;
  late final TextEditingController _creditLimitController;
  DateTime? _dueDate;
  DateTime? _billingCycleStartDay;
  int? _index;
  String _type = 'savings';
  String? _icon;
  String? _color;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final acc = widget.initialAccount;
    _accountholderController = TextEditingController(text: acc?.accountholder ?? '');
    _InitbalanceController = TextEditingController(text: acc?.balance.toString() ?? '');
    _bankNameController = TextEditingController(text: acc?.name ?? '');
    _accountNumberController = TextEditingController(text: acc?.accountNumber ?? '');
    _creditLimitController = TextEditingController(text: acc?.creditLimit?.toString() ?? '');
    _dueDate = acc?.dueDate;
    _billingCycleStartDay = acc?.billingCycleStartDay;
    _index = acc?.index;
    _type = acc?.type ?? 'savings';
    _icon = acc?.icon ?? '';
    _color = acc?.color ?? '0xFF9E9E9E';
  }

  @override
  void dispose() {
    _accountholderController.dispose();
    _InitbalanceController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _creditLimitController.dispose();
    super.dispose();
  }

  Future<void> _saveAccount() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() { _isSaving = true; });
      try {
        final account = Account(
          accountholder: _accountholderController.text.trim(),
          type: _type,
          initialBalance: double.tryParse(_InitbalanceController.text.trim()) ?? 0.0,
          name: _bankNameController.text.trim(),
          accountNumber: _accountNumberController.text.trim(),
          creditLimit: _type == 'credit' ? double.tryParse(_creditLimitController.text.trim()) : null,
          dueDate: _type == 'credit' ? _dueDate : null,
          billingCycleStartDay: _type == 'credit' ? _billingCycleStartDay : null,
          index: _index,
          icon: _icon,
          color: _color,
        );
        final ref = FirebaseFirestore.instance.collection('accounts');
        await ref.doc(account.accountNumber).set(account.toFirestore());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.initialAccount == null
              ? 'Account added successfully!'
              : 'Account updated successfully!')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving account: ${e.toString()}')),
        );
      } finally {
        setState(() { _isSaving = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialAccount == null ? 'Add Account' : 'Edit Account'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _accountholderController,
                decoration: const InputDecoration(labelText: 'Account Holder'),
                validator: (value) => value == null || value.isEmpty ? 'Enter account holder' : null,
                enabled: widget.initialAccount == null,
              ),
              const SizedBox(height: 12),
              IconPickerFormField(
                context: context,
                initialValue: _icon ?? '',
                decoration: InputDecoration(
                  labelText: 'Account Icon',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                onSaved: (value) {
                  _icon = value;
                },
              ),
              const SizedBox(height: 12),
              ColorPickerField(
                initialColorHex: _color ?? '0xFF9E9E9E',
                label: 'Account Color',
                onColorChanged: (hex) {
                  setState(() {
                    _color = hex;
                  });
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Account Type:'),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Text('Credit', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          Switch(
                            value: _type == 'savings',
                            activeColor: Colors.green,
                            inactiveThumbColor: Colors.red,
                            inactiveTrackColor: Colors.red.shade200,
                            onChanged: (val) {
                              setState(() {
                                _type = val ? 'savings' : 'credit';
                              });
                            },
                          ),
                          Text('Savings', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _InitbalanceController,
                decoration: const InputDecoration(labelText: 'Initial Balance'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Enter balance' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bankNameController,
                decoration: const InputDecoration(labelText: 'Bank Name'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _accountNumberController,
                decoration: const InputDecoration(labelText: 'Account Number'),
              ),
              if (_type == 'credit') ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _creditLimitController,
                  decoration: const InputDecoration(labelText: 'Credit Limit'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DatePickerFormField(
                  initialDate: _dueDate,
                  label: 'Due Date',
                  onSaved: (date) {
                    _dueDate = date;
                  },
                ),
                const SizedBox(height: 12),
                DatePickerFormField(
                  initialDate: _billingCycleStartDay,
                  label: 'Billing Cycle Start Day',
                  onSaved: (date) {
                    _billingCycleStartDay = date;
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveAccount,
          child: _isSaving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 3))
              : Text(widget.initialAccount == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}

