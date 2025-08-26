import 'package:accountie/services/data_service.dart';
import 'package:accountie/widgets/color_picker.dart';
import 'package:accountie/widgets/custom_textform_widget.dart';
import 'package:flutter/material.dart';
import 'package:accountie/models/category_model.dart'; // Assuming this is the correct path for your Category model
import 'package:accountie/widgets/icon_picker_widget.dart';
import 'package:provider/provider.dart';

class AddCategoryDialog extends StatefulWidget {
  final Category? initialCategory; // Optional: for editing existing categories

  const AddCategoryDialog({super.key, this.initialCategory});

  @override
  _AddCategoryDialogState createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _isUpdate = false;
  late Category _currCat;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _isUpdate = true;
      _currCat = widget.initialCategory!;
    } else {
      _currCat = Category(
          name: '', icon: '', color: '0xFF9E9E9E', index: 0, subcategories: []);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _saveCategory() async {
    final dataService = Provider.of<DataService>(context, listen: false);

    if (!_isSaving) {
      if (_formKey.currentState?.validate() ?? false) {
        _formKey.currentState?.save();
        setState(() {
          _isSaving = true;
        });

        try {
          await dataService.handleCategory(_currCat, _currCat.name, _isUpdate, false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category added successfully!')),
          );
        } catch (e) {
          print('Error saving category: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving category: ${e.toString()}')),
          );
        } finally {
          if (mounted) {
            setState(() {
              _isSaving = false;
            });
            Navigator.of(context).pop();
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialCategory == null
          ? 'Add New Category'
          : 'Edit Category'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CustomTextFormWidget(
                label: 'Category Name',
                initialValue: _currCat.name,
                icon: const Icon(Icons.category),
                onChanged: (value) {
                  setState(() {
                    _currCat.name = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              IconPickerFormField(
                context: context,
                initialValue:
                    _currCat.icon ?? _currCat.name, // Corrected parameter name
                decoration: InputDecoration(
                  labelText: 'Category Icon',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                ),
                onChanged: (icon) {
                    _currCat.icon = icon;
                },
              ),
              const SizedBox(height: 16),

              // Color Picker Field (Simple example, you might use a dedicated package)
              ColorPickerField(
                initialColorHex: _currCat.color ?? '0xFF9E9E9E',
                label: 'Category Color',
                onColorChanged: (hex) {
                  setState(() {
                    _currCat.color = hex;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('DELETE'),
          onPressed: () async {
            await Provider.of<DataService>(context, listen: false)
                .handleCategory(_currCat, _currCat.name, false, true);
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveCategory,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : Text(!_isUpdate
                  ? 'Add Category'
                  : 'Save Changes'),
        ),
      ],
    );
  }
}
