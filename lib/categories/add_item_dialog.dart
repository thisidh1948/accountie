import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:accountie/models/category_model.dart';
import 'package:accountie/widgets/icon_picker_widget.dart';
import 'package:accountie/widgets/color_picker.dart';

class AddItemDialog extends StatefulWidget {
  final String categoryId;
  final String subCategoryId;
  final Item? initialItem;
  const AddItemDialog({super.key, required this.categoryId, required this.subCategoryId, this.initialItem});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  String? _icon;
  String? _color;
  int _index = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    _nameController = TextEditingController(text: item?.name ?? '');
    _icon = item?.icon ?? '';
    _color = item?.color ?? '0xFF9E9E9E';
    _index = item?.index ?? 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() { _isSaving = true; });
      try {
        final item = Item(
          name: _nameController.text.trim(),
          icon: _icon?.trim() ?? '',
          color: _color?.trim() ?? '',
          index: _index,
        );
        final ref = FirebaseFirestore.instance
            .collection('categories')
            .doc(widget.categoryId)
            .collection('subcategories')
            .doc(widget.subCategoryId)
            .collection('items');
        await ref.doc(item.name).set(item.toMap());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.initialItem == null
              ? 'Item added successfully!'
              : 'Item updated successfully!')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving item: ${e.toString()}')),
        );
      } finally {
        setState(() { _isSaving = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialItem == null ? 'Add Item' : 'Edit Item'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator: (value) => value == null || value.isEmpty ? 'Enter name' : null,
                enabled: widget.initialItem == null,
              ),
              const SizedBox(height: 12),
              IconPickerFormField(
                context: context,
                initialValue: _icon ?? '',
                decoration: InputDecoration(
                  labelText: 'Item Icon',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                onSaved: (value) {
                  _icon = value;
                },
              ),
              const SizedBox(height: 16),
              ColorPickerField(
                initialColorHex: _color ?? '0xFF9E9E9E',
                label: 'Item Color',
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
          onPressed: _isSaving ? null : _saveItem,
          child: _isSaving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 3))
              : Text(widget.initialItem == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}
