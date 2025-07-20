import 'package:accountie/widgets/color_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:accountie/models/category_model.dart'; // Assuming this is the correct path for your Category model
import 'package:accountie/widgets/icon_picker_widget.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // Adjust the import path for IconPickerFormField

class AddCategoryDialog extends StatefulWidget {
  final Category? initialCategory; // Optional: for editing existing categories

  const AddCategoryDialog({super.key, this.initialCategory});

  @override
  _AddCategoryDialogState createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedIconFileName; // To hold the selected icon file name
  String?
      _selectedColorHex; // To hold the selected color hex string (e.g., '0xFFFFFFFF')
  int? _initialIndex; // To hold the initial index for editing

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      // If an initial category is provided, pre-fill the form fields
      _nameController.text = widget.initialCategory!.name;
      _selectedIconFileName = widget.initialCategory!.icon;
      _selectedColorHex = widget.initialCategory!.color;
      _initialIndex = widget.initialCategory!.index;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Trigger onSaved for all form fields

      setState(() {
        _isSaving = true;
      });

      try {
        final String categoryName = _nameController.text.trim();
        final String icon = _selectedIconFileName ??
            ''; // Default to empty string if no icon selected
        final String color = _selectedColorHex ??
            '0xFF9E9E9E'; // Default to grey if no color selected (or any default color you prefer)

        if (widget.initialCategory == null) {
          // Adding a new category
          // Determine the next index
          final QuerySnapshot<Map<String, dynamic>> snapshot =
              await FirebaseFirestore.instance.collection('categories').get();
          final int nextIndex =
              snapshot.docs.length; // Simple count for next index

          final newCategory = Category(
            name: categoryName,
            subcategories: [], // New categories start with no subcategories
            icon: icon,
            color: color,
            index: nextIndex,
          );

          await FirebaseFirestore.instance
              .collection('categories')
              .doc(
                  categoryName) // Use category name as document ID for simplicity
              .set(newCategory.toFirestore());

          print('Category added successfully!');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category added successfully!')),
          );
        } else {
          // Editing an existing category
          final updatedCategory = Category(
            name: categoryName,
            subcategories: widget
                .initialCategory!.subcategories, // Keep existing subcategories
            icon: icon,
            color: color,
            index: _initialIndex ?? 0, // Keep existing index or default
          );

          await FirebaseFirestore.instance
              .collection('categories')
              .doc(widget.initialCategory!
                  .name) // Use original category name as doc ID
              .update(updatedCategory.toFirestore());

          print('Category updated successfully!');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category updated successfully!')),
          );
        }

        Navigator.of(context).pop(); // Close the dialog on success
      } catch (e) {
        print('Error saving category: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving category: ${e.toString()}')),
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
      title: Text(widget.initialCategory == null
          ? 'Add New Category'
          : 'Edit Category'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Category Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                  prefixIcon: const Icon(Icons.category),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter category name';
                  }
                  return null;
                },
                enabled: widget.initialCategory ==
                    null, // Disable editing name for existing categories if using name as doc ID
              ),
              const SizedBox(height: 16),

              // Icon Picker Field
              IconPickerFormField(
                context: context,
                initialValue:
                    _selectedIconFileName ?? '', // Corrected parameter name
                decoration: InputDecoration(
                  labelText: 'Category Icon',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                ),
                onSaved: (value) {
                  _selectedIconFileName = value;
                },
              ),
              const SizedBox(height: 16),

              // Color Picker Field (Simple example, you might use a dedicated package)
              ColorPickerField(
                initialColorHex: _selectedColorHex ?? '0xFF9E9E9E',
                label: 'Category Color',
                onColorChanged: (hex) {
                  setState(() {
                    _selectedColorHex = hex;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
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
              : Text(widget.initialCategory == null
                  ? 'Add Category'
                  : 'Save Changes'),
        ),
      ],
    );
  }

  }

