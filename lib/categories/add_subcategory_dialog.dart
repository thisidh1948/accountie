import 'package:accountie/services/data_service.dart';
import 'package:accountie/widgets/color_picker.dart';
import 'package:accountie/widgets/custom_textform_widget.dart';
import 'package:accountie/widgets/icon_picker_widget.dart';
import 'package:accountie/widgets/credit_debit_toggle.dart';
import 'package:flutter/material.dart';
import 'package:accountie/models/category_model.dart';
import 'package:provider/provider.dart';

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
  late SubCategory currSubCategory;
  bool _isUpdate = false;
  String? _icon;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialSubCategory != null) {
      _isUpdate = true;
      currSubCategory = widget.initialSubCategory!;
    } else {
      currSubCategory = SubCategory(
        name: '',
        type: false,
        icon: '',
        color: '0xFF9E9E9E',
        index: 0,
        items: [],
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _saveSubCategory() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSaving = true;
      });
      try {
       final dataService = Provider.of<DataService>(context, listen: false);
        await dataService.handleSubCategory(
            currSubCategory,
            widget.categoryId,
            currSubCategory.name,
            _isUpdate,
            false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.initialSubCategory == null
                  ? 'Subcategory added successfully!'
                  : 'Subcategory updated successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving subcategory: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isSaving = false;
        });
        Navigator.of(context).pop();
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
              CustomTextFormWidget(
                initialValue: currSubCategory.name,
                label: 'Subcategory Name',
                icon: const Icon(Icons.pan_tool_alt_sharp),
                onChanged: (p0) => {
                  setState(() {
                    currSubCategory.name = p0;
                  })
                },
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
                onChanged: (value) {
                  setState(() {
                    currSubCategory.icon = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              CreditDebitSwitch(
                initialValue: currSubCategory.type,
                label: 'Type:',
                onChanged: (val) {
                  setState(() {
                    currSubCategory.type = val;
                  });
                },
              ),
              const SizedBox(height: 16),
              ColorPickerField(
                initialColorHex: currSubCategory.color ?? '0xFF9E9E9E',
                label: 'Category Color',
                onColorChanged: (hex) {
                  setState(() {
                    currSubCategory.color = hex;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('DELETE'),
          onPressed: () async => {
            await Provider.of<DataService>(context, listen: false)
                .handleSubCategory(currSubCategory, widget.categoryId,
                    currSubCategory.name, false, true),
            if (mounted)
              {
                Navigator.of(context).pop(),
              }
          },
        ),
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
