import 'package:accountie/widgets/color_picker.dart';
import 'package:accountie/widgets/icon_picker_widget.dart';
import 'package:accountie/widgets/credit_debit_toggle.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:accountie/models/category_model.dart';

class AddSubCategoryDialog extends StatefulWidget {
  final String categoryId;
  final SubCategory? initialSubCategory;
  const AddSubCategoryDialog(
      {super.key, required this.categoryId, this.initialSubCategory});

  @override
  State<AddSubCategoryDialog> createState() => _AddSubCategoryDialogState();
}

class _AddSubCategoryDialogState extends State<AddSubCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  bool _type = false;
  String? _icon;
  String? _color;
  int _index = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final subcat = widget.initialSubCategory;
    _nameController = TextEditingController(text: subcat?.name ?? '');
    _type = subcat?.type?? false; // Default to false if not provided
    _icon = subcat?.icon ?? '';
    _color = subcat?.color ?? '0xFF9E9E9E';
    _index = subcat?.index ?? 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveSubCategory() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSaving = true;
      });
      try {
        final subcat = SubCategory(
          name: _nameController.text.trim(),
          type: _type,
          icon: _icon?.trim() ?? '',
          color: _color?.trim() ?? '',
          items: [],
          index: _index,
        );
        final ref = FirebaseFirestore.instance
            .collection('categories')
            .doc(widget.categoryId)
            .collection('subcategories');
        await ref.doc(subcat.name).set(subcat.toMap());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.initialSubCategory == null
                  ? 'Subcategory added successfully!'
                  : 'Subcategory updated successfully!')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving subcategory: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialSubCategory == null
          ? 'Add Subcategory'
          : 'Edit Subcategory'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration:
                    const InputDecoration(labelText: 'Subcategory Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter name' : null,
                enabled: widget.initialSubCategory == null,
              ),
              const SizedBox(height: 12),
              IconPickerFormField(
                context: context,
                initialValue: _icon ?? '',
                decoration: InputDecoration(
                  labelText: 'Category Icon',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                ),
                onSaved: (value) {
                  _icon = value;
                },
              ),
              const SizedBox(height: 16),
              CreditDebitSwitch(
                initialValue: _type,
                label: 'Type:',
                onChanged: (val) {
                  setState(() {
                    _type = val;
                  });
                },
              ),
              const SizedBox(height: 16),
              ColorPickerField(
                initialColorHex: _color ?? '0xFF9E9E9E',
                label: 'Category Color',
                onColorChanged: (hex) {
                  setState(() {
                    _color = hex;
                  });
                },
              ),
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
          onPressed: _isSaving ? null : _saveSubCategory,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 3))
              : Text(widget.initialSubCategory == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}
