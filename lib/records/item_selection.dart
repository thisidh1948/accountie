import 'package:accountie/models/category_model.dart';
import 'package:accountie/widgets/svg_icon_widgets.dart';
import 'package:flutter/material.dart';

class SelectItemTypeDialog extends StatefulWidget {
  final SubCategory selectedSubCategory;

  const SelectItemTypeDialog({super.key, required this.selectedSubCategory});

  @override
  State<SelectItemTypeDialog> createState() => _SelectItemTypeDialogState();
}

class _SelectItemTypeDialogState extends State<SelectItemTypeDialog> {
  final TextEditingController _customTypeController = TextEditingController();

  @override
  void dispose() {
    _customTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Item> items = widget.selectedSubCategory.items ?? [];

    return AlertDialog(
      title: const Text('Select Transaction Type/Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // List existing items
            if (items.isNotEmpty)
              ...items.map((item) {
                return ListTile(
                  leading: item.icon != null && item.icon!.isNotEmpty
                      ? SvgIconWidget(iconFileName: item.icon!, width: 24, height: 24)
                      : Icon(Icons.fiber_manual_record, color: item.color != null && item.color!.isNotEmpty ? Color(int.parse(item.color!)) : Colors.grey),
                  title: Text(item.name),
                  onTap: () {
                    Navigator.of(context).pop(item.name); // Return the item name
                  },
                );
              }).toList(),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('No predefined items for this subcategory.'),
              ),
            const Divider(),
            // Custom entry option
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _customTypeController,
                decoration: const InputDecoration(
                  labelText: 'Or Enter Custom Type',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_customTypeController.text.trim().isNotEmpty) {
                  Navigator.of(context).pop(_customTypeController.text.trim());
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a custom type or select an item.')),
                  );
                }
              },
              child: const Text('Add Custom Type'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
