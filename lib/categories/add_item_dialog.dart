// ignore_for_file: use_build_context_synchronously

import 'package:accountie/services/data_service.dart';
import 'package:accountie/widgets/custom_textform_widget.dart';
import 'package:flutter/material.dart';
import 'package:accountie/models/category_model.dart';
import 'package:accountie/widgets/icon_picker_widget.dart';
import 'package:accountie/widgets/color_picker.dart';
import 'package:provider/provider.dart';

class AddItemDialog extends StatefulWidget {
  final String categoryId;
  final String subCategoryId;
  final Item? initialItem;
  const AddItemDialog(
      {super.key,
      required this.categoryId,
      required this.subCategoryId,
      this.initialItem});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool isUpdate = false;
  late Item currItem;

  @override
  void initState() {
    super.initState();
    if (widget.initialItem != null) {
      isUpdate = true;
      currItem = widget.initialItem!;
    } else {
      currItem = Item(name: '', icon: '', color: '', index: 0);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSaving = true;
      });
      try {
        final dataService = Provider.of<DataService>(context, listen: false);
        await dataService.handleItem(currItem, widget.categoryId,
            widget.subCategoryId, currItem.name, isUpdate, false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.initialItem == null
                  ? 'Item added successfully!'
                  : 'Item updated successfully!')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving item: ${e.toString()}')),
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
      title: Text(widget.initialItem == null ? 'Add Item' : 'Edit Item'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextFormWidget(
                initialValue: currItem.name,
                label: 'Item Name',
                icon: const Icon(Icons.pan_tool_alt_sharp),
                onChanged: (p0) => {
                  setState(() {
                    currItem.name = p0;
                  })
                },
              ),
              const SizedBox(height: 12),
              IconPickerFormField(
                context: context,
                initialValue: currItem.icon ?? currItem.name,
                decoration: InputDecoration(
                  labelText: 'Item Icon',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                ),
                onSaved: (value) {
                  currItem.icon = value;
                },
              ),
              const SizedBox(height: 16),
              ColorPickerField(
                initialColorHex: currItem.color ?? '0xFF9E9E9E',
                label: 'Item Color',
                onColorChanged: (hex) {
                  setState(() {
                    currItem.color = hex;
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
            await Provider.of<DataService>(context, listen: false).handleItem(
                currItem,
                widget.categoryId,
                widget.subCategoryId,
                currItem.name,
                false,
                true),
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
          onPressed: _isSaving ? null : _saveItem,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 3))
              : Text(widget.initialItem == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}
