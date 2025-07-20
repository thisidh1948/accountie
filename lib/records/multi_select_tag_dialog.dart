import 'package:flutter/material.dart';

class MultiSelectTagDialog extends StatefulWidget {
  final List<String> tags;
  final List<String> initialSelected;
  const MultiSelectTagDialog({Key? key, required this.tags, this.initialSelected = const []}) : super(key: key);

  @override
  State<MultiSelectTagDialog> createState() => _MultiSelectTagDialogState();
}

class _MultiSelectTagDialogState extends State<MultiSelectTagDialog> {
  late List<String> selectedTags;

  @override
  void initState() {
    super.initState();
    selectedTags = List<String>.from(widget.initialSelected);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Tags'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.tags.map((tag) {
            final isSelected = selectedTags.contains(tag);
            return ListTile(
              leading: Icon(Icons.label, color: isSelected ? Colors.blue : Colors.grey),
              title: Text(tag),
              trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedTags.remove(tag);
                  } else {
                    selectedTags.add(tag);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(selectedTags),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
